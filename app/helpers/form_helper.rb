module FormHelper
  # Renders a list of validation errors for the given model.
  # @param model [ActiveRecord::Base] The model to render errors for.
  # @return [String] The HTML for the errors or nil if there are no errors.
  def form_errors(model)
    return unless model.errors.any?

    content_tag(:div, class: "p-4 mb-4 text-sm text-red-800 rounded-lg bg-red-50") do
      content_tag(:ul, class: "list-disc pl-4") do
        model.errors.full_messages.each do |message|
          concat content_tag(:li, message)
        end
      end
    end
  end
end
