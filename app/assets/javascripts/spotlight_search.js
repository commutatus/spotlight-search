var current_request, get_paginated_list;

current_request = null;

get_paginated_list = function(page, thisObj) {
  var filter_params, query_string, sort_column, sort_direction, success_replace_class, url;
  url = $('.filters').data('filter-url');
  success_replace_class = $('.filters').data('replacement-class');
  if (typeof page === void 0) {
    page = 1;
  }
  if (thisObj.data('behaviour') === "sort") {
    sort_column = thisObj.data('sort-column');
    sort_direction = thisObj.data('sort-direction');
  } else {
    sort_column = $('[data-behaviour="current-page"]').data('sort-column');
    sort_direction = $('[data-behaviour="current-page"]').data('sort-direction');
  }
  filter_params = {};
  $('[data-behaviour="filter"]').each(function(index) {
    filter_params[$(this).data('scope')] = $(this).val();
  });
  query_string = {
    filters: filter_params,
    page: page,
    sort: {
      sort_column: sort_column,
      sort_direction: sort_direction
    }
  };
  return current_request = $.ajax(url, {
    type: 'GET',
    data: query_string,
    beforeSend: function() {
      if (current_request !== null) {
        current_request.abort();
      }
    },
    success: function(data) {
      var q;
      q = jQuery.param(query_string);
      window.history.pushState("", "", url + "?" + q);
      return $('.' + success_replace_class).html(data);
    },
    error: function(jqxhr, textStatus, errorThrown) {
      alert(errorThrown);
      return $.jGrowl("Whoops! There was an error processing your request. Please contact support!")({
        life: 2000
      });
    }
  });
};

$(document).on('click', '[data-behaviour="next-page"]', function() {
  var current_page, thisObj;
  thisObj = $(this);
  current_page = parseInt($('[data-behaviour="current-page"]').data('page'));
  return $(function() {
    return get_paginated_list(current_page + 1, thisObj);
  });
});

$(document).on('click', '[data-behaviour="previous-page"]', function() {
  var current_page, thisObj;
  thisObj = $(this);
  current_page = parseInt($('[data-behaviour="current-page"]').data('page'));
  return $(function() {
    return get_paginated_list(current_page - 1, thisObj);
  });
});

$(document).on('keyup', '[data-type="input-filter"]', function() {
  var thisObj;
  thisObj = $(this);
  return $(function() {
    return get_paginated_list(1, thisObj);
  });
});

$(document).on('change', '[data-type="select-filter"]', function() {
  var thisObj;
  thisObj = $(this);
  return $(function() {
    return get_paginated_list(1, thisObj);
  });
});

$(document).on('click', '[data-type="anchor-filter"]', function() {
  var thisObj;
  thisObj = $(this);
  return $(function() {
    return get_paginated_list(1, thisObj);
  });
});

$(document).on('click', '#export-to-file-btn', function(event) {
  event.preventDefault();
  $(this).attr('disabled', true);
  var filter_params, query_string, sort_column, sort_direction;
  sort_column = $('[data-behaviour="current-page"]').data('sort-column');
  sort_direction = $('[data-behaviour="current-page"]').data('sort-direction');
  filter_params = {};
  $('[data-behaviour="filter"]').each(function(index) {
    filter_params[$(this).data('scope')] = $(this).val();
  });
  body = {
    filters: filter_params,
    sort: {
      sort_column: sort_column,
      sort_direction: sort_direction
    }
  }
  $('#export-to-file-filters').value(body);
  $('#export-to-file-form').submit();
});
