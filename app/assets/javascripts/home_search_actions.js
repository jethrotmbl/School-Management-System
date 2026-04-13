(function($) {
  function buildPromptMessage(label) {
    var actionLabel = (label || "").toString().trim();
    var subject = actionLabel.replace(/^search\s+/i, "").trim();

    if (subject.length > 0) {
      return "Type " + subject + " keyword then press Enter:";
    }

    return "Type your search keyword then press Enter:";
  }

  function shouldIgnoreClick(event) {
    return event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey;
  }

  function initializeHomeSearchActions() {
    $(document)
      .off("click.homeSearchActions", ".resource-card__action[data-search-prompt='true']")
      .on("click.homeSearchActions", ".resource-card__action[data-search-prompt='true']", function(event) {
        if (shouldIgnoreClick(event)) {
          return;
        }

        event.preventDefault();

        var targetPath = $(this).attr("href");
        if (!targetPath) {
          return;
        }

        var searchLabel = $(this).data("searchLabel");
        var query = window.prompt(buildPromptMessage(searchLabel), "");

        if (query === null) {
          return;
        }

        query = query.trim();
        if (query.length === 0) {
          return;
        }

        var url = new URL(targetPath, window.location.origin);
        url.searchParams.set("q", query);
        window.location.assign(url.toString());
      });
  }

  $(document).on("turbolinks:load", initializeHomeSearchActions);
})(jQuery);
