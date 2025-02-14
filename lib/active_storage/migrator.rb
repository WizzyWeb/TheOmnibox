require 'yaml'
require 'erb'
require 'logger'

class ActiveStorage::Migrator
  Rails.logger = Logger.new($stdout)
  Rails.logger.level = Logger::DEBUG

  def self.migrate(from_service_name, to_service_name)
    configs = load_storage_config

    # Check if services are configured correctly
    if configs[from_service_name.to_s].nil? || configs[to_service_name.to_s].nil?
      raise "Erro: Os serviços '#{from_service_name}' ou '#{to_service_name}' not configured correctly."
    end

    from_service, to_service = configure_services(from_service_name, to_service_name, configs)
    configure_blob_service(from_service)

    Rails.logger.debug { "#{ActiveStorage::Blob.count} Blobs to be migrated #{from_service_name} to #{to_service_name}" }

    migrate_blobs(from_service, to_service, to_service_name)
  end

  # load the storage configs
  def self.load_storage_config
    yaml_with_env = ERB.new(File.read('config/storage.yml')).result
    YAML.load(yaml_with_env)
  end

  # Configure TO and FROM services
  def self.configure_services(from_service_name, to_service_name, configs)
    from_service = configure_service(from_service_name, configs)
    to_service = configure_service(to_service_name, configs)
    [from_service, to_service]
  end

  # Configure a single service based on settings
  def self.configure_service(service_name, configs)
    service_config = configs[service_name.to_s]
    ActiveStorage::Service.configure(service_name, { service_name.to_sym => service_config })
  end

  # Change the blob service on DB
  def self.configure_blob_service(service)
    ActiveStorage::Blob.service = service
  end

  # migrate all blobs to "TO" service
  def self.migrate_blobs(_from_service, to_service)
    # Configure the blob service for the source service
    ActiveStorage::Blob.find_each do |blob|
      next unless blob.image?

      Rails.logger.debug { '.' }

      begin
        blob.open do |io|
          checksum = blob.checksum
          to_service.upload(blob.key, io, checksum: checksum)
        end
      rescue ActiveStorage::FileNotFoundError => e
        # ... ignore file not found error, if it doesn't exist, it doesn't make sense to migrate it
        Rails.logger.debug { 'Non-existant file, unable to migrate it' }
      end
    end
    Rails.logger.debug { 'Successful migration' }
  end

  # migrate a blob
  def self.migrate_blob(blob, to_service, to_service_name)
    # Verify if the blo is already migrated
    if blob.service_name == to_service_name.to_s
      Rails.logger.debug { "Blob #{blob.key} is already on #{to_service_name}, skipping migration." }
      return
    end

    Rails.logger.debug { "Migrating Blob #{blob.key} to#{to_service_name}" }

    begin
      blob.open do |io|
        checksum = blob.checksum
        to_service.upload(blob.key, io, checksum: checksum)
      end
      blob.update!(service_name: to_service_name.to_s)
      log_migration(blob)
    rescue ActiveStorage::FileNotFoundError
      Rails.logger.debug { "Non-existant file to blob #{blob.key}, unable to migrate it" }
    rescue StandardError => e
      handle_migration_error(blob, e)
    end
  end

  # Register the succes migrated Blob
  def self.log_migration(blob)
    Rails.logger.debug { "Blob #{blob.key} successfully migrated" }
  end

  # Register errors on migration
  def self.handle_migration_error(blob, error)
    Rails.logger.error { "Error on blob #{blob.key} migration: #{error.message}\n#{error.backtrace.join("\n")}" }
  end
end
