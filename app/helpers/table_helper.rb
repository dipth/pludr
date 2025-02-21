module TableHelper
  def boolean_with_icon(value)
    if value
      icon "square-check", variant: "outline", aria: { label: t("yes") }, class: "text-green-500"
    else
      icon "square-x", variant: "outline", aria: { label: t("no") }, class: "text-red-500"
    end
  end
end
