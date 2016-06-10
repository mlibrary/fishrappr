(function (factory, window) {

    // define an AMD module that relies on 'leaflet'
    if (typeof define === 'function' && define.amd) {
        define(['leaflet'], factory);

    // define a Common JS module that relies on 'leaflet'
    } else if (typeof exports === 'object') {
        module.exports = factory(require('leaflet'));
    }

    // attach your plugin to the global 'L' variable
    if (typeof window !== 'undefined' && window.L) {
        // window.L.Control.RemoteZoom = factory(L);
        factory(window.L);
    }
}(function (L) {
    L.Control.RemoteZoom = L.Control.extend({
        options: {
            zoomInClass: 'action-zoom-in',
            zoomOutClass: 'action-zoom-out',
            zoomStatusClass: 'span-zoom-status'
        },

        onAdd: function (map) {

            this._map = map;

            this._zoomInButton = this._createButton(this.options.zoomInClass, this._zoomIn, this);
            this._zoomOutButton  = this._createButton(this.options.zoomOutClass, this._zoomOut, this);
            this._zoomStatusField = $("." + this.options.zoomStatusClass);

            this._updateDisabled();
            map.on('zoomend zoomlevelschange', this._updateDisabled, this);

            return $("<div></div>").get(0);

        },

        onRemove: function (map) {
            map.off('zoomend zoomlevelschange', this._updateDisabled, this);
        },

        _zoomIn: function (e) {
            this._map.zoomIn(e.shiftKey ? 3 : 1);
        },

        _zoomOut: function (e) {
            this._map.zoomOut(e.shiftKey ? 3 : 1);
        },

        _createButton: function (className, fn, context) {

            // var link = L.DomUtil.create('a', className, container);
            // link.innerHTML = html;
            // link.href = '#';
            // link.title = title;

            var stop = L.DomEvent.stopPropagation;
            var $btn = $("." + className);
            var link = $btn.get(0);

            L.DomEvent
                .on(link, 'click', stop)
                .on(link, 'mousedown', stop)
                .on(link, 'dblclick', stop)
                .on(link, 'click', L.DomEvent.preventDefault)
                .on(link, 'click', fn, context)
                .on(link, 'click', this._refocusOnMap, context);

            return link;
        },

        _updateDisabled: function () {
            var map = this._map,
                className = 'leaflet-disabled';

            L.DomUtil.removeClass(this._zoomInButton, className);
            L.DomUtil.removeClass(this._zoomOutButton, className);

            var per = Math.ceil(( map._zoom / map.getMaxZoom() ) * 100.0);
            this._zoomStatusField.text(per + "%");

            if (map._zoom === map.getMinZoom()) {
                L.DomUtil.addClass(this._zoomOutButton, className);
            }
            if (map._zoom === map.getMaxZoom()) {
                L.DomUtil.addClass(this._zoomInButton, className);
            }
        }
    });

}, window));

