module ApplicationHelper
  BOOTSTRAP_ICONS = {
    "globe2" => {
      view_box: "0 0 16 16",
      path: "M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8m7.5 6.923V11.5H5.033a12.5 12.5 0 0 0 2.467 3.423m1 0a12.5 12.5 0 0 0 2.467-3.423H8.5zm3.348-4.423a13.1 13.1 0 0 1-1.302 3h2.444A7 7 0 0 0 14.478 10.5zM14.478 9.5a7 7 0 0 0-1.488-3h-2.444a13.1 13.1 0 0 1 1.302 3zM8.5 9.5h2.95a12.5 12.5 0 0 0 0-3H8.5zm-1 0v-3h-2.95a12.5 12.5 0 0 0 0 3zm-3.046 1a13.1 13.1 0 0 0 1.302 3H3.312A7 7 0 0 1 1.522 10.5zM3.312 5.5h2.444a13.1 13.1 0 0 0-1.302-3A7 7 0 0 0 1.522 5.5zm5.188 0h2.467A12.5 12.5 0 0 0 8.5 2.077zm-1 0V2.077A12.5 12.5 0 0 0 5.033 5.5z"
    },
    "diagram-3-fill" => {
      view_box: "0 0 16 16",
      path: "M6 3.5A1.5 1.5 0 0 1 7.5 2h1A1.5 1.5 0 0 1 10 3.5v1A1.5 1.5 0 0 1 8.5 6v1H14a.5.5 0 0 1 .5.5v1a.5.5 0 0 1-1 0V8h-5v.5a.5.5 0 0 1-1 0V8h-5v.5a.5.5 0 0 1-1 0v-1A.5.5 0 0 1 2 7h5.5V6A1.5 1.5 0 0 1 6 4.5zm-6 8A1.5 1.5 0 0 1 1.5 10h1A1.5 1.5 0 0 1 4 11.5v1A1.5 1.5 0 0 1 2.5 14h-1A1.5 1.5 0 0 1 0 12.5zm6 0A1.5 1.5 0 0 1 7.5 10h1a1.5 1.5 0 0 1 1.5 1.5v1A1.5 1.5 0 0 1 8.5 14h-1A1.5 1.5 0 0 1 6 12.5zm6 0a1.5 1.5 0 0 1 1.5-1.5h1a1.5 1.5 0 0 1 1.5 1.5v1a1.5 1.5 0 0 1-1.5 1.5h-1a1.5 1.5 0 0 1-1.5-1.5z"
    },
    "geo-alt-fill" => {
      view_box: "0 0 16 16",
      path: "M8 16s6-5.686 6-10A6 6 0 0 0 2 6c0 4.314 6 10 6 10m0-7a3 3 0 1 1 0-6 3 3 0 0 1 0 6"
    },
    "building" => {
      view_box: "0 0 16 16",
      path: "M6.5 15V1h3v14zm-1 0V0h5v15h3a.5.5 0 0 1 0 1h-11a.5.5 0 0 1 0-1zm-2-1V4h2v10zm9 0V7h2v7zM4 5h1v1H4zm0 2h1v1H4zm0 2h1v1H4zm0 2h1v1H4zm7-3h1v1h-1zm0 2h1v1h-1zm0 2h1v1h-1zM7 3h1v1H7zm0 2h1v1H7zm0 2h1v1H7zm2-4h1v1H9zm0 2h1v1H9zm0 2h1v1H9z"
    },
    "map" => {
      view_box: "0 0 16 16",
      path: "M15.817.113A.5.5 0 0 1 16 .5v14a.5.5 0 0 1-.402.49l-5 1a.5.5 0 0 1-.196 0L5.5 15.01l-4.902.98A.5.5 0 0 1 0 15.5v-14a.5.5 0 0 1 .402-.49l5-1a.5.5 0 0 1 .196 0L10.5.99l4.902-.98a.5.5 0 0 1 .415.103M10 1.91l-4-.8v12.98l4 .8zm1 12.98 4-.8V1.11l-4 .8zm-6-.8V1.11l-4 .8v12.98z"
    },
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

  def safe_return_path(fallback)
    return_to = params[:return_to].to_s
    return fallback unless return_to.start_with?("/")

    return_to
  end

  def resource_stat_label(count)
    "#{pluralize(count, 'record')} total"
  end
end
