import { buildPortalArticleURL, buildPortalURL } from '../portalHelper';

describe('PortalHelper', () => {
  describe('buildPortalURL', () => {
    it('returns the correct url', () => {
      window.chatwootConfig = {
        hostURL: 'https://chatapp.emovur.com',
        helpCenterURL: 'https://help.emovur.com',
      };
      expect(buildPortalURL('handbook')).toEqual(
        'https://help.emovur.com/hc/handbook'
      );
      window.chatwootConfig = {};
    });
  });

  describe('buildPortalArticleURL', () => {
    it('returns the correct url', () => {
      window.chatwootConfig = {
        hostURL: 'https://chatapp.emovur.com',
        helpCenterURL: 'https://help.emovur.com',
      };
      expect(
        buildPortalArticleURL('handbook', 'culture', 'fr', 'article-slug')
      ).toEqual('https://help.emovur.com/hc/handbook/articles/article-slug');
      window.chatwootConfig = {};
    });
  });
});
