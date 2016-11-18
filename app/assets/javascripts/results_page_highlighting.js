$().ready(function() {
    var do_log = true;

    $("#documents .thumbnail.loading img").on('load', function() {
        load_highlights($(this));
    })

    var lpad = function(str, length) {
        var padString = '0';
        while (str.length != length)
            str = padString + str;
        return str;
    };

    var load_highlights = function($img) {

        var $link = $img.parents(".thumbnail");
        $link.removeClass("loading");

        var $div = $link.parents(".document");
        var words = $div.data('words');
        if ( words === undefined || words.length == 0 ) { return ; }

        var img_width = $img.width();
        var img_height = $img.height();

        var padding_left = ( $link.width() - img_width ) / 2;
        // var padding_left = parseInt($link.css('padding-left'));
        var padding_top = 0;

        var identifier = $div.data('identifier');

        // var ___debug = function() {
        //     if ( identifier == 'bhl_midaily:mdp.39015071754738-00000808:WORDS00000808' ) {
        //         console.log.apply(console, arguments);
        //     }
        // }

        var debugging = false; // ( identifier == 'bhl_midaily:mdp.39015071754159-00000114:WORDS00000114' );
        var message = [];

        var service_url = $("link[rel='repository']").attr("href");
        var coords_url = service_url + 'file/' + identifier;
        $.getJSON(coords_url, function(data) {

            var true_width = data.page.width;
            var true_height = data.page.height;

            var scale;
            if ( img_width > img_height ) {
                scale = img_height / true_height;
            } else {
                scale = img_width / true_width;
            }
            var hScale = scale; var vScale = scale;

            $.each(words, function(idx, word) {
                var coords = data.words[word]
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
                    var check_width = img_width + ( padding_left * 2 ) - ( min * 2 );
                    if ( height < min ) { var r = min / height; height = min;  width *= r; }
                    if ( debugging ) { message = [ "AHOY", left, "+", width, check_width, "/", left + width > check_width, "/", img_width - left ] };
                    if ( left + width > check_width ) { 
                        width = img_width - left - ( min * 2 ); 
                        if ( left > ( img_width + padding_left ) ) {
                            left = img_width - padding_left;
                        }
                        if ( width <= min ) {
                            // left = ( img_width - min ) + padding_left;
                            width = min;
                        }
                        // console.log("AHOY REDUX", left, width, img_width );
                    }

                    var original_top = top; var original_left = left;

                    left = ( left / ( img_width + ( padding_left * 2 ) ) ) * 100;
                    top = ( top / ( img_height ) ) * 100;
                    width = ( width / ( img_width + ( padding_left * 2 ) ) ) * 100;
                    height = ( height / img_height ) * 100;
                    unit = '%';

                    var $span = $('<div class="highlight"></div>').css({ top: top + unit, left: left + unit, width: width + unit, height: height + unit });
                    $span.appendTo($link);
                    if ( debugging && message.length > 0 ) { message.push($span); console.log.apply(console, message); message = []; }
                })

            })

        })
    };
})

