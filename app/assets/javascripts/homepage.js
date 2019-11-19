$().ready(function() {

  if ($("body.blacklight-catalog-home").length > 0) {
    var $head = $(".head");
    var classes = $head.attr('class').split(' ');
    var enhancedClass = 'head-enhanced';
    for(var i = 0; i < classes.length; i++) {
      if ( classes[i].indexOf('head-') > -1 ) {
        enhancedClass = classes[i] + '-enhanced';
        break;
      }
    }

    // Rather convoluted, but parses out the first mention of a background
    // image url for the enhanced header, even if the style is not applied.
    var bigSrc = (function() {
      // Find all of the CssRule objects inside the inline stylesheet 
      var stylesheets = document.styleSheets;
      for(var j = 0; j < stylesheets.length; j++) {
        var styles = null;
        try {
          styles = stylesheets[j].rules;
        } catch(e) {
          // NOP
        }
        if ( styles === null ) {
          continue;
        }

        // Fetch the background-image declaration...
        var bgDecl = (function() {
          // ...via a self-executing function, where a loop is run
          var bgStyle, i, l = styles.length;
          for (i = 0; i < l; i++) {
            // ...checking if the rule is the one targeting the
            // enhanced header.
            if (styles[i].selectorText &&
              styles[i].selectorText.indexOf('.' + enhancedClass) > -1) {
              // If so, set bgDecl to the entire background-image
              // value of that rule
              bgStyle = styles[i].style.backgroundImage;
              // ...and break the loop.
              break;
            }
          }
          // ...and return that text.
          return bgStyle;
        }());

        // var styles = document.querySelector('style').sheet.cssRules;
        // Finally, return a match for the URL inside the background-image
        // by using a fancy regex i Googled up, if the bgDecl variable is
        // assigned at all.  
        if ( bgDecl ) {
          return bgDecl && bgDecl.match(/(?:\(['|"]?)(.*?)(?:['|"]?\))/)[1];          
        }

      }
    }());

    // $(".head").addClass("loaded");
    var img = new Image();
    // Assign an onLoad handler to the dummy image *before* assigning the src
    img.onload = function() {
      // header.className += ' ' + enhancedClass;
      $head.addClass(enhancedClass);
    };
    // Finally, trigger the whole preloading chain by giving the dummy
    // image its source.
    if (bigSrc) {
      img.src = bigSrc;
    }
  };

})
