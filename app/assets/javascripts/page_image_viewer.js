  $().ready(function() {
      
    if ( ! $("body").is(".blacklight-catalog-show") ) {
      return;
    }

    window.F = window.F || {};
    var $map = $("#image-viewer");

    var words = $map.data('words');
    // words = [ 'design', 'wrinkle', 'clever' ];
    var identifier = $map.data('identifier');
    var image_base;

    var page;

    if ( identifier.indexOf('fake.') > -1 ) {
      return;
    }

    var addHighlightOverlay = function(viewer) {
      if ( words.length == 0 ) {
        return;
      }

      var dimensions = viewer.source.dimensions;
      console.log(viewer.source);
      console.log(dimensions);
      var scale = 1 / dimensions.x;
      var placement = OpenSeadragon.OverlayPlacement.BOTTOM;

      var highlightColor;
      // find the text layer. How, exactly?
      var coordinates_url;
      $.each(page.otherContent, function(index, data) {
        if ( data['@id'].indexOf('/contentAsText/') > -1 ) {
          coordinates_url = data['@id'];
        }
      })

      $.getJSON(coordinates_url, function(annoData) {

        $.each(annoData.resources, function(i, value) {
          var content = value.resource.chars;
          var possibles = [ content ];
          var hash_match = false;
          if ( typeof(content) == 'string' && content.indexOf("-") >= 0 ) {
            var tmp = content.split("-");
            possibles.push(tmp[0]);
          }

          // if ( words.indexOf(content) < 0 ) { return ; }

          var did_match = false;
          for(var i = 0; i < possibles.length; i++) {
            if ( words.indexOf(possibles[i]) >= 0 ) {
              did_match = true;
              break;
            }
          }

          if ( ! did_match ) { return ; }

          var b = /xywh=(.*)/.exec(value.on)[1].split(',');

          var h = parseFloat(b[3]) * 1.5;  // w
          var w = parseFloat(b[2]) * 1.10; // h

          var dw = ( w - parseFloat(b[2]) ) / 2;
          var dh = ( h - parseFloat(b[3]) ) / 2;

          var x1 = parseFloat(b[0] - dw),
              y1 = parseFloat(b[1] - dh);

          var rect = new OpenSeadragon.Rect(x1 * scale, y1 * scale, ( w + dw ) * scale, ( h + dh ) * scale);
          var div = document.createElement("div");
          div.className = "highlight";
          viewer.addOverlay(div, rect);

        });
        if ( $map.data('highlighting') ) {
          // annoFeatures.addTo(map);
        }
      })
    }

    var viewer; var selection; var mode;

    var i = 1;
    var manifest_url = $("link[rel='manifest']").attr("href");

    $.getJSON(manifest_url, function(data) {
      console.log(data);
      page = data.sequences[0].canvases[0];
      var info_url = page.images[0].resource.service['@id'] + '/info.json';

      imageHeight = data.sequences[0].canvases[0].height;
      imageWidth = data.sequences[0].canvases[0].width;


      console.log(imageWidth, "x", imageHeight);
      if ( true || words.length > 0 ) {
        console.log("LOADING ANNOTATIONS");
      }

      viewer = OpenSeadragon({
          id: "image-viewer",
          prefixUrl: "//openseadragon.github.io/openseadragon/images/",
          gestureSettingsMouse: {
            scrollToZoom: false,
            clickToZoom: false,
            dblClickToZoom: true,
            flickEnabled: true,
            pinchRotate: true
          },
          gestureSettingsTouch: {
            pinchRotate: true
          },
          showNavigationControl: true,
          zoomInButton: 'action-zoom-in',
          zoomOutButton: 'action-zoom-out'
      });

      viewer.world.addHandler('add-item', function() {
        addHighlightOverlay(viewer);
        if ( sessionStorage.getItem('best-fit-width') == 'true' ) {
          setTimeout(function() {
            viewer.viewport.fitHorizontally();
          }, 500)
        }
      })

      viewer.addHandler('open', function() {
        // viewer.world.addHandler('add-item', function(e, item, userData) {
        //   console.log("AHOY ADD ITEM", e, item, userData);
        //   addHighlightOverlay(viewer);
        // });
      })

      viewer.addHandler('zoom', function(e) {
        $(".span-zoom-status").text(Math.floor(e.zoom * 100) + '%');
      })

      // viewer.addTiledImage({ tileSource: info_url });
      viewer.open(info_url);
      F.viewer = viewer;

      selection = viewer.selection({
        prefixUrl: '/assets/selection/',
        restrictToImage: false,
        onSelection: function(rect) {
          var translated = viewer.viewport.imageToViewportRectangle(rect)
          viewer.viewport.fitBounds(translated);
          reset_selection();
        },
        onDownloadSelection: function(rect) {
          var params = [];
          params.push(rect.x + "," + rect.y + "," + rect.width + "," + rect.height);
          params.push("full");
          params.push("0");
          params.push("native.jpg");
          params = params.join("/");
          var href = viewer.source['@id'] + "/" + params;
          window.open(href, "_blank");
          // href += "?attachment=0";
          // window.location.href = href;

          // var translated = viewer.viewport.imageToViewportRectangle(rect)
          // viewer.viewport.fitBounds(translated);
          reset_selection();
        },
        onZoomSelection: function(rect) {
          var translated = viewer.viewport.imageToViewportRectangle(rect)
          viewer.viewport.fitBounds(translated);
          reset_selection();
        }
      })
      F.selection = selection;

    });

    $(".action-download-view").on('click', function(e) {
      e.preventDefault();
      var params = resizePrint(viewer);
      var href = viewer.source['@id'] + "/" + params + "?attachment=1";
      window.location.href = href;

      // var href = baseLayer.getViewRequest() + "?attachment=1";
      // window.location.href = href;
    })

    $(".action-toggle-mode").on('change', function() {
      var $input = $(this);
      mode = $input.val();
      if ( mode == 'pan' ) {
        selection.disable();
      } else {
        selection.enable();
      }
    })

    var rotation_total_time = 1;
    var rotateViewer = function(delta) {
      var rotation_step_delta = 1; 
      var deg = viewer.viewport.getRotation();
      var next_deg = deg + delta;
      if ( next_deg < 0 ) { next_deg = 360 + next_deg; }
      viewer.viewport.setRotation(next_deg);     
    }

    var reset_selection = function() {
      var $parent = $(".action-toggle-mode[value=pan]").prop('checked', true).trigger('change').parents(".btn");
      $parent.siblings().toggleClass("active").end().addClass("active");
    }

    $(".action-rotate-left").on('click', function() {
      rotateViewer(-90);
    })

    $(".action-rotate-right").on('click', function() {
      rotateViewer(90);
    })

    window.delta = 1; window.total_time = 1;
    F.razzle = function() {
      var deg = viewer.viewport.getRotation();
      var next_deg = deg + 90;
      var i = setInterval(function() {
        deg += window.delta;;
        viewer.viewport.setRotation(deg);
        if ( deg >= next_deg ) { clearInterval(i); }
      }, window.total_time);
    };

    // from chronam
    function resizePrint(viewer) {
        var image = viewer.source;
        var zoom = viewer.viewport.getZoom(); 
        var size = new OpenSeadragon.Rect(0, 0, image.dimensions.x, image.dimensions.y);
        var container = viewer.viewport.getContainerSize();
        var fit_source = fitWithinBoundingBox(size, container);
        var total_zoom = fit_source.x/image.dimensions.x;
        var container_zoom = fit_source.x/container.x;
        var level =  (zoom * total_zoom) / container_zoom;
        var box = getDisplayRegion(viewer, new OpenSeadragon.Point(parseInt(image.dimensions.x*level), parseInt(image.dimensions.y*level)));
        var scaledBox = new OpenSeadragon.Rect(parseInt(box.x/level), parseInt(box.y/level), parseInt(box.width/level), parseInt(box.height/level));
        var d = fitWithinBoundingBox(box, new OpenSeadragon.Point(681, 817));
        console.log("RESIZE", zoom, size, container, fit_source, total_zoom, level, box, scaledBox);
        var params = [];
        params.push(scaledBox.x + "," + scaledBox.y + "," + scaledBox.width + "," + scaledBox.height);
        params.push(box.width + "," + box.height);
        params.push(box.degrees);
        params.push('default.jpg');
        return params.join("/");
    };

    function fitWithinBoundingBox(d, max) {
        if (d.width/d.height > max.x/max.y) {
            return new OpenSeadragon.Point(max.x, parseInt(d.height * max.x/d.width));
        } else {
            return new OpenSeadragon.Point(parseInt(d.width * max.y/d.height),max.y);
        }
    }
    
    function getDisplayRegion(viewer, source) {
        //Determine portion of scaled image that is being displayed
        var box = new OpenSeadragon.Rect(0, 0, source.x, source.y);
        var container = viewer.viewport.getContainerSize();
        var bounds = viewer.viewport.getBounds();

        console.log(container, box);
        var rotation = viewer.viewport.getRotation();
        if ( rotation == 90 ) {
          var tmp = viewer.viewport.getBounds();
          bounds.x = tmp.y;
          bounds.y = tmp.x;
          bounds.height = tmp.width;
          bounds.width = tmp.height;

          tmp = viewer.viewport.getContainerSize();
          container = new OpenSeadragon.Rect(tmp.y, tmp.x, tmp.height, tmp.width);

          // box = new OpenSeadragon.Rect(0, 0, source.y, source.x);

          console.log(container, bounds, box);
        }

        //If image is offset to the left
        if (bounds.x > 0){
          var offset = viewer.viewport.pixelFromPoint(new OpenSeadragon.Point(0,0));
          var dim = ( rotation == 0 ) ? 'x' : 'y';
            box.x = box.x - offset[dim];
        }
        //If full image doesn't fit
        if (box.x + source.x > container.x) {
            box.width = container.x - viewer.viewport.pixelFromPoint(new OpenSeadragon.Point(0,0)).x;
            if (box.width > container.x) {
                box.width = container.x;
            }
        }
        //If image is offset up
        if (bounds.y > 0) {
            var offset = viewer.viewport.pixelFromPoint(new OpenSeadragon.Point(0,0));
            var dim = ( rotation == 0 ) ? 'y' : 'x';

            box.y = box.y - offset[dim];
        }
        //If full image doesn't fit
        if (box.y + source.y > container.y) {
            box.height = container.y - viewer.viewport.pixelFromPoint(new OpenSeadragon.Point(0,0)).y;
            if (box.height > container.y) {
                box.height = container.y;
            }
        }
        return box;
    }

  })