// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// Replaces the magnifying glass in the search button with a rotating wait icon
// See changes in customers.css.scss too, as well as /catalog and /home html.

$( document ).ready(function() {

    $("div.search span#not-searching").removeClass("hidden");
    $("div.search span#now-searching").addClass("hidden");
    $("body").css("cursor", "auto");
    
    set_dates("div.search ");


  $(document).on("click", 'button#search', function(){
    // add validation here

    var check_start_year = $("div.search form input#range_start_year").val();
    var check_end_year = $("div.search form input#range_end_year").val();

    if (
        (check_start_year && (check_start_year.length < 4 || check_start_year.length > 4))
        || (check_end_year && (check_end_year.length < 4 || check_end_year.length > 4))
        ) {
        alert("All years must be entered as four digits or left blank for default search");
        return false;
    }

    // show search in progress
    // Replaces the magnifying glass in the search button with a rotating wait icon
    // See changes in customers.css.scss too, as well as /catalog and /home html.
    $("div.search span#not-searching").addClass("hidden");
    $("div.search span#now-searching").removeClass("hidden");
    $("body").css("cursor", "wait");
    set_dates("div.search "); 

  });

  // facet
  $(document).on("click", "form.range_date_issued_yyyymmdd_ti input.date-range-submit", function(){
    alert("Got a click!");
    // add validation here
    var check_start_year = $("form.range_date_issued_yyyymmdd_ti input#range_start_year").val();
    var check_end_year = $("form.range_date_issued_yyyymmdd_ti input#range_end_year").val();
    if (
        (check_start_year && (check_start_year.length < 4 || check_start_year.length > 4))
        || (check_end_year && (check_end_year.length < 4 || check_end_year.length > 4))
        ) {
        alert("All years must be entered as four digits or left blank for default search");
        return false;
    }

    // show search in progress
    $("body").css("cursor", "wait");
    set_dates("form.range_date_issued_yyyymmdd_ti ");

    // send click event to search button at the top of the page
    $('div.search form button#search').trigger("click");

  });

  // main search, not facet
  $(document).on("click", 'div.search button.range-toggle', function(){

    if ($('button.range-toggle').val() == "Show Date Range") {
        $("div.search div.start-year span.hint").html("Start Year")
        $("div.search input#dash").removeClass("hidden");
        $("div.search div.end-year").removeClass("hidden");
        $("div.search div.end-month").removeClass("hidden");
        $("div.search div.end-date").removeClass("hidden");
        $('div.search button.range-toggle span.range-toggle-text').html("Show Specific Date");
        $('div.search button.range-toggle').val("Show Single Date");
        $('div.search button.range-toggle  span.glyphicon-chevron-left').removeClass("hidden");
        $('div.search button.range-toggle  span.glyphicon-chevron-right').addClass("hidden");
    } else {
        $("div.search div.start-year span.hint").html("Specific date")
        $("div.search input#dash").addClass("hidden");
        $("div.search div.end-year").addClass("hidden");
        $("div.search div.end-month").addClass("hidden");
        $("div.search div.end-date").addClass("hidden");
        $('div.search button.range-toggle span.range-toggle-text').html("Show Date Range");
        $('div.search button.range-toggle').val("Show Date Range");
        $('div.search button.range-toggle  span.glyphicon-chevron-right').removeClass("hidden");
        $('div.search button.range-toggle  span.glyphicon-chevron-left').addClass("hidden");
    }
    
  });  

  $("div.search form input.changeable, div.search form select.changeable").on("change", function(event){

    // alert("id: " + this.id);
    // alert("value: " + this.value);

    if ( this.id  == "range_start_month" ) {
       update_month_dates("div.search form input#range_start_year", "div.search form input#range_start", "div.search form select#range_start_month", "div.search form select#range_start_date");
    }

    if (this.id == "range_end_month") {
        update_month_dates("div.search form input#range_end_year", "div.search form input#range_end", "div.search form select#range_end_month", "div.search form select#range_end_date");
    }

    set_dates("div.search ");
    event.preventDefault();

  });

    // facet
  $(document).on("click", 'form.range_date_issued_yyyymmdd_ti button.range-toggle', function(event){

    if ($('form.range_date_issued_yyyymmdd_ti button.range-toggle').val() == "Show Date Range") {
        $("form.range_date_issued_yyyymmdd_ti div.start-year span.hint").html("Start Year")
        $("form.range_date_issued_yyyymmdd_ti input#dash").removeClass("hidden");
        $("form.range_date_issued_yyyymmdd_ti div.end-year").removeClass("hidden");
        $("form.range_date_issued_yyyymmdd_ti div.end-month").removeClass("hidden");
        $("form.range_date_issued_yyyymmdd_ti div.end-date").removeClass("hidden");
        $('form.range_date_issued_yyyymmdd_ti button.range-toggle span.range-toggle-text').html("Show Specific Date");
        $('form.range_date_issued_yyyymmdd_ti button.range-toggle').val("Show Single Date");
        $('form.range_date_issued_yyyymmdd_ti button.range-toggle  span.glyphicon-chevron-left').removeClass("hidden");
        $('form.range_date_issued_yyyymmdd_ti button.range-toggle  span.glyphicon-chevron-right').addClass("hidden");
    } else {
        $("form.range_date_issued_yyyymmdd_ti  div.start-year span.hint").html("Specific date")
        $("form.range_date_issued_yyyymmdd_ti  input#dash").addClass("hidden");
        $("form.range_date_issued_yyyymmdd_ti  div.end-year").addClass("hidden");
        $("form.range_date_issued_yyyymmdd_ti  div.end-month").addClass("hidden");
        $("form.range_date_issued_yyyymmdd_ti  div.end-date").addClass("hidden");
        $('form.range_date_issued_yyyymmdd_ti button.range-toggle span.range-toggle-text').html("Show Date Range");
        $('form.range_date_issued_yyyymmdd_ti button.range-toggle').val("Show Date Range");
        $('form.range_date_issued_yyyymmdd_ti button.range-toggle  span.glyphicon-chevron-right').removeClass("hidden");
        $('form.range_date_issued_yyyymmdd_ti button.range-toggle  span.glyphicon-chevron-left').addClass("hidden");
    }

    event.preventDefault();
    
  }); 


  $("form.range_date_issued_yyyymmdd_ti input, form.range_date_issued_yyyymmdd_ti select").on("change", function(event){

    // Note that these get the backup year values from the div.search

    // alert("id: " + this.id)

    if ( this.id  == "range_start_month" ) {
       update_month_dates("form.range_date_issued_yyyymmdd_ti input#range_start_year", "div.search form input#range_start", "form.range_date_issued_yyyymmdd_ti select#range_start_month", "form.range_date_issued_yyyymmdd_ti select#range_start_date");
    }

    if (this.id == "range_end_month") {
        update_month_dates("form.range_date_issued_yyyymmdd_ti input#range_end_year", "div.search form input#range_end", "form.range_date_issued_yyyymmdd_ti select#range_end_month", "form.range_date_issued_yyyymmdd_ti select#range_end_date");
    }

    set_dates("form.range_date_issued_yyyymmdd_ti ");
    event.preventDefault();

  });

 function set_dates(parent) {
    // set up range start and end fields s=start e=end y=year m=month d=date r=range
    // alert("Setting dates for parent: " + parent);

    var sy = $(parent + "input#range_start_year").val();
    sy = !sy ? 1890 : sy;
    
    var sm = $(parent + "select#range_start_month").val();
    sm = !sm ? 1 : sm;
    sm = sm > 9 ? sm : "0" + sm; //  add zero padding
    
    var sd = $(parent + "select#range_start_date").val();
    sd = !sd ? 1 : sd;
    sd = sd > 9 ? sd : "0" + sd;

    var ey = $(parent + "input#range_end_year").val();
    ey = !ey ? 2016 : ey;

    var em = $(parent + "select#range_end_month").val();
    em = !em ? 1 : em;
    em = em > 9 ? em : "0" + em;
   
    var ed = $(parent + "select#range_end_date").val();
    em = !em ? 1 : em;
    ed = ed > 9 ? ed : "0" + ed;

    var sr = sy + sm + sd;
    var er = ey + em + em;

    // if only one date and it is not empty, set end date to same as start date
    if ( ($(parent + 'button.range-toggle').val() == "Show Date Range") &&  ($(parent + "input#range_start_year").val()) ) {
        er = sr;
    }

    // alert("about to set ranges start and end are " + sr + " and  " + er);

    $("div.search input#range_start").val(sr);
    $("div.search input#range_end").val(er);
    $("div.search  input[name='range_start']").val(sr);
    $("div.search  input[name='range_end']").val(er);
    $("form.range_date_issued_yyyymmdd_ti input[name='range_start']").val(sr);
    $("form.range_date_issued_yyyymmdd_ti input[name='range_end']").val(er);
    // $("input[name='range_date_issued_yyyymmdd_ti][begin]'").val(sr);
    // $("input[name='range_date_issued_yyyymmdd_ti][end]'").val(er);
  }

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

    function update_month_dates(year_el, year_backup_el, month_el, date_el) {
        // get currently selected date, if there is one
        var new_selected = was_selected = $(date_el + ' option:selected').val();
        if (empty(new_selected)) { new_selected = was_selected = 1 }

        // alert("new_selected: " + new_selected);

        // get year to check for leap year
        var check_start_year = $(year_el).val();
        if (empty(check_start_year)) {
            year = $(year_backup_el).val().trim();
            year = year.substring(0,4);
        } else {
            year = check_start_year
        }

        // alert("year: " + year);

        // get number of dates to display in this month
        var date_count = month_dates(year, $(month_el).val());

        // alert("date_count: " + date_count);


        if (was_selected > date_count) {
            alert("You had a previously selected date greater than a date available in your new month");
            new_selected = date_count;
        }

        // alert("new_selected: " + new_selected);
        
        // clear then set dates for this month
        var optionsAsString = "";
        for( var i = 1; i <= date_count; i++) {
            optionsAsString += "<option value='" + i + "'>" + i + "</option>";
        }

        // alert("optionsAsString: " + optionsAsString);

        // alert("date_el: " + date_el);


        $(date_el).find('option').remove().end().append($(optionsAsString));

        // set or reset the selected value
        $(date_el + " option:selected").prop("selected",false);
        $(date_el + " option[value=" + new_selected + "]").prop("selected",true);
    }

});