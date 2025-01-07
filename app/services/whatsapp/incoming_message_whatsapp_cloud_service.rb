# https://docs.360dialog.com/whatsapp-api/whatsapp-api/media
# https://developers.facebook.com/docs/whatsapp/api/media/

class Whatsapp::IncomingMessageWhatsappCloudService < Whatsapp::IncomingMessageBaseService
  private

  def processed_params
    @processed_params ||= params[:entry].try(:first).try(:[], 'changes').try(:first).try(:[], 'value')
  end

  def download_attachment_file(attachment_payload)
    url_response = HTTParty.get(inbox.channel.media_url(attachment_payload[:id]), headers: inbox.channel.api_headers)

    # Log the response details
    unless url_response.success?
      Rails.logger.error(
        "WhatsApp Media Download Error: \n" \
        "Status: #{url_response.code}\n" \
        "Headers: #{url_response.headers}\n" \
        "Body: #{url_response.body}\n" \
        "Media ID: #{attachment_payload[:id]}"
      )
    end

    # Handle unauthorized response
    inbox.channel.authorization_error! if url_response.unauthorized?

    # Only proceed with download if successful
    Down.download(url_response.parsed_response['url'], headers: inbox.channel.api_headers) if url_response.success?
  end
end
