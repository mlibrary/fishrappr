// ga_tracking.js

$().ready(function() {

    $("a[data-track]").on('click', function(e) {
        var $this = $(this);
        var options = {};
        options.location = $this.attr('href');
        options.title =  $('title').text() + " - " + $this.text() ;
        ga('send', 'pageview', options);
    });

});