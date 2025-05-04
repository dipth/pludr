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

  def game_workflow_state_badge(game)
    attrs = case game.workflow_state
    when "building"
      { class: "bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-300", spinner: true }
    when "started"
      { class: "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300" }
    when "ended"
      { class: "bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300" }
    when "canceled"
      { class: "bg-pink-100 text-pink-800 dark:bg-pink-900 dark:text-pink-300" }
    when "failed"
      { class: "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300" }
    else
      { class: "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-300" }
    end

    text = I18n.t("activerecord.attributes.game.workflow_states.#{game.workflow_state}")

    content_tag :span, class: "#{attrs[:class]} text-xs font-medium me-2 px-2.5 py-0.5 rounded-sm inline-flex items-center" do
      if attrs[:spinner]
        icon("loader-2", variant: "outline", class: "w-2.5 h-2.5 me-1.5 animate-spin", aria: { hidden: true }) + text
      else
        text
      end
    end
  end
end
