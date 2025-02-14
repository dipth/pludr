require 'rails_helper'

RSpec.describe LayoutHelper, type: :helper do
  describe '#container' do
    subject(:rendered) { helper.container(title: title) { content } }

    let(:title) { 'Test Title' }
    let(:content) { 'Test Content' }

    it 'renders a container with the given title' do
      expect(rendered).to have_content('Test Title')
    end

    it 'renders the content of the block' do
      expect(rendered).to have_content('Test Content')
    end
  end
end
