module ApplicationHelper
  BOOTSTRAP_ICONS = {
    "mortarboard-fill" => {
      view_box: "0 0 16 16",
      path: "M8.211.5a.5.5 0 0 0-.422 0l-7.5 3a.5.5 0 0 0 0 .928L1.5 4.91v5.472a.5.5 0 0 0 .342.474l6 2a.5.5 0 0 0 .316 0l6-2a.5.5 0 0 0 .342-.474V4.909l1.211-.481a.5.5 0 0 0 0-.928zM8 1.508 14.71 4.2 8 6.891 1.29 4.2zM2.5 5.31l5.342 2.137a.5.5 0 0 0 .316 0L13.5 5.309v4.713L8 11.856l-5.5-1.833zm11.5 5.79v1.4a.5.5 0 0 1-1 0v-1.4z"
    }
  }.freeze

  def bootstrap_icon(name, classes: nil, label: nil)
    icon = BOOTSTRAP_ICONS.fetch(name)
    attributes = {
      xmlns: "http://www.w3.org/2000/svg",
      viewBox: icon[:view_box],
      fill: "currentColor",
      class: classes,
      role: (label.present? ? "img" : "presentation"),
      "aria-hidden": label.present? ? nil : true,
      "aria-label": label
    }.compact

    content_tag(:svg, **attributes) do
      tag.path(d: icon[:path])
    end
  end
end
