$().ready(function() {
    var do_log = true;

    $("#documents .thumbnail.loading img").on('load', function() {
        var $link = $(this).parents(".thumbnail");
        $link.removeClass("loading");
    })

    $("#documents > div").each(function() {
        var $div = $(this);
        var words = $div.data('words');
        if ( words === undefined || words.length == 0 ) { return ; }

        var $link = $div.find("a.thumbnail");

        var img_width = $link.data('min-width');
        var img_height = $link.data('min-height');

        var padding_left = ( $link.width() - img_width ) / 2;
        var padding_top = 0;

        var identifier = $div.data('identifier');
        var coords_url = '/services/coords/' + identifier;
        $.getJSON(coords_url, function(data) {

            var true_width = data.width;
            var true_height = data.height;
            var hScale = img_width / true_width;
            var vScale = hScale;

            $.each(words, function(idx, word) {
                var coords = data.coords[word]
                if ( coords == null ) {
                    return;
                }

                $.each(coords, function() {
                    var coord = this;
                    var left = coord[0] * hScale + padding_left;
                    var top = coord[1] * vScale + padding_top;
                    var width = coord[2] * hScale;
                    var height = coord[3] * vScale;

                    var unit = 'px';

                    var min = 5;
                    if ( height < min ) { var r = min / height; height = min;  width *= r; }
                    console.log("AHOY", left, "+", width, img_width, "/", left + width > img_width, "/", img_width - left);
                    if ( left + width > img_width ) { 
                        width = img_width - left; 
                        if ( left > ( img_width + padding_left ) ) {
                            left = img_width - padding_left;
                        }
                        if ( width <= min ) {
                            // left = ( img_width - min ) + padding_left;
                            width = min;
                        }
                        console.log("AHOY REDUX", left, width, img_width );
                    }

                    left = ( left / ( img_width + ( padding_left * 2 ) ) ) * 100;
                    top = ( top / ( img_height ) ) * 100;
                    width = ( width / ( img_width + ( padding_left * 2 ) ) ) * 100;
                    height = ( height / img_height ) * 100;
                    unit = '%';

                    var orig_width = width; var orig_height = height;


                    var $span = $('<div class="highlight"></div>').css({ top: top + unit, left: left + unit, width: width + unit, height: height + unit });
                    $span.appendTo($link);
                })

            })

        })
    })
})

