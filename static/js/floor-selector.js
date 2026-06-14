(function () {
  'use strict';

  var VIEWBOX_GENERAL = '0 0 663 419';
  var VIEWBOX_PISO    = '0 0 181 223';

  var objetoSvg  = document.getElementById('objeto-svg');
  var overlay    = document.getElementById('svg-overlay');
  var btnVolver  = document.getElementById('btn-volver-general');
  var tituloMapa = document.getElementById('titulo-mapa');
  var TITULO_BASE = tituloMapa ? tituloMapa.textContent.trim() : 'Mapa del Campus';

  var estadoActual = null; 

  function setOverlayViewBox(vb) {
    if (overlay) overlay.setAttribute('viewBox', vb);
  }

  function despacharEvento() {
    window.dispatchEvent(new CustomEvent('campus:piso-cambiado', {
      detail: {
        edificio: estadoActual ? estadoActual.edificio : null,
        piso:     estadoActual ? estadoActual.piso     : 0
      }
    }));
  }

  function cambiarPiso(idEdificio, piso) {
    var info = (window.CAMPUS_PISOS || {})[idEdificio];
    if (!info) return;

    estadoActual = { edificio: idEdificio, piso: piso };

    var archivo = window.CAMPUS_SVG_BASE + idEdificio + '_piso' + piso + '.svg';
    if (objetoSvg) objetoSvg.setAttribute('data', archivo);

    setOverlayViewBox(VIEWBOX_PISO);

    if (btnVolver)  btnVolver.style.display  = 'inline-flex';
    if (tituloMapa) tituloMapa.textContent   = TITULO_BASE + ' — ' + info.nombre + ', piso ' + piso;

    despacharEvento();
  }

  function volverMapaGeneral() {
    estadoActual = null;
    if (objetoSvg) objetoSvg.setAttribute('data', window.CAMPUS_SVG_GENERAL);
    setOverlayViewBox(VIEWBOX_GENERAL);
    if (btnVolver)  btnVolver.style.display  = 'none';
    if (tituloMapa) tituloMapa.textContent   = TITULO_BASE;
    despacharEvento();
  }

  setOverlayViewBox(VIEWBOX_GENERAL);

  window.CampusMapa = {
    cambiarPiso:       cambiarPiso,
    volverMapaGeneral: volverMapaGeneral,
    estadoActual:      function () { return estadoActual; }
  };
  setTimeout(despacharEvento, 100);

})();