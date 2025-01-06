import { shallowMount } from '@vue/test-utils';
import messageFormatterMixin from '../messageFormatterMixin';

describe('messageFormatterMixin', () => {
  it('returns correct plain text', () => {
    const Component = {
      render() {},
      mixins: [messageFormatterMixin],
    };
    const wrapper = shallowMount(Component);
    const message =
      '<b>TheOmnibox is an opensource tool. https://www.theomnibox.com</b>';
    expect(wrapper.vm.getPlainText(message)).toMatch(
      'TheOmnibox is an opensource tool. https://www.theomnibox.com'
    );
  });
});
