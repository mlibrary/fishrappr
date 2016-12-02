// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// Replaces the magnifying glass in the search button with a rotating wait icon
// See changes in customers.css.scss too, as well as /catalog and /home html.

$( document ).ready(function() {

  // Browse box
  if ($("body.blacklight-catalog-browse").length > 0) {

     $("select#date_issued_mm_ti").on('change', function() {
      var $this = $(this);
      update_month_dates($this, $("select#date_issued_dd_ti"), $("select#date_issued_yyyy_ti"));
    });

  }

  function setup_date_filters($select) {
    var option = $select.val();
    var $form = $select.parents("form");
    $form.find(".date-option").hide().css("width: 0;");
    $form.find(".date-option-" + option).show();
  }


  $("body").css("cursor", "auto");
    
  // if we are on a help page (include the contacts page) mark the link for that page in the sidebar
  $('ul.help-ul li.current a').addClass('currentlyActive');

  // Back to top window scroll for catalog index page
  var back_to_top_margin = 250;
  if (true || ("body.blacklight-catalog-index, body.blacklight-catalog-show").length > 0) {
      $(window).scroll(function () {
          if ($(this).scrollTop() > back_to_top_margin) {
              $('#back-to-top').fadeIn();
          } else {
              $('#back-to-top').fadeOut();
          }
      });
      // scroll body to 0px on click
      $('#back-to-top').click(function () {
          // $('#back-to-top').tooltip('hide');
          $('body,html').animate({
              scrollTop: 0
          }, 800);
          return false;
      });
      
      // $('#back-to-top').tooltip('show');
  }

  $("select[name=date_filter]").on('change', function() {
    setup_date_filters($(this));
  })

  var $form = $(".site-search-form");
  if ( $form.size ) {
    setup_date_filters($form.find("select[name=date_filter]"));
  }

  $(".site-search-form").on('submit', function() {
    var $form = $(this);
    var $button = $form.find("button[type=submit]");

    var check_start_year = $form.find("input[name=date_issued_begin_yyyy]").val();
    var check_end_year = $form.find("input[name=date_issued_end_yyyy]").val();
    var filter = $form.find("select[name=date_filter]").val();
    if ( filter != 'any' ) {
        if ( check_start_year && ! check_start_year.match(/^\d{4}$/) ) {
            alert("Please enter the year as four digits.");
            return false;
        }
    }

    if ( filter == 'between' ) {
        if ( check_end_year && ! check_end_year.match(/^\d{4}$/) ) {
            alert("Please enter the year as four digits.");
            return false;
        }
    }

    $button.find(".icon_16px").toggleClass('hidden');
    $("body").css("cursor", "wait");

    return true;

  })

  $("select.date_filter_control_mm").on('change', function() {
    var $this = $(this);
    update_month_dates($this, $this.next(".date_filter_control_dd"), $this.nextAll(".date_issued_yyyy"))
  })


  // assumes y is four digits
  function leap_year(y) {
    return !(y % 4) && (y % 100) || !(y % 400);
  }

  function month_dates(year, month) {
    var leap = leap_year(year)
    if (month == 2) {
        if (leap){
            return 29;
        } else {
            return 28;
        }
    }

    if (
            month == 4 ||
            month == 6 ||
            month == 9 ||
            month == 11
        ) {
        return 30;
    }

    return 31;

  }

  function empty(data) {
      if(typeof(data) == 'number' || typeof(data) == 'boolean')
      { 
        return false; 
      }
      if(typeof(data) == 'undefined' || data === null)
      {
        return true; 
      }
      if(typeof(data.length) != 'undefined')
      {
        return data.length == 0;
      }
      var count = 0;
      for(var i in data)
      {
        if(data.hasOwnProperty(i))
        {
          count ++;
        }
      }
      return count == 0;
    }

    function update_month_dates($mm_el, $dd_el, $yyyy_el) {
      var mm = $mm_el.val();
      var dd = $dd_el.val();
      var check_year = $yyyy_el.val().trim() || ( ( new Date() ).getYear() + 1900 )
      var dd_count = month_dates(check_year, mm);

      var last_dd = parseInt($dd_el.find("option:last").val(), 10);
      if ( dd_count > last_dd ) {
        // add to the options
        for(var dd = last_dd + 1; dd <= dd_count; dd++) {
          var $option = $("<option>" + dd + "</option>");
          $option.val(dd);
          $dd_el.append($option);
        }
      } else {
        // remove options
        while ( last_dd > dd_count ) {
          $dd_el.find("option:last").remove();
          last_dd = parseInt($dd_el.find("option:last").val(), 10);
        }
      }
    }


});