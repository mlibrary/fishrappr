$().ready(function() {
    var do_log = true;
    $("#documents.grid > div").each(function() {
        var $div = $(this);
        var words = $div.data('words');
        if ( words === undefined || words.length == 0 ) { return ; }

        var $img = $div.find("a.thumbnail");

        var padding_top = parseInt($img.css('padding-top'));
        var padding_left = parseInt($img.css('padding-left'));

        var identifier = $div.data('identifier');
        var coords_url = '/services/coords/' + identifier;
        $.getJSON(coords_url, function(data) {

            var true_width = data.width;
            var true_height = data.height;
            var hScale = $img.width() / true_width;
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

                    var orig_width = width; var orig_height = height;

                    var min = 5;
                    if ( height < min ) { var r = min / height; height = min;  width *= r; }
                    if ( left + width > $img.width() ) { width = $img.width() - left; }

                    var $span = $('<div class="highlight"></div>').css({ top: top + 'px', left: left + 'px', width: width + 'px', height: height + 'px' });
                    $span.appendTo($img);
                })

            })

        })
    })
})

