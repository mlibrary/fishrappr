$().ready(function() {

  if ( $("body").is(".blacklight-catalog-index") || $("body").is(".blacklight-catalog-browse") ) {
    var query = location.search.substr(1);
    if ( query ) {
      var params = $.deparam(query)
      params.controller = 'catalog';
      params.action = location.pathname.substr(1);
      sessionStorage.setItem('query_params', JSON.stringify(params));
    }
  }

  $("body").on('click', 'a[href^="/midaily"]', function() {
    var q = sessionStorage.getItem('query_params');
    if ( q ) {
      Cookies.set('query_params', q, { expires: 1 }); // already JSON
    }
  })

  // delete the cookie here; for some reason cookie.delete from Rails
  // is not having any effect
  Cookies.remove('query_params');

})