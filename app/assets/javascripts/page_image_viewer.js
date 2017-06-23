  $().ready(function() {
      
    if ( ! $("body").is(".blacklight-catalog-show") ) {
      return;
    }

    window.F = window.F || {};
    var $map = $("#image-viewer");
    var $wrap = $("#image-viewer-wrap");
    var option = $("body").data('option');

    var waypoints;
    var $toolbar; var $spacer;

    var resize_viewer = function() {
      var width = $map.data('width'); var height = $map.data('height');
      var r;
      r = $map.width() / width;
      height *= r;
      if ( height < 300 ) {
        height = $(window).height() - 20;
      }
      $wrap.height(height);
      var w = $(window).width();
      $("body").trigger("sticky_kit:recalc");
      setTimeout(function() {
        if ( $(".page-options").parents(".table-row").css('display') == 'block' ) {
          $(".page-options").trigger('sticky_kit:detach');
        } else {
          $(".page-options").stick_in_parent({ parent: '.container-viewer', offset_top: -50 });
        }        
      }, 100);
      if ( $toolbar !== undefined ) {
        if ( $toolbar.css('position') == 'fixed' ) {
          $spacer.detach();
          var w = $toolbar.width();
          $toolbar.css({
            position: "",
            top: "",
            width: "",
            bottom: ""
          });
          setTimeout(function() {
            waypoints.disable();
            stick_bottom_toolbar();
          }, 100);
        }
      }
    };

    $(window).resize(debounce(resize_viewer));

    var words = $map.data('words');
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
      })
    }

    var viewer; var selection; var mode;
    var queue = [];

    var i = 1;
    var manifest_url = $("link[rel='manifest']").attr("href");

    var load_tile_viewer = function() {
      $.ajax({
        url: manifest_url,
        method: 'GET',
        dataType: 'json',
        xhrFields: {
          withCredentials: true
        },
        success: function(data) {
          console.log("AHOY", data);
          page = data.sequences[0].canvases[0];
          var info_url = page.images[0].resource.service['@id'] + '/info.json';

          imageHeight = data.sequences[0].canvases[0].height;
          imageWidth = data.sequences[0].canvases[0].width;

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
              zoomOutButton: 'action-zoom-out',
              ajaxWithCredentials: true
          });

          viewer.world.addHandler('add-item', function() {
            addHighlightOverlay(viewer);
            if ( sessionStorage.getItem('best-fit-width') == 'true' ) {
              setTimeout(function() {
                viewer.viewport.fitHorizontally();
              }, 500)
            }
          })

          viewer.addHandler('zoom', function(e) {
            $(".span-zoom-status").text(Math.floor(e.zoom * 100) + '%');
          })

          viewer.open(info_url);
          F.viewer = viewer;

          selection = viewer.selection({
            // prefixUrl: '/assets/selection/',
            showSelectionControl: false,
            restrictToImage: false,
            onSelection: function(rect) {
              var translated = viewer.viewport.imageToViewportRectangle(rect)
              viewer.viewport.fitBounds(translated);
              reset_selection();
            },
            onSelectionDrawn: function() {
              $(".selection-toolbar .invisible").toggleClass("visible");
            },
            onDownloadSelection: function(rect) {
              var params = [];
              params.push(rect.x + "," + rect.y + "," + rect.width + "," + rect.height);
              params.push("full");
              params.push("0");
              params.push("default.jpg");
              params = params.join("/");
              var href = viewer.source['@id'] + "/" + params;
              href += "?attachment=1";
              window.location.href = href;

              //// --- if we were scaling
              // var translated = viewer.viewport.imageToViewportRectangle(rect)
              // viewer.viewport.fitBounds(translated);
              reset_selection();
            },
            onZoomSelection: function(rect) {
              queue.push(function() { reset_selection(); })
              var translated = viewer.viewport.imageToViewportRectangle(rect)
              viewer.viewport.fitBounds(translated);
            },
            onCancelSelection: function() {
              reset_selection();
            }
          })
          F.selection = selection;

          viewer.addHandler('animation-finish', function() {
            while ( queue.length ) {
              var fn = queue.pop();
              fn();
            }
          })

        },
        error: function(jqXHR, textStatus, errorThrown) {
          console.log("XHR", jqXHR);
          console.log("STATUS:", textStatus);
          console.log("ERROR:", errorThrown);
        }
      })

      // $.getJSON(manifest_url, function(data) {

      // });

    }

    var stick_bottom_toolbar = function() {


      if ( $toolbar === undefined ) {
        $toolbar = $(".image-viewer-toolbar-bottom");
        $spacer = $('<div></div>').css({ height: $toolbar.height(), width: $toolbar.width(), display: 'none' });
      }

      if ( $toolbar.offset().top + $toolbar.outerHeight() < $(window).scrollTop() + $(window).height() ) {
        return;
      }

      if ( waypoints === undefined ) {
        setTimeout(function() {
          waypoints = new Waypoint.Inview({
            element: $spacer[0],
            entered: function(direction) {
              // console.log("ENTERED", direction);
              if ( direction == 'down' ) {
                $toolbar.css({ position: 'static' });
                $spacer.hide();
              }
            },
            exit: function(direction) {
              // console.log("EXITED", direction);
              if ( direction == 'up' ) {
                $toolbar.css({ position: 'fixed' });
                $spacer.show();
              }
            }
          })          
        }, 1000);

      } else {
        setTimeout(function() {
          waypoints.enable();
        })
      }

      $toolbar.css({ position: 'fixed', bottom: 0, width: $toolbar.width() });
      $spacer.css({ width: $toolbar.width() });
      $toolbar.after($spacer);
      $spacer.show();

    };

    var resize_and_load_viewer = function() {
        resize_viewer();
        $map.empty();
        $(".default-toolbar").show();
        $(".action-reset-viewer").removeClass('hidden');
        $(".action-deactivate-viewer").removeClass('hidden');

        stick_bottom_toolbar();
        load_tile_viewer();
    };

    resize_and_load_viewer();

    $(".action-reset-viewer").on('click', function(e) {
      e.preventDefault();
      viewer.viewport.goHome();
    })

    $(".action-download-view").on('click', function(e) {
      e.preventDefault();
      var params = resizePrint(viewer);
      var href = viewer.source['@id'] + "/" + params + "?attachment=1";
      window.location.href = href;
    })

    $(".action-toggle-mode").on('click', function() {
      // we are toggling modal
      $(".default-toolbar").toggleClass('hidden');
      $(".selection-toolbar").toggleClass('hidden');
      selection.enable();
    })

    $("#action-selection-cancel").on('click', function() {
      reset_selection();
    })

    $("#action-selection-zoom-in").on('click', function(e) {
      selection.zoom();
    })

    $("#action-selection-download").on('click', function(e) {
      selection.download();
    })

    $("body").on('keydown', function(e) {
      var keyCode = e.which;

      var remap_codes = {};
      var track_codes = {};
      remap_codes['187'] = 43;
      remap_codes['189'] = 45;
      track_codes['38'] = true; // up arrow
      track_codes['40'] = true; // down arrow
      track_codes['37'] = true; // left arrow
      track_codes['39'] = true; // right arrow

      var $canvas = $("canvas");
      if ( ! $canvas.get(0).hasAttribute('tabindex') ) {
        $canvas.attr("tabindex", -1);
      }
      if ( keyCode == 27 ) {
        // escape
        if ( selection.isSelecting ) {
          reset_selection();
        } else {
          viewer.viewport.goHome();
        }
      } else if ( ( track_codes[keyCode] || remap_codes[keyCode] ) && ! $canvas.is(":focus") ) {
        $canvas.focus();
        if ( remap_codes[keyCode] ) {
          viewer.innerTracker.keyHandler({ keyCode: remap_codes[keyCode] ? remap_codes[keyCode] : keyCode });
        } else {
          viewer.innerTracker.keyDownHandler({ keyCode: keyCode });
        }
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
      // var $parent = $(".action-toggle-mode[value=pan]").prop('checked', true).trigger('change').parents(".btn");
      // $parent.siblings().toggleClass("active").end().addClass("active");

      selection.disable();
      $(".selection-toolbar").toggleClass('hidden');
      $(".default-toolbar").toggleClass('hidden');
      $(".selection-toolbar .invisible.visible").toggleClass("visible");
    }

    $(".action-rotate-left").on('click', function() {
      rotateViewer(-90);
    })

    $(".action-rotate-right").on('click', function() {
      rotateViewer(90);
    })

    $("a[role=tab]").on('click', function(e) {
      e.preventDefault();
      var $target = $($(this).attr("href"));
      // window.scrollTo(0, $target.offset().top - 60);
      $('body,html').animate({
          scrollTop: $target.offset().top - 60
      }, 'fast');
    })

    function resizePrint(viewer) {
        var image = viewer.source;
        var zoom = viewer.viewport.getZoom(); 
        var size = new OpenSeadragon.Rect(0, 0, image.dimensions.x, image.dimensions.y);
        var container = viewer.viewport.getContainerSize();
        var fit_source = fitWithinBoundingBox(size, container);
        var total_zoom = fit_source.x/image.dimensions.x;

        var container_zoom = fit_source.x/container.x;
        var percentage =  parseInt(100 * (zoom * total_zoom) / container_zoom);

        var bounds = viewer.viewport.getBounds();
        var rect = viewer.viewport.viewportToImageRectangle(bounds);

        if ( rect.x < 0 ) { rect.x = 0 ; }
        if ( rect.y < 0 ) { rect.y = 0 ; }

        var params = [];
        params.push(rect.x + "," + rect.y + "," + rect.width + "," + rect.height);
        // params.push("pct:" + percentage);
        params.push("full");
        params.push(viewer.viewport.getRotation());
        params.push("default.jpg");
        return params.join("/");
    };

    function fitWithinBoundingBox(d, max) {
        if (d.width/d.height > max.x/max.y) {
            return new OpenSeadragon.Point(max.x, parseInt(d.height * max.x/d.width));
        } else {
            return new OpenSeadragon.Point(parseInt(d.width * max.y/d.height),max.y);
        }
    }
  

  })