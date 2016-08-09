$( document ).ready(function() {

 // Graph box
 // Adapted from: 
  if ($("div#searchGraph").length > 0) {
    var chartMAX = 11e22221220;
    var chartMIN = 0;
    var chart_title = $("#graph_data").data("chart-title");
    var highest_col = $("#graph_data").data("highest-col");
    var lowest_col = $("#graph_data").data("lowest-col");
    var facet_key = $("#graph_data").data("facet-key");
    // alert("chart_title =" + chart_title);       
    // alert("highest_col =" + highest_col);       
    // alert("lowest_col =" + lowest_col);       
    // alert("facet_key =" + facet_key);       

    var col_values = new Array();
    col_values = $("#graph_data").data("col-values").split(",");
    var col_names = new Array();
    col_names = $("#graph_data").data("col-names").split(",");
    var col_links = new Array();
    col_links = $("#graph_data").data("col-links").split(",");

    // alert("col values are =" + col_values);       
    // alert("col names are =" + col_names);       
    // alert("col_links =" + col_links);       

    // col_names adjustments for readability
    // substitute month abbreviation for month number 
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    if (chart_title.includes("Months")) {
      for (i = 0; i < col_names.length; i++) {
        col_names[i] = months[i];
     }
    }

    // append "s" to decade numbers
    if (chart_title.includes("Decades")) {
      for (i = 0; i < col_names.length; i++) {
        col_names[i] = col_names[i] + "s";
     }
    }

    // // split link string into array
    // col_links = col_links_str.split(",")
    // alert("col_links after split =" + col_links);       


    var chartLineBase = chartMAX / highest_col
    var chartLinePxLength = chartLineBase * lowest_col +"px"
    chartLinePxLength = chartLineBase * lowest_col +"px"
    // alert("chartLineBase: " + chartLineBase);
    // alert("i: " + i + " col_values[i] is: " + col_values[i] + " col_names[i] is: " + col_names[i]);

    $.each( col_values, function( i, val ) {
        var chartLineBase = chartMAX / highest_col;
        var chartLinePxLength = parseInt(chartLineBase * val) +"px";
        console.log("chartLinePxLength: " + chartLinePxLength);
        
        // default to linked graph bar and solid color bar style
        var day_class = 'day';
        var col_name = col_name = $('<a href="' + col_links[i] + '"><span class="col_names" tabindex="0">' + col_names[i] + '<span class="sr-only"> has ' + val + ' pages matching search</span></span></a>');

        if (val == 0) {
          // light gray bar
          day_class = 'day0';
        } 

        if (col_links[i].includes("#")) {
          // no link on bar
          col_name = $('<span class="col_names" tabindex="0">' + col_names[i] + '<span class="sr-only"> has ' + val + ' pages matching search</span></span>');
        } 

          var day = $('<div />', {
            'class': day_class,
            id     : i,
            'data-value' : col_names[i] +  ' has '  + val + ' pages matching search',
            css    : {width : chartLinePxLength},
            on     : {
              mouseenter: function(e) {
                console.log($(this).data('value'))
                $('<div />', {
                    'class' : 'tip',
                    text : $(this).data('value'),
                    css : {
                        position: 'fixed',
                        top: e.pageY-28,
                        left: e.pageX+5
                    }
                }).appendTo(this);
              },
              mouseleave: function() {
                $('.tip', this).remove();
              },
              mousemove: function(e) {
                $('.tip', this).css({
                    top: e.clientY-28,
                    left: e.clientX+5
              });
            }
          }
        }).append(col_name)

      $("#hit_chart_frame").append(day);
    });
  }
});