module ApplicationHelper
  BOOTSTRAP_ICONS = {
    "globe2" => {
      view_box: "0 0 16 16",
      path: "M0 8a8 8 0 1 1 16 0A8 8 0 0 1 0 8m7.5 6.923V11.5H5.033a12.5 12.5 0 0 0 2.467 3.423m1 0a12.5 12.5 0 0 0 2.467-3.423H8.5zm3.348-4.423a13.1 13.1 0 0 1-1.302 3h2.444A7 7 0 0 0 14.478 10.5zM14.478 9.5a7 7 0 0 0-1.488-3h-2.444a13.1 13.1 0 0 1 1.302 3zM8.5 9.5h2.95a12.5 12.5 0 0 0 0-3H8.5zm-1 0v-3h-2.95a12.5 12.5 0 0 0 0 3zm-3.046 1a13.1 13.1 0 0 0 1.302 3H3.312A7 7 0 0 1 1.522 10.5zM3.312 5.5h2.444a13.1 13.1 0 0 0-1.302-3A7 7 0 0 0 1.522 5.5zm5.188 0h2.467A12.5 12.5 0 0 0 8.5 2.077zm-1 0V2.077A12.5 12.5 0 0 0 5.033 5.5z"
    },
    "diagram-3-fill" => {
      view_box: "0 0 16 16",
      path: "M6 3.5a1.5 1.5 0 1 0-2 1.415v2.17c0 .122.05.24.138.326l1.362 1.362v1.312a1.5 1.5 0 1 0 1 0V8.462a.5.5 0 0 0-.146-.354L5 6.754V4.915A1.5 1.5 0 0 0 6 3.5m5 0a1.5 1.5 0 1 0-2 1.415v1.839L7.646 8.108a.5.5 0 0 0-.146.354v1.623a1.5 1.5 0 1 0 1 0V8.773l1.362-1.362A.46.46 0 0 0 10 7.085v-2.17A1.5 1.5 0 0 0 11 3.5m-8 8a1.5 1.5 0 1 0-2 1.415v.585a1.5 1.5 0 1 0 1 0v-.585A1.5 1.5 0 0 0 3 11.5m10 0a1.5 1.5 0 1 0-2 1.415v.585a1.5 1.5 0 1 0 1 0v-.585A1.5 1.5 0 0 0 13 11.5"
    },
    "signpost-2-fill" => {
      view_box: "0 0 16 16",
      path: "M7 1.414V2h2v-.586a1 1 0 1 0-2 0M7 3h2v4H7zm2 11v-3h1.5a.5.5 0 0 0 .354-.146l2-2A.5.5 0 0 0 12.5 8H9V7h1.5a.5.5 0 0 0 .4-.2l2-2.5A.5.5 0 0 0 12.5 3H9V2H7v12H5.5a.5.5 0 0 0 0 1h5a.5.5 0 0 0 0-1z"
    },
    "building" => {
      view_box: "0 0 16 16",
      path: "M6.5 15V1h3v14zm-1 0V0h5v15h3a.5.5 0 0 1 0 1h-11a.5.5 0 0 1 0-1zm-2-1V4h2v10zm9 0V7h2v7zM4 5h1v1H4zm0 2h1v1H4zm0 2h1v1H4zm0 2h1v1H4zm7-3h1v1h-1zm0 2h1v1h-1zm0 2h1v1h-1zM7 3h1v1H7zm0 2h1v1H7zm0 2h1v1H7zm2-4h1v1H9zm0 2h1v1H9zm0 2h1v1H9z"
    },
    "pin-map-fill" => {
      view_box: "0 0 16 16",
      path: "M3.1.5a.5.5 0 0 0-.5.5v11.79a.5.5 0 0 0 .724.447L6 11.618l3.176 1.589a.5.5 0 0 0 .448 0L13.9 11.118V14.5a.5.5 0 0 0 1 0V1a.5.5 0 0 0-.724-.447L10 2.382 6.824.793a.5.5 0 0 0-.448 0zM10 3.382l3.9-1.95v8.736l-3.9 1.95zM7 4.5a2 2 0 1 1 4 0c0 1.5-2 4-2 4s-2-2.5-2-4"
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
