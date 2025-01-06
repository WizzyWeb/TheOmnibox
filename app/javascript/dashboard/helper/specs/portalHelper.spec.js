import { buildPortalArticleURL, buildPortalURL } from '../portalHelper';

describe('PortalHelper', () => {
  describe('buildPortalURL', () => {
    it('returns the correct url', () => {
      window.chatwootConfig = {
        hostURL: 'https://chat.theomnibox.com',
        helpCenterURL: 'https://help.theomnibox.com',
      };
      expect(buildPortalURL('handbook')).toEqual(
        'https://help.theomnibox.com/hc/handbook'
      );
      window.chatwootConfig = {};
    });
  });

  describe('buildPortalArticleURL', () => {
    it('returns the correct url', () => {
      window.chatwootConfig = {
        hostURL: 'https://chat.theomnibox.com',
        helpCenterURL: 'https://help.theomnibox.com',
      };
      expect(
        buildPortalArticleURL('handbook', 'culture', 'fr', 'article-slug')
      ).toEqual('https://help.theomnibox.com/hc/handbook/articles/article-slug');
      window.chatwootConfig = {};
    });
  });
});
