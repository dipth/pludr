module LayoutHelper
  # Renders a container that will be centered horizontally and vertically on the page.
  # @param title [String] The title of the container.
  # @yield The content of the container.
  # @return [String] The HTML for the container.
  def container(title: nil, &block)
    content_tag(:div, class: "flex flex-col items-center justify-center md:px-6 md:py-6 mx-auto md:h-screen md:py-0") do
      content_tag(:div, class: "w-full bg-white rounded-lg max-w-xl md:shadow") do
        content_tag(:div, class: "md:p-6") do
          concat content_tag(:h1, title, class: "text-2xl mb-4 font-bold leading-tight tracking-tight text-gray-900")
          concat capture(&block)
        end
      end
    end
  end
end
