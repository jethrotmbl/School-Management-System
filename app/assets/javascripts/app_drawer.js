(function() {
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

        if (child.key === currentChildKey) {
          childClasses += " home-dashboard-drawer__subdrawer-item--active";
        }

        subTemplate +=
          "<li class='" + childClasses + "' data-url='" + child.path + "'>" +
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

    if ($drawer.data("kendoDrawer")) {
      return;
    }

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
        var destination = $(this).data("url");

        closeSubdrawer();
        if (drawer) {
          drawer.hide();
        }

        if (!destination) {
          return;
        }

        window.location.assign(destination);
      });
  }

  $(document).on("turbolinks:load", initializeHomeDashboardDrawer);
})();
