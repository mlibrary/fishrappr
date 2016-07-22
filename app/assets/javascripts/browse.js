// browse page js
$( document ).ready(function() {
    // trigger a change on select in the browse page
    if (("body.blacklight-catalog-browse").length > 0) {
     $("body.blacklight-catalog-browse form select.browse-decade").trigger("change");
    }


    $("body.blacklight-catalog-browse form select#browse-decade").on("click", function(event) {

        // alert("id: " + this.id);
        // alert("value: " + this.value);

        if ( this.id  == "browse-decade" ) {
           update_browse_years("body.blacklight-catalog-browse form select#browse-decade", "body.blacklight-catalog-browse form select#browse-year");
        }

        event.preventDefault();

        });

        $("body.blacklight-catalog-browse form select.changeable").on("change", function(event) {

        // alert("id: " + this.id);
        // alert("value: " + this.value);

        // Update div.issues-display h3 to reflect year and month
        // var y = $('body.blacklight-catalog-browse form select#browse-year').val();
        // var m = $('body.blacklight-catalog-browse form select#browse-month').val();
        // var m $.trim($("select#browse-month").children("option:selected").text()) 
        var d = $.trim($("select#browse-decade").children("option:selected").text()) 
        var y = $.trim($("select#browse-year").children("option:selected").text()) 
        var m = $.trim($("select#browse-month").children("option:selected").text()) 

        if (d != "Any Decade") {
            d = "in the " + d + "s"
        }

         if (y != "Any Year") {
            d = ""
        }

        $('body.blacklight-catalog-browse div.issues-display h3').html(m + " in  " + y + " " + d);

        event.preventDefault();

    });


    function update_browse_years(decade_el, year_el) {

        // get decade start year from decade select
        var start_year = $(decade_el).val();

        // alert("decade value is: " + $(decade_el).val());

        // alert("start year: " + start_year);

        
        // clear then set dates for this month
        var optionsAsString = "";
        optionsAsString += "<option value='" + "1" + "'>" + "Any Year" + "</option>";

        for( var i = 0; i < 11; i++) {
            new_val = parseInt(start_year) + i
            optionsAsString += "<option value='" + new_val + "'>" + new_val + "</option>";
        }

        // alert("optionsAsString: " + optionsAsString);


        $(year_el).find('option').remove().end().append($(optionsAsString));

        // set or reset the selected value
        $(year_el + " option:selected").prop("selected",false);
        $(year_el + " option[value=" + 0 + "]").prop("selected",true);
    }

})

