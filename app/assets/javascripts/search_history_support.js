$().ready(function() {

  var action = location.pathname ? location.pathname.substr(1) : null;
  if ( action == null ) { return ; }
  action = action.split('/').pop();
  if ( action == 'index' || action == 'browse' || action == 'search' ) {
    var query = location.search.substr(1);
    var params = query ? $.deparam(query) : {};
    params.controller = 'catalog';
    params.action = action;
    sessionStorage.setItem('query_params', JSON.stringify(params));
  }

  var set_search_cookie = function() {
    var q = sessionStorage.getItem('query_params');
    if ( q ) {
      Cookies.set('query_params', q, { expires: 1 }); // already JSON
    }    
  }

  // /search and /browse will ignore the cookie, but otherwise
  // your search session works all over the app
  $(window).on('beforeunload', function(e) {
    set_search_cookie();
  })

  // delete the cookie here; for some reason cookie.delete from Rails
  // is not having any effect
  Cookies.remove('query_params');

})