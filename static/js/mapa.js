let todosLosNodos    = [];
let nodoSeleccionado = null;
let estadoMapa       = { edificio: null, piso: 0 };
let filtroTipoActivo = null;

const COLORES = {
  sala:           '#0d6efd',
  edificio:       '#6610f2',
  bano_accesible: '#0dcaf0',
  ascensor:       '#ffc107',
  rampa:          '#20c997',
  zona_tranquila: '#198754',
  entrada:        '#fd7e14',
  escalera:       '#adb5bd',
  punto_interes:  '#e83e8c',
};

document.addEventListener('DOMContentLoaded', function () {
  iniciarBuscador();
  iniciarFiltros();
  iniciarFormularioRuta();
  iniciarReporte();
  iniciarFavorito();
  leerParamsURL();
  cargarNodos();
});

window.addEventListener('campus:piso-cambiado', function (e) {
  estadoMapa = {
    edificio: e.detail.edificio,
    piso:     e.detail.piso
  };
  cargarNodos(filtroTipoActivo);
});

function perteneceAlEstado(nodo) {
  if (!estadoMapa.edificio) {
    return nodo.piso === 0;
  }
  if (estadoMapa.edificio === 'M1') {
    if (nodo.piso !== estadoMapa.piso) return false;
    return nodo.svg_id.startsWith('m1-') || nodo.svg_id.startsWith('escaleras-m1-');
  }
  if (estadoMapa.edificio === 'M3') {
    if (nodo.piso !== estadoMapa.piso) return false;
    return nodo.svg_id.startsWith('m3-') ||
           nodo.svg_id.startsWith('escaleras-m3-') ||
           nodo.svg_id.startsWith('bano-m3-');
  }
  return false;
}

function cargarNodos(tipo = null) {
  filtroTipoActivo = tipo;
  const url = tipo ? `/api/nodos?tipo=${tipo}` : '/api/nodos';
  fetch(url)
    .then(r => r.json())
    .then(nodos => {
      todosLosNodos = nodos;
      limpiarOverlay();
      nodos.forEach(pintarMarcador);
    })
    .catch(err => console.error('Error cargando nodos:', err));
}

function pintarMarcador(nodo) {
  if (!perteneceAlEstado(nodo)) return;

  const overlay = document.getElementById('svg-overlay');
  if (!overlay) return;

  const cx    = nodo.coord_x;
  const cy    = nodo.coord_y;
  const color = nodo.activo ? (COLORES[nodo.tipo] || '#888') : '#dc3545';

  const g = document.createElementNS('http://www.w3.org/2000/svg', 'g');
  g.setAttribute('class', 'marcador-nodo');
  g.setAttribute('role', 'button');
  g.setAttribute('tabindex', '0');
  g.setAttribute('aria-label', `${nodo.nombre} — ${nodo.tipo.replace('_', ' ')}`);
  g.dataset.nodoId = nodo.id;
  g.style.pointerEvents = 'all';

  const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
  circle.setAttribute('cx', cx);
  circle.setAttribute('cy', cy);
  circle.setAttribute('r', 5);
  circle.setAttribute('fill', color);
  circle.setAttribute('stroke', '#fff');
  circle.setAttribute('stroke-width', 1.5);

  const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
  text.setAttribute('x', cx);
  text.setAttribute('y', cy - 7);
  text.setAttribute('text-anchor', 'middle');
  text.setAttribute('font-size', '7');
  text.setAttribute('fill', '#111');
  text.setAttribute('font-family', 'sans-serif');
  text.textContent = nodo.nombre.length > 18 ? nodo.nombre.slice(0, 16) + '…' : nodo.nombre;

  g.appendChild(circle);
  g.appendChild(text);
  overlay.appendChild(g);

  g.addEventListener('click',   () => abrirModalNodo(nodo));
  g.addEventListener('keydown', e => { if (e.key === 'Enter' || e.key === ' ') abrirModalNodo(nodo); });
}

function limpiarOverlay() {
  const overlay = document.getElementById('svg-overlay');
  if (overlay) overlay.innerHTML = '';
}

function centrarEnNodo(nodo) {
  const overlay = document.getElementById('svg-overlay');
  if (!overlay) return;
  overlay.querySelectorAll('.marcador-nodo circle').forEach(c => {
    c.setAttribute('stroke-width', 1.5);
    c.setAttribute('r', 5);
    c.removeAttribute('stroke');
  });
  const c = overlay.querySelector(`[data-nodo-id="${nodo.id}"] circle`);
  if (c) {
    c.setAttribute('r', 9);
    c.setAttribute('stroke-width', 3);
    c.setAttribute('stroke', '#fd7e14');
  }
}

function iniciarBuscador() {
  const input = document.getElementById('input-busqueda');
  const lista = document.getElementById('lista-sugerencias');
  if (!input || !lista) return;

  let timeout;
  input.addEventListener('input', function () {
    clearTimeout(timeout);
    const q = this.value.trim();
    if (q.length < 2) { lista.innerHTML = ''; return; }
    timeout = setTimeout(() => {
      fetch(`/api/nodos/buscar?q=${encodeURIComponent(q)}`)
        .then(r => r.json())
        .then(resultados => {
          lista.innerHTML = '';
          if (!resultados.length) {
            lista.innerHTML = '<li class="list-group-item text-muted small">Sin resultados</li>';
            return;
          }
          resultados.forEach(nodo => {
            const li = document.createElement('li');
            li.className = 'list-group-item list-group-item-action small';
            li.setAttribute('role', 'option');
            li.setAttribute('tabindex', '0');
            li.textContent = `${nodo.nombre} (piso ${nodo.piso})`;
            li.addEventListener('click', () => {
              input.value = nodo.nombre;
              lista.innerHTML = '';
              centrarEnNodo(nodo);
              const selDestino = document.getElementById('sel-destino');
              if (selDestino) selDestino.value = nodo.id;
            });
            li.addEventListener('keydown', e => { if (e.key === 'Enter') li.click(); });
            lista.appendChild(li);
          });
        });
    }, 300);
  });

  document.addEventListener('click', e => {
    if (!input.contains(e.target)) lista.innerHTML = '';
  });
}

function iniciarFiltros() {
  document.querySelectorAll('.filtro-btn').forEach(btn => {
    btn.addEventListener('click', function () {
      const tipo = this.dataset.tipo;
      const yaActivo = this.classList.contains('active');
      document.querySelectorAll('.filtro-btn').forEach(b => b.classList.remove('active'));
      if (yaActivo) {
        cargarNodos(null);
      } else {
        this.classList.add('active');
        cargarNodos(tipo);
      }
    });
  });

  const btnLimpiar = document.getElementById('btn-limpiar-filtros');
  if (btnLimpiar) {
    btnLimpiar.addEventListener('click', () => {
      document.querySelectorAll('.filtro-btn').forEach(b => b.classList.remove('active'));
      cargarNodos(null);
    });
  }
}

function iniciarFormularioRuta() {
  const btnCalc = document.getElementById('btn-calcular-ruta');
  if (!btnCalc) return;

  btnCalc.addEventListener('click', function () {
    const origenId  = document.getElementById('sel-origen').value;
    const destinoId = document.getElementById('sel-destino').value;
    const accesible = document.getElementById('chk-accesible').checked;

    if (!origenId || !destinoId) {
      alert('Selecciona un punto de origen y uno de destino.');
      return;
    }
    if (origenId === destinoId) {
      alert('El origen y el destino no pueden ser el mismo punto.');
      return;
    }

    this.disabled    = true;
    this.textContent = 'Calculando…';

    fetch(`/api/ruta?desde=${origenId}&hasta=${destinoId}&accesible=${accesible}`)
      .then(r => r.json())
      .then(data => {
        if (data.error) { alert(data.error); return; }
        dibujarRuta(data.camino);
        mostrarInstrucciones(data.instrucciones);
      })
      .catch(() => alert('Error al calcular la ruta. Intenta de nuevo.'))
      .finally(() => {
        this.disabled  = false;
        this.innerHTML = '<i class="bi bi-arrow-right-circle" aria-hidden="true"></i> Calcular ruta';
      });
  });
}

function dibujarRuta(camino) {
  limpiarOverlay();
  todosLosNodos.forEach(pintarMarcador);

  const overlay = document.getElementById('svg-overlay');
  if (!overlay || camino.length < 2) return;

  const puntos = camino.map(n => `${n.coord_x},${n.coord_y}`).join(' ');
  const linea  = document.createElementNS('http://www.w3.org/2000/svg', 'polyline');
  linea.setAttribute('points', puntos);
  linea.setAttribute('class', 'ruta-linea');
  overlay.appendChild(linea);

  camino.forEach((n, i) => {
    const c = overlay.querySelector(`[data-nodo-id="${n.id}"] circle`);
    if (!c) return;
    c.setAttribute('r', i === 0 || i === camino.length - 1 ? 9 : 5);
    if (i === 0) { c.setAttribute('fill', '#198754'); c.setAttribute('stroke', '#fff'); }
    if (i === camino.length - 1) { c.setAttribute('fill', '#dc3545'); c.setAttribute('stroke', '#fff'); }
  });
}

function mostrarInstrucciones(instrucciones) {
  const card  = document.getElementById('card-resultado');
  const panel = document.getElementById('panel-ruta');
  if (!card || !panel) return;

  card.style.display = 'block';
  panel.innerHTML = instrucciones.map((texto, i) => `
    <div class="d-flex gap-2 mb-1 align-items-start">
      <span class="badge bg-primary rounded-pill">${i + 1}</span>
      <span class="small">${texto}</span>
    </div>`).join('');

  const btnLeer = document.getElementById('btn-leer-ruta');
  if (btnLeer) {
    btnLeer.onclick = function () {
      leerInstrucciones(instrucciones);
    };
  }
}

function leerInstrucciones(instrucciones) {
  if (!instrucciones || instrucciones.length === 0) {
    alert('No hay instrucciones para leer. Calcula una ruta primero.');
    return;
  }
  if (!window.speechSynthesis) {
    alert('Tu navegador no soporta síntesis de voz.');
    return;
  }
  window.speechSynthesis.cancel();
  const texto = instrucciones.join('. ');
  const utt   = new SpeechSynthesisUtterance(texto);
  utt.lang    = 'es-CL';
  utt.rate    = 0.9;
  window.speechSynthesis.speak(utt);
}

function iniciarReporte() {
  const btn = document.getElementById('btn-enviar-reporte');
  if (!btn) return;

  btn.addEventListener('click', function () {
    const nodoId      = document.getElementById('rep-nodo').value;
    const tipo        = document.getElementById('rep-tipo').value;
    const descripcion = document.getElementById('rep-descripcion').value;
    const msgEl       = document.getElementById('rep-mensaje');

    if (!nodoId || !tipo) {
      msgEl.className   = 'alert alert-danger';
      msgEl.textContent = 'Selecciona una ubicación y el tipo de problema.';
      msgEl.classList.remove('d-none');
      return;
    }

    btn.disabled = true;
    fetch('/api/reportes', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify({ nodo_id: parseInt(nodoId), tipo, descripcion })
    })
    .then(r => r.json())
    .then(data => {
      msgEl.className   = 'alert alert-success';
      msgEl.textContent = data.mensaje || data.error;
      msgEl.classList.remove('d-none');
      document.getElementById('rep-nodo').value        = '';
      document.getElementById('rep-tipo').value        = '';
      document.getElementById('rep-descripcion').value = '';
      setTimeout(() => {
        bootstrap.Modal.getInstance(document.getElementById('modal-reporte'))?.hide();
      }, 2000);
    })
    .catch(() => {
      msgEl.className   = 'alert alert-danger';
      msgEl.textContent = 'Error al enviar el reporte.';
      msgEl.classList.remove('d-none');
    })
    .finally(() => btn.disabled = false);
  });
}

function abrirModalNodo(nodo) {
  nodoSeleccionado = nodo;
  document.getElementById('titulo-modal-nodo').textContent = nodo.nombre;
  document.getElementById('cuerpo-modal-nodo').innerHTML = `
    <dl class="mb-0 small">
      <dt>Tipo</dt><dd>${nodo.tipo.replace(/_/g, ' ')}</dd>
      <dt>Piso</dt><dd>${nodo.piso === 0 ? 'Planta baja / exterior' : 'Piso ' + nodo.piso}</dd>
      ${nodo.descripcion ? `<dt>Descripción</dt><dd>${nodo.descripcion}</dd>` : ''}
      <dt>Estado</dt>
      <dd>${nodo.activo
        ? '<span class="text-success fw-semibold">Disponible</span>'
        : '<span class="text-danger fw-semibold">Fuera de servicio</span>'}</dd>
    </dl>`;
  new bootstrap.Modal(document.getElementById('modal-nodo')).show();
}

function iniciarFavorito() {
  const btn = document.getElementById('btn-guardar-favorito');
  if (!btn) return;
  btn.addEventListener('click', function () {
    if (!nodoSeleccionado) return;
    fetch('/api/favoritos', {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify({ nodo_id: nodoSeleccionado.id })
    })
    .then(r => r.json())
    .then(data => {
      alert(data.mensaje || data.error);
      bootstrap.Modal.getInstance(document.getElementById('modal-nodo'))?.hide();
    })
    .catch(() => alert('Error al guardar favorito. ¿Iniciaste sesión?'));
  });
}

function leerParamsURL() {
  const params    = new URLSearchParams(window.location.search);
  const destinoId = params.get('destino');
  const tipo      = params.get('tipo');
  if (tipo) {
    const btn = document.querySelector(`.filtro-btn[data-tipo="${tipo}"]`);
    if (btn) btn.click();
  }
  if (destinoId) {
    const sel = document.getElementById('sel-destino');
    if (sel) sel.value = destinoId;
  }
}