$().ready(function() {

    if ( ! $("body").is(".blacklight-catalog-show") ) {
        return;
    }

    var $content = $("#content");
    var $map = $("#map");
    var $action = $(".action-toggle-highlight");

    $action.on('click', function(e) {
        e.preventDefault();
        $.post(window.location.pathname + "/toggle_highlight", function(data) {
            toggle_highlighting(data.highlighting);
            toggle_label(data.highlighting);
        })
    })
    
    var toggle_highlighting = function(status) {
        if ( $map.length  ) {
            // dealing with an image
            if ( status ) {
                F.map.addLayer(F.annoFeatures);
            } else {
                F.map.removeLayer(F.annoFeatures);
            }
        } else {
            $content.find("span.highlight").toggleClass("de-highlighted", ! status);
        }
    }

    var toggle_label = function(status) {
        // maybe return label text in toggle response to have access to locales?
        $action.text(status ? "Remove Hit Highlights" : "Show Hit Highlights");
    }

    if ( $map.length == 0 ) {
        // map will take care of initial highlighting
        toggle_highlighting($content.data('highlighting'));        
    }

});