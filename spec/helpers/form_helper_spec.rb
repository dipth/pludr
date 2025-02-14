require 'rails_helper'

RSpec.describe FormHelper, type: :helper do
  describe '#form_errors' do
    # Create an anonymous model for testing
    let(:model) { double("TestModel", errors: errors) }
    let(:errors) { double("Errors", any?: error_messages.any?, full_messages: error_messages) }

    context 'when model has validation errors' do
      let(:error_messages) do
        [
          "Name can't be blank",
          "Email can't be blank"
        ]
      end

      it 'renders error messages in a formatted list' do
        rendered_errors = helper.form_errors(model)

        # Test that it shows multiple error messages
        expect(rendered_errors).to have_selector('li', count: 2)
        expect(rendered_errors).to have_content("Name can't be blank")
        expect(rendered_errors).to have_content("Email can't be blank")
      end
    end

    context 'when model has no validation errors' do
      let(:error_messages) { [] }

      it 'returns nil' do
        expect(helper.form_errors(model)).to be_nil
      end
    end
  end
end
