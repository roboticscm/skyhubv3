(function($) {
  var $keyCode = 0;
  // keycode '17' is CONTROL
  $(document).keydown(function(event) {
    if ($keyCode != event.which) {
      $keyCode = event.which;
    } else {
      $keyCode = 0;
    }
  });

  $.fn.RowValue = function(row) {
    return $(this)
      .children('tbody')
      .children('tr')
      .eq(row);
  };

  $.fn.SelectableTable = function(options, callback) {
    var settings = $.extend(
      {
        sort: true,
        status: 'single',
      },
      options,
    );
    return this.each(function() {
      var $row_nums = [];

      let tr = $(this)
        .children('tbody')
        .children('tr');

      tr.unbind();

      tr.click(function() {
        if ($keyCode == 17 || settings.status === 'multiple') {
          $(this).toggleClass('selected');
          var index = parseInt($(this).index());

          var arrIndex = $row_nums.indexOf(index);
          if (arrIndex > -1) {
            $row_nums.splice(arrIndex, 1);
          } else {
            if (index >= 0) $row_nums.push(index);
          }
        } else {
          $(this)
            .addClass('selected')
            .siblings()
            .removeClass('selected');
          var index = parseInt($(this).index());
          $row_nums = [];
          if (index >= 0) $row_nums.push(index);
        }
        if (settings.sort) $row_nums = $row_nums.sort();
        // call back function
        if ($.isFunction(callback)) {
          callback.call(this, { rows: $row_nums });
        } else {
          console.log('Require callback function.');
        }
      });
    });
  };

  $.fn.selectAll = function(isSelectOrUnselectAll, callback) {
    let $row_nums = [];
    let tr = $(this)
      .children('tbody')
      .children('tr');

    if (isSelectOrUnselectAll) {
      tr.addClass('selected');
      tr.each(function(row) {
        if (row > 0) $row_nums.push(row);
      });
    } else {
      tr.removeClass('selected');
      $row_nums = [];
    }
    if ($.isFunction(callback)) {
      callback.call(this, { rows: $row_nums });
    } else {
      console.log('Require callback function.');
    }
  };

  $.fn.toggleSelection = function(callback) {
    let $row_nums = [];
    let tr = $(this)
      .children('tbody')
      .children('tr');

    tr.toggleClass('selected');
    tr.each(function(row) {
      if (row > 0) {
        if ($(this).hasClass('selected')) {
          $row_nums.push(row);
        } else {
          let index = $row_nums.indexOf(row);
          if (index !== -1) $row_nums.splice(index, 1);
        }
      }
    });
    if ($.isFunction(callback)) {
      callback.call(this, { rows: $row_nums });
    } else {
      console.log('Require callback function.');
    }
  };

  $.fn.selectRow = function(row, callback) {
    let $row_nums = [];
    let tr = $(this)
      .children('tbody')
      .children('tr');

    tr.removeClass('selected');
    tr.each(function(r) {
      if (row === r) {
        $(this).addClass('selected');
        $row_nums.push(row);
        return;
      }
    });
    if ($.isFunction(callback)) {
      callback.call(this, { rows: $row_nums });
    } else {
      console.log('Require callback function.');
    }
  };
})(jQuery);
