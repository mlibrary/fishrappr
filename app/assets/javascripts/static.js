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

    set_dates();
    event.preventDefault();

  // Replaces the magnifying glass in the search button with a rotating wait icon
  // See changes in customers.css.scss too, as well as /catalog and /home html.
  $(document).on("click",'button#search',function(){
    // add validation here
    // show search in progress
    $("div.search span#not-searching").addClass("hidden");
    $("div.search span#now-searching").removeClass("hidden");
    $("body").css("cursor", "progress");

    set_dates();

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

    // alert("about to set ranges start and end are " + sr + " and  " + er);

    $("input#range_start").val(sr);
    $("input#range_end").val(er);

    // alert("range start field is: " + $("input#range_start").val());  

  }

});