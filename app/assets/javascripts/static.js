// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// Replaces the magnifying glass in the search button with a rotating wait icon
// See changes in customers.css.scss too, as well as /catalog and /home html.
$(document).on("click",'button#search',function(){
  $("div.search span#not-searching").addClass("hidden");
  $("div.search span#now-searching").removeClass("hidden");
  $("body").css("cursor", "progress");
});
