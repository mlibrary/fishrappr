// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// Replaces the magnifying glass in the search button with a rotating wait icon
// See changes in customers.css.scss too, as well as /catalog and /home html.
// $(document).on("click",'button#search',function(){
//   // add validation here
//   // show search in progress
//   $("div.search span#not-searching").addClass("hidden");
//   $("div.search span#now-searching").removeClass("hidden");
//   $("body").css("cursor", "progress");
// });

$( document ).ready(function() {

    // if $('input#q').length > 0 {
        $("div.search span#not-searching").removeClass("hidden");
        $("div.search span#now-searching").addClass("hidden");
        $("body").css("cursor", "auto");
    // }


  // Replaces the magnifying glass in the search button with a rotating wait icon
  // See changes in customers.css.scss too, as well as /catalog and /home html.
  $(document).on("click", 'button#search', function(){

    // add validation here
    var check_start_year = $("input#range_start_year").val();
    var check_end_year = $("input#range_end_year").val();
    var alert_str = ""
    if (
        (check_start_year && (check_start_year.length < 4 || check_start_year.length > 4))
        || (check_end_year && (check_end_year.length < 4 || check_end_year.length > 4))
        ) {
        alert("All years must be entered as four digits or left blank for default search");
        return false;
    }

    // show search in progress
    $("div.search span#not-searching").addClass("hidden");
    $("div.search span#now-searching").removeClass("hidden");
    $("body").css("cursor", "wait");
    set_dates();

    //alert("range start field is: " + $("input#range_start").val() + " and end field is: " + $("input#range_end").val());  

  });

  $(document).on("click", 'button.range-toggle', function(){

    if ($('button.range-toggle').val() == "Show Date Range") {
        $("div.search div.start-year span.hint").html("Start Year")
        $("div.search input#dash").removeClass("hidden");
        $("div.search div.end-year").removeClass("hidden");
        $("div.search div.end-month").removeClass("hidden");
        $("div.search div.end-date").removeClass("hidden");
        $('button.range-toggle span.range-toggle-text').html("Show Specific Date");
        $('button.range-toggle').val("Show Single Date");
        $('button.range-toggle  span.glyphicon-chevron-left').removeClass("hidden");
        $('button.range-toggle  span.glyphicon-chevron-right').addClass("hidden");
    } else {
        $("div.search div.start-year span.hint").html("Specific date")
        $("div.search input#dash").addClass("hidden");
        $("div.search div.end-year").addClass("hidden");
        $("div.search div.end-month").addClass("hidden");
        $("div.search div.end-date").addClass("hidden");
        $('button.range-toggle span.range-toggle-text').html("Show Date Range");
        $('button.range-toggle').val("Show Date Range");
        $('button.range-toggle  span.glyphicon-chevron-right').removeClass("hidden");
        $('button.range-toggle  span.glyphicon-chevron-left').addClass("hidden");
    }
    
  });  

  $("div.search form input, div.search form select").on("change", function(){
    
    set_dates();
    event.preventDefault();

  });


  $("div.search form input, div.search form select").on("load", function(){
    
    set_dates();
    event.preventDefault();

  });

 function set_dates() {
    // set up range start and end fields s=start e=end y=year m=month d=date r=range
    // var sy = $("div#search-navbar input#range_start_year").val();
    var sy = $("input#range_start_year").val();
    sy = !sy ? 1890 : sy;
    
    var sm = $("select#range_start_month").val();
    sm = !sm ? 1 : sm;
    sm = sm > 9 ? sm : "0" + sm; //  add zero padding
    
    var sd = $("select#range_start_date").val();
    sd = !sd ? 1 : sd;
    sd = sd > 9 ? sd : "0" + sd;

    var ey = $("input#range_end_year").val();
    ey = !ey ? 2016 : ey;

    var em = $("select#range_end_month").val();
    em = !em ? 1 : em;
    em = em > 9 ? em : "0" + em;
   
    var ed = $("select#range_end_date").val();
    em = !em ? 1 : em;
    ed = ed > 9 ? ed : "0" + ed;

    var sr = sy + sm + sd;
    var er = ey + em + em;

    // if only one date and it is not empty, set end date to same as start date
    if ( ($('button.range-toggle').val() == "Show Date Range") &&  ($("input#range_start_year").val()) ) {
        er = sr;
    }

    // alert("about to set ranges start and end are " + sr + " and  " + er);

    $("input#range_start").val(sr);
    $("input#range_end").val(er);
  }

});