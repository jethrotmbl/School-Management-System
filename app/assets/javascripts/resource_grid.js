(function() {
  function buildFieldName(title, index, usedFields) {
    var candidate = $.trim(title).replace(/[^A-Za-z0-9_$]/g, "");

    if (!candidate.length) {
      candidate = "Column" + index;
    }

    if (!/^[A-Za-z_$]/.test(candidate)) {
      candidate = "Column" + index;
    }

    while (usedFields[candidate]) {
      candidate += index;
    }

    usedFields[candidate] = true;
    return candidate;
  }

  function buildGridConfiguration($table) {
    var columns = [];
    var data = [];
    var usedFields = {};
    var fieldNames = [];

    $table.find("thead th").each(function(index) {
      var $header = $(this);
      var className = $header.attr("class") || "";
      var isActionsColumn = $header.hasClass("actions-col");
      var title = $.trim($header.text());
      var fieldName = buildFieldName(title, index, usedFields);
      var htmlFieldName = fieldName + "_html";

      columns.push({
        field: fieldName,
        title: title,
        encoded: false,
        template: "#= " + htmlFieldName + " #",
        attributes: {
          "class": className
        },
        headerAttributes: {
          "class": className
        },
        groupable: !isActionsColumn,
        reorderable: !isActionsColumn,
        sortable: !isActionsColumn
      });

      fieldNames.push(fieldName);
    });

    $table.find("tbody tr").each(function() {
      var $row = $(this);

      // Ignore Kendo-generated helper/group rows when rebuilding from cached pages.
      if ($row.hasClass("k-grouping-row") || $row.hasClass("k-group-footer") || $row.hasClass("k-detail-row")) {
        return;
      }

      var row = {};

      $row.find("td").each(function(index) {
        var fieldName = fieldNames[index];

        if (!fieldName) {
          return;
        }

        row[fieldName] = $.trim($(this).text());
        row[fieldName + "_html"] = $(this).html();
      });

      data.push(row);
    });

    return {
      columns: columns,
      data: data
    };
  }

  function initializeResourceGrids() {
    $(".js-resource-grid").each(function() {
      var $table = $(this);
      var config;

      if ($table.attr("data-resource-grid-enhanced") === "true") {
        return;
      }

      if ($table.data("kendoGrid")) {
        $table.attr("data-resource-grid-enhanced", "true");
        return;
      }

      config = buildGridConfiguration($table);

      $table.kendoGrid({
        mobile: true,
        dataSource: {
          data: config.data
        },
        columns: config.columns,
        groupable: {
          messages: {
            empty: ""
          }
        },
        sortable: true,
        resizable: true,
        reorderable: true,
        scrollable: false,
        columnMenu: false,
        noRecords: {
          template: "No records found."
        }
      });

      $table.attr("data-resource-grid-enhanced", "true");
    });
  }

  $(document).on("turbolinks:load", initializeResourceGrids);
})();
