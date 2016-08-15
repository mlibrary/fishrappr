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

        var $img = $div.find("a.thumbnail");

        var padding_top = parseInt($img.css('padding-top'));
        var padding_left = parseInt($img.css('padding-left'));

        var identifier = $div.data('identifier');
        var coords_url = '/services/coords/' + identifier;
        $.getJSON(coords_url, function(data) {

            var img_width = $img.data('min-width'); // $img.width();
            var img_height = $img.data('min-height'); // $img.height();

            var true_width = data.width;
            var true_height = data.height;
            var hScale = img_width / true_width;
            var vScale = hScale;

            // and then remote the min-width
            // $img.css({ 'min-width': 0, 'min-height': 0});

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
                    if ( left + width > img_width ) { width = img_width - left; }

                    left = ( left / ( img_width + padding_left ) ) * 100;
                    top = ( top / ( img_height + padding_top ) ) * 100;
                    width = ( width / img_width ) * 100;
                    height = ( height / img_height ) * 100;
                    unit = '%';

                    var orig_width = width; var orig_height = height;


                    var $span = $('<div class="highlight"></div>').css({ top: top + unit, left: left + unit, width: width + unit, height: height + unit });
                    $span.appendTo($img);
                })

            })

        })
    })
})

