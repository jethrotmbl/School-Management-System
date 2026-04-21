(function() {
  function cleanupHomeDashboardDrawer($drawer, $subdrawerHost, $menuButton) {
    var existingDrawer = $drawer.data("kendoDrawer");

    if (existingDrawer && typeof existingDrawer.destroy === "function") {
      existingDrawer.destroy();
    }

    $menuButton.off(".homeDrawer");
    $drawer.off(".homeDrawerItem");
    $subdrawerHost.off(".homeDrawerSubdrawer");

    $subdrawerHost
      .removeClass("home-dashboard-subdrawer--open")
      .attr("aria-hidden", "true")
      .css("margin-top", "")
      .empty();

    $drawer
      .removeData("kendoDrawer")
      .attr("class", "home-dashboard-drawer")
      .removeAttr("style")
      .empty();
  }

  function teardownHomeDashboardDrawer() {
    var $drawer = $("#home-dashboard-drawer");
    var $subdrawerHost = $("#home-dashboard-subdrawer");
    var $menuButton = $("#home-dashboard-menu-button");

    if (!$drawer.length || !$subdrawerHost.length || !$menuButton.length) {
      return;
    }

    cleanupHomeDashboardDrawer($drawer, $subdrawerHost, $menuButton);
  }

  function initializeHomeDashboardDrawer() {
    var $drawer = $("#home-dashboard-drawer");
    var $subdrawerHost = $("#home-dashboard-subdrawer");
    var $toolbar = $("#home-dashboard-toolbar");
    var $menuButton = $("#home-dashboard-menu-button");
    var drawer;
    var navigationItems;
    var template;
    var currentKey = $toolbar.data("current-key");
    var currentChildKey = $toolbar.data("current-child-key");
    var activeParentItem = null;

    function escapeHtml(value) {
      return $("<div>").text(value || "").html();
    }

    function buildPromptMessage(label) {
      var actionLabel = (label || "").toString().trim();
      var subject = actionLabel.replace(/^search\s+/i, "").trim();

      if (subject.length > 0) {
        return "Type " + subject + " keyword then press Enter:";
      }

      return "Type your search keyword then press Enter:";
    }

    function buildSubdrawerTemplate(item) {
      var subTemplate = "";

      subTemplate += "<div class='home-dashboard-drawer__subdrawer-panel'>";
      subTemplate += "<button type='button' class='home-dashboard-drawer__subdrawer-back'>";
      subTemplate += "<span class='k-icon k-i-arrow-chevron-left'></span>";
      subTemplate += "<span class='home-dashboard-drawer__subdrawer-back-text'>Back</span>";
      subTemplate += "</button>";
      subTemplate += "<div class='home-dashboard-drawer__subdrawer-title'>" + escapeHtml(item.label) + "</div>";
      subTemplate += "<ul class='home-dashboard-drawer__subdrawer-list'>";

      $.each(item.children || [], function(_, child) {
        var childClasses = "home-dashboard-drawer__subdrawer-item";
        var isSearchChild = /-search$/.test((child.key || "").toString());

        if (child.key === currentChildKey) {
          childClasses += " home-dashboard-drawer__subdrawer-item--active";
        }

        subTemplate +=
          "<li class='" + childClasses + "' data-url='" + child.path + "' data-search-prompt='" + isSearchChild + "' data-search-label='" + escapeHtml(child.label) + "'>" +
            "<span class='home-dashboard-drawer__subdrawer-item-text'>" + escapeHtml(child.label) + "</span>" +
          "</li>";
      });

      subTemplate += "</ul>";
      subTemplate += "</div>";

      return subTemplate;
    }

    function alignSubdrawerToItem($item) {
      var itemTop;

      if (!$item || !$item.length) {
        $subdrawerHost.css("margin-top", "");
        return;
      }

      itemTop = $item.position().top || 0;
      $subdrawerHost.css("margin-top", itemTop + "px");
    }

    function openSubdrawer(item, $item) {
      if (!item || !item.children || !item.children.length) {
        return;
      }

      if (drawer) {
        drawer.show();
      }

      activeParentItem = item;

      $drawer.find("[data-role='drawer-item']").removeClass("home-dashboard-drawer__active");
      $drawer.find("[data-key='" + item.key + "']").addClass("home-dashboard-drawer__active");
      alignSubdrawerToItem($item);

      $subdrawerHost
        .html(buildSubdrawerTemplate(item))
        .addClass("home-dashboard-subdrawer--open")
        .attr("aria-hidden", "false");
    }

    function closeSubdrawer() {
      activeParentItem = null;
      $subdrawerHost
        .removeClass("home-dashboard-subdrawer--open")
        .attr("aria-hidden", "true")
        .css("margin-top", "")
        .empty();
      $drawer.find("[data-role='drawer-item']").removeClass("home-dashboard-drawer__active");
      $drawer.find("[data-key='" + currentKey + "']").addClass("home-dashboard-drawer__active");
    }

    if (!$drawer.length || !$subdrawerHost.length || !$toolbar.length || !$menuButton.length) {
      return;
    }

    // Rebuild from a clean state so Turbolinks restore/back cannot duplicate drawer markup.
    cleanupHomeDashboardDrawer($drawer, $subdrawerHost, $menuButton);

    navigationItems = JSON.parse($toolbar.attr("data-navigation-items") || "[]");

    if (!navigationItems.length) {
      return;
    }

    template = "<ul class='home-dashboard-drawer__nav'>";

    $.each(navigationItems, function(_, item) {
      var hasChildren = item.children && item.children.length;
      var itemClasses = "home-dashboard-drawer__item";
      var isHomeItem = item.key === "home";

      if (item.key === currentKey) {
        itemClasses += " home-dashboard-drawer__active";
      }

      template += "<li>";
      if (isHomeItem) {
        template +=
          "<a data-role='drawer-item' class='" + itemClasses + "'" +
            " data-url='" + item.path + "'" +
            " data-key='" + item.key + "'" +
            " data-has-children='false'" +
            " href='" + item.path + "'>";
      } else {
        template +=
          "<div data-role='drawer-item' class='" + itemClasses + "'" +
            " data-url='" + item.path + "'" +
            " data-key='" + item.key + "'" +
            " data-has-children='" + hasChildren + "'>";
      }
      template +=
        "<span class='k-icon k-i-" + item.icon + "'></span>" +
        "<span class='k-item-text'>" + item.label + "</span>";

      if (hasChildren) {
        template += "<span class='home-dashboard-drawer__caret k-icon k-i-chevron-right'></span>";
      }

      template += isHomeItem ? "</a>" : "</div>";
      template += "</li>";
    });

    template += "</ul>";

    $drawer.kendoDrawer({
      mode: "push",
      mini: {
        width: 70
      },
      position: "left",
      swipeToOpen: true,
      width: 240,
      minHeight: 600,
      template: template
    });

    drawer = $drawer.data("kendoDrawer");

    if (!drawer) {
      return;
    }

    drawer.hide();

    $menuButton.off("click.homeDrawer").on("click.homeDrawer", function() {
      if (drawer.drawerContainer.hasClass("k-drawer-expanded")) {
        closeSubdrawer();
        drawer.hide();
      } else {
        drawer.show();
      }
    });

    $drawer
      .off("click.homeDrawerItem")
      .on("click.homeDrawerItem", "[data-role='drawer-item']", function(event) {
        var $item = $(this);
        var destination = $item.data("url");
        var itemKey = $item.data("key");
        var matchedItem = null;

        $.each(navigationItems, function(_, item) {
          if (item.key === itemKey) {
            matchedItem = item;
            return false;
          }
        });

        if ($item.data("has-children") && matchedItem) {
          if (activeParentItem && activeParentItem.key === matchedItem.key) {
            closeSubdrawer();
          } else {
            openSubdrawer(matchedItem, $item);
          }

          return;
        }

        closeSubdrawer();
        if (!destination) {
          return;
        }

        if (itemKey === "home") {
          event.preventDefault();
          window.location.href = destination;
          return;
        }

        if (destination === window.location.pathname) {
          drawer.hide();
          return;
        }

        window.location.href = destination;
      });

    $subdrawerHost
      .off("click.homeDrawerSubdrawer")
      .on("click.homeDrawerSubdrawer", ".home-dashboard-drawer__subdrawer-back", function() {
        closeSubdrawer();
      })
      .on("click.homeDrawerSubdrawer", ".home-dashboard-drawer__subdrawer-item", function() {
        var $item = $(this);
        var destination = $item.data("url");
        var promptForSearch = $item.data("search-prompt") === true;
        var searchLabel = $item.data("search-label");
        var query;
        var url;

        closeSubdrawer();
        if (drawer) {
          drawer.hide();
        }

        if (!destination) {
          return;
        }

        if (promptForSearch) {
          if (!/\/search(?:\?|$)/.test(destination)) {
            destination = destination.replace(/\/$/, "") + "/search";
          }

          query = window.prompt(buildPromptMessage(searchLabel), "");

          if (query === null) {
            return;
          }

          query = query.toString().trim();
          if (query.length === 0) {
            return;
          }

          url = new URL(destination, window.location.origin);
          url.searchParams.set("q", query);
          destination = url.toString();
        }

        window.location.assign(destination);
      });
  }

  $(document).on("turbolinks:load", initializeHomeDashboardDrawer);
  $(document).on("turbolinks:before-cache", teardownHomeDashboardDrawer);

  window.addEventListener("pageshow", function(event) {
    if (event.persisted) {
      initializeHomeDashboardDrawer();
    }
  });
})();
