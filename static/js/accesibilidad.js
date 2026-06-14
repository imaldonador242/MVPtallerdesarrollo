(function () {
  'use strict';

  // ── Alto contraste ───────────────────────────────────────
  var estilosContraste = `
    body.alto-contraste,
    body.alto-contraste .navbar,
    body.alto-contraste .barra-accesibilidad,
    body.alto-contraste .card,
    body.alto-contraste .modal-content,
    body.alto-contraste .list-group-item,
    body.alto-contraste footer {
      background-color: #000 !important;
      color: #fff !important;
      border-color: #fff !important;
    }
    body.alto-contraste a,
    body.alto-contraste .nav-link,
    body.alto-contraste .navbar-brand,
    body.alto-contraste label,
    body.alto-contraste .form-label,
    body.alto-contraste .text-muted,
    body.alto-contraste small,
    body.alto-contraste h1,h2,h3,h4,h5,h6 {
      color: #fff !important;
    }
    body.alto-contraste .btn {
      border: 2px solid #fff !important;
      color: #fff !important;
      background-color: #000 !important;
    }
    body.alto-contraste .btn:hover,
    body.alto-contraste .btn:focus {
      background-color: #fff !important;
      color: #000 !important;
    }
    body.alto-contraste .btn-primary {
      background-color: #ff0 !important;
      color: #000 !important;
      border-color: #ff0 !important;
    }
    body.alto-contraste .form-control,
    body.alto-contraste .form-select {
      background-color: #000 !important;
      color: #fff !important;
      border: 2px solid #fff !important;
    }
    body.alto-contraste #svg-overlay text {
      fill: #fff !important;
    }
  `;

  var styleEl = document.createElement('style');
  styleEl.textContent = estilosContraste;
  document.head.appendChild(styleEl);

  var btnContraste = document.getElementById('btn-alto-contraste');
  var altoContrasteActivo = localStorage.getItem('alto-contraste') === '1';

  function aplicarContraste(activo) {
    document.body.classList.toggle('alto-contraste', activo);
    if (btnContraste) btnContraste.setAttribute('aria-pressed', String(activo));
    localStorage.setItem('alto-contraste', activo ? '1' : '0');
  }

  aplicarContraste(altoContrasteActivo);

  if (btnContraste) {
    btnContraste.addEventListener('click', function () {
      altoContrasteActivo = !altoContrasteActivo;
      aplicarContraste(altoContrasteActivo);
    });
  }

  // ── Tamaño de fuente ─────────────────────────────────────
  var tamanos = ['1rem', '1.2rem', '1.45rem'];
  var indiceActual = parseInt(localStorage.getItem('tamano-fuente') || '0', 10);
  var btnFuente = document.getElementById('btn-fuente-grande');

  function aplicarTamano(i) {
    document.documentElement.style.fontSize = tamanos[i];
    if (btnFuente) btnFuente.setAttribute('aria-pressed', String(i > 0));
    localStorage.setItem('tamano-fuente', String(i));
  }

  aplicarTamano(indiceActual);

  if (btnFuente) {
    btnFuente.addEventListener('click', function () {
      indiceActual = (indiceActual + 1) % tamanos.length;
      aplicarTamano(indiceActual);
    });
  }

  // ── TTS global (lector de pantalla básico) ───────────────
  var btnTTS      = document.getElementById('btn-tts');
  var btnPararTTS = document.getElementById('btn-parar-tts');
  var ttsActivo   = false;
  var utterance   = null;

  function leer(texto) {
    if (!window.speechSynthesis || !texto || !texto.trim()) return;
    window.speechSynthesis.cancel();
    utterance      = new SpeechSynthesisUtterance(texto.trim());
    utterance.lang = 'es-CL';
    utterance.rate = 0.9;
    window.speechSynthesis.speak(utterance);
    if (btnPararTTS) btnPararTTS.classList.remove('d-none');
  }

  function detenerTTS() {
    if (window.speechSynthesis) window.speechSynthesis.cancel();
    if (btnPararTTS) btnPararTTS.classList.add('d-none');
  }

  function manejarHover(e) {
    if (!ttsActivo) return;
    var el   = e.target;
    var texto = el.getAttribute('aria-label')
              || el.getAttribute('title')
              || el.getAttribute('alt')
              || el.textContent;
    if (texto) leer(texto);
  }

  function activarModoLector(activo) {
    ttsActivo = activo;
    if (btnTTS) btnTTS.setAttribute('aria-pressed', String(activo));

    if (activo) {
      document.addEventListener('mouseover', manejarHover);
      leer('Lector de pantalla activado. Pasa el cursor sobre los elementos para escucharlos.');
    } else {
      document.removeEventListener('mouseover', manejarHover);
      detenerTTS();
    }
  }

  if (btnTTS) {
    btnTTS.addEventListener('click', function () {
      activarModoLector(!ttsActivo);
    });
  }

  if (btnPararTTS) {
    btnPararTTS.addEventListener('click', detenerTTS);
  }

})();