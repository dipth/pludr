module AdminHelper
  def admin_action_button(title, url, method: nil, data: nil)
    classes = %w[font-medium rounded-lg text-sm px-5 py-2.5 text-center text-white]

    if method == :delete
      classes += %w[bg-red-700 hover:bg-red-800 dark:bg-red-600 dark:hover:bg-red-700]
    else
      classes += %w[bg-blue-700 hover:bg-blue-800 dark:bg-blue-600 dark:hover:bg-blue-700]
    end

    link_to title, url, method: method, data: data, class: classes.join(" ")
  end
end
