$().ready(function() {

    if ( ! $("body").is(".blacklight-catalog-show") ) {
        return;
    }

    var $content = $("[data-highlighting]");
    var $text = $(".document");
    var $map = $("#image-viewer");
    var $action = $(".action-toggle-highlight");

    $action.on('click', function(e) {
        e.preventDefault();
        $.post(window.location.pathname + "/toggle_highlight", function(data) {
            toggle_highlighting(data.highlighting);
            toggle_label(data.highlighting);
        })
    })
    
    var toggle_highlighting = function(status) {
        $("body").toggleClass('activate-highlighting', status);
    }

    var toggle_label = function(status) {
        // maybe return label text in toggle response to have access to locales?
        // $action.text(status ? "Remove Hit Highlights" : "Show Hit Highlights");
        $action.prop("checked", status);
    }

    toggle_highlighting($content.data('highlighting'));    

});