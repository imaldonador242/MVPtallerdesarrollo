from flask import Flask, render_template, request, jsonify, session, redirect, url_for, flash, g
import pymysql
import pymysql.cursors
from werkzeug.security import generate_password_hash, check_password_hash
from functools import wraps
from collections import defaultdict
import heapq
import os
from config import get_db_params

app = Flask(__name__)
app.secret_key = os.environ.get('SECRET_KEY', 'cambiar-en-produccion')


def get_db():
    if 'db' not in g:
        g.db = pymysql.connect(**get_db_params())
    return g.db

@app.teardown_appcontext
def close_db(error):
    db = g.pop('db', None)
    if db is not None:
        db.close()


def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'usuario_id' not in session:
            flash('Debes iniciar sesión.', 'warning')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated

def admin_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'usuario_id' not in session:
            return redirect(url_for('login'))
        if session.get('rol') != 'admin':
            flash('Acceso restringido a administradores.', 'danger')
            return redirect(url_for('index'))
        return f(*args, **kwargs)
    return decorated


def obtener_grafo(solo_accesible=True):
    cur = get_db().cursor()
    query = """
        SELECT nodo_origen, nodo_destino, distancia
        FROM conexiones
        WHERE 1=1
    """
    if solo_accesible:
        query += " AND tiene_escalera = FALSE"

    cur.execute(query)
    conexiones = cur.fetchall()
    cur.close()

    grafo = defaultdict(list)
    for c in conexiones:
        grafo[c['nodo_origen']].append((c['nodo_destino'], c['distancia']))
        grafo[c['nodo_destino']].append((c['nodo_origen'], c['distancia']))

    return grafo

def dijkstra(grafo, origen, destino):
    dist  = {origen: 0}
    prev  = {origen: None}
    heap  = [(0, origen)]

    while heap:
        costo_actual, nodo = heapq.heappop(heap)
        if nodo == destino:
            break
        if costo_actual > dist.get(nodo, float('inf')):
            continue
        for vecino, peso in grafo.get(nodo, []):
            nuevo_costo = costo_actual + peso
            if nuevo_costo < dist.get(vecino, float('inf')):
                dist[vecino]  = nuevo_costo
                prev[vecino]  = nodo
                heapq.heappush(heap, (nuevo_costo, vecino))

    if destino not in dist:
        return float('inf'), []

    camino = []
    nodo   = destino
    while nodo is not None:
        camino.append(nodo)
        nodo = prev[nodo]
    camino.reverse()
    return dist[destino], camino


@app.route('/')
def index():
    return render_template('index.html')

@app.route('/mapa')
def mapa():
    cur = get_db().cursor()
    cur.execute("SELECT * FROM nodos WHERE activo = TRUE ORDER BY nombre")
    nodos = cur.fetchall()
    cur.close()
    return render_template('mapa.html', nodos=nodos)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email    = request.form.get('email', '').strip()
        password = request.form.get('password', '')

        cur = get_db().cursor()
        cur.execute("SELECT * FROM usuarios WHERE email = %s", (email,))
        usuario = cur.fetchone()
        cur.close()

        if usuario and check_password_hash(usuario['password_hash'], password):
            session['usuario_id'] = usuario['id']
            session['nombre']     = usuario['nombre']
            session['rol']        = usuario['rol']
            flash(f'Bienvenido/a, {usuario["nombre"]}', 'success')
            return redirect(url_for('mapa'))
        else:
            flash('Email o contraseña incorrectos.', 'danger')

    return render_template('login.html')

@app.route('/registro', methods=['GET', 'POST'])
def registro():
    if request.method == 'POST':
        nombre   = request.form.get('nombre', '').strip()
        email    = request.form.get('email', '').strip()
        password = request.form.get('password', '')

        if not nombre or not email or not password:
            flash('Todos los campos son obligatorios.', 'danger')
            return render_template('registro.html')

        password_hash = generate_password_hash(password)

        try:
            db = get_db()
            cur = db.cursor()
            cur.execute(
                "INSERT INTO usuarios (nombre, email, password_hash) VALUES (%s, %s, %s)",
                (nombre, email, password_hash)
            )
            db.commit()
            cur.close()
            flash('Cuenta creada. Ahora puedes iniciar sesión.', 'success')
            return redirect(url_for('login'))
        except Exception:
            flash('El email ya está registrado.', 'danger')

    return render_template('registro.html')

@app.route('/logout')
def logout():
    session.clear()
    flash('Sesión cerrada.', 'info')
    return redirect(url_for('index'))

@app.route('/admin')
@admin_required
def admin():
    cur = get_db().cursor()
    cur.execute("SELECT * FROM nodos ORDER BY tipo, nombre")
    nodos = cur.fetchall()
    cur.execute("""
        SELECT r.*, n.nombre AS nodo_nombre
        FROM reportes r
        JOIN nodos n ON r.nodo_id = n.id
        WHERE r.estado = 'activo'
        ORDER BY r.creado_en DESC
    """)
    reportes = cur.fetchall()
    cur.close()
    return render_template('admin.html', nodos=nodos, reportes=reportes)

@app.route('/perfil')
@login_required
def perfil():
    cur = get_db().cursor()
    cur.execute("""
        SELECT f.id, f.alias, n.nombre, n.tipo, n.svg_id
        FROM favoritos f
        JOIN nodos n ON f.nodo_id = n.id
        WHERE f.usuario_id = %s
    """, (session['usuario_id'],))
    favoritos = cur.fetchall()
    cur.close()
    return render_template('perfil.html', favoritos=favoritos)


@app.route('/api/ruta')
def api_ruta():
    origen_id  = request.args.get('desde', type=int)
    destino_id = request.args.get('hasta', type=int)
    accesible  = request.args.get('accesible', 'true').lower() == 'true'

    if not origen_id or not destino_id:
        return jsonify({'error': 'Faltan parámetros desde/hasta'}), 400

    grafo = obtener_grafo(solo_accesible=accesible)
    distancia, camino_ids = dijkstra(grafo, origen_id, destino_id)

    if not camino_ids:
        return jsonify({'error': 'No existe ruta disponible entre los puntos seleccionados'}), 404

    cur = get_db().cursor()
    formato = ','.join(['%s'] * len(camino_ids))
    cur.execute(f"SELECT * FROM nodos WHERE id IN ({formato})", camino_ids)
    nodos_raw = cur.fetchall()
    cur.close()

    nodos_dict = {n['id']: n for n in nodos_raw}
    nodos_ordenados = [nodos_dict[i] for i in camino_ids if i in nodos_dict]

    instrucciones = []
    for i, nodo in enumerate(nodos_ordenados):
        if i == 0:
            instrucciones.append(f'Comienza en {nodo["nombre"]}.')
        elif i == len(nodos_ordenados) - 1:
            instrucciones.append(f'Has llegado a tu destino: {nodo["nombre"]}.')
        else:
            instrucciones.append(f'Continúa hacia {nodo["nombre"]}.')

    return jsonify({
        'distancia':     distancia,
        'camino':        nodos_ordenados,
        'instrucciones': instrucciones,
        'accesible':     accesible
    })

@app.route('/api/nodos')
def api_nodos():
    tipo = request.args.get('tipo')
    cur  = get_db().cursor()
    if tipo:
        cur.execute("SELECT * FROM nodos WHERE tipo = %s AND activo = TRUE", (tipo,))
    else:
        cur.execute("SELECT * FROM nodos WHERE activo = TRUE")
    nodos = cur.fetchall()
    cur.close()
    return jsonify(nodos)

@app.route('/api/nodos/buscar')
def api_buscar_nodo():
    q = request.args.get('q', '').strip()
    if len(q) < 2:
        return jsonify([])
    cur = get_db().cursor()
    cur.execute(
        "SELECT * FROM nodos WHERE nombre LIKE %s AND activo = TRUE LIMIT 10",
        (f'%{q}%',)
    )
    resultados = cur.fetchall()
    cur.close()
    return jsonify(resultados)

@app.route('/api/reportes', methods=['POST'])
def api_crear_reporte():
    data        = request.get_json()
    nodo_id     = data.get('nodo_id')
    tipo        = data.get('tipo')
    descripcion = data.get('descripcion', '')
    usuario_id  = session.get('usuario_id')

    if not nodo_id or not tipo:
        return jsonify({'error': 'nodo_id y tipo son requeridos'}), 400

    db = get_db()
    cur = db.cursor()
    cur.execute(
        "INSERT INTO reportes (nodo_id, usuario_id, tipo, descripcion) VALUES (%s,%s,%s,%s)",
        (nodo_id, usuario_id, tipo, descripcion)
    )
    db.commit()
    cur.close()
    return jsonify({'mensaje': 'Reporte enviado. Gracias por avisar.'}), 201

@app.route('/api/nodos/<int:nodo_id>', methods=['PUT'])
@admin_required
def api_actualizar_nodo(nodo_id):
    data   = request.get_json()
    activo = data.get('activo')

    db = get_db()
    cur = db.cursor()
    cur.execute("UPDATE nodos SET activo = %s WHERE id = %s", (activo, nodo_id))

    if activo is False:
        cur.execute("SELECT tipo FROM nodos WHERE id = %s", (nodo_id,))
        nodo = cur.fetchone()
        if nodo and nodo['tipo'] == 'ascensor':
            cur.execute(
                "INSERT INTO reportes (nodo_id, usuario_id, tipo, descripcion) VALUES (%s,%s,%s,%s)",
                (nodo_id, session['usuario_id'], 'ascensor_fuera', 'Marcado fuera de servicio por administrador')
            )

    db.commit()
    cur.close()
    return jsonify({'mensaje': 'Estado actualizado correctamente'})

@app.route('/api/reportes/<int:reporte_id>/resolver', methods=['PUT'])
@admin_required
def api_resolver_reporte(reporte_id):
    db = get_db()
    cur = db.cursor()
    cur.execute(
        "UPDATE reportes SET estado='resuelto', resuelto_en=NOW() WHERE id=%s",
        (reporte_id,)
    )
    db.commit()
    cur.close()
    return jsonify({'mensaje': 'Reporte marcado como resuelto'})

@app.route('/api/favoritos', methods=['GET'])
@login_required
def api_get_favoritos():
    cur = get_db().cursor()
    cur.execute("""
        SELECT f.id, f.alias, n.id AS nodo_id, n.nombre, n.tipo, n.svg_id
        FROM favoritos f
        JOIN nodos n ON f.nodo_id = n.id
        WHERE f.usuario_id = %s
    """, (session['usuario_id'],))
    favs = cur.fetchall()
    cur.close()
    return jsonify(favs)

@app.route('/api/favoritos', methods=['POST'])
@login_required
def api_agregar_favorito():
    data    = request.get_json()
    nodo_id = data.get('nodo_id')
    alias   = data.get('alias', '')

    if not nodo_id:
        return jsonify({'error': 'nodo_id requerido'}), 400

    try:
        db = get_db()
        cur = db.cursor()
        cur.execute(
            "INSERT INTO favoritos (usuario_id, nodo_id, alias) VALUES (%s,%s,%s)",
            (session['usuario_id'], nodo_id, alias)
        )
        db.commit()
        cur.close()
        return jsonify({'mensaje': 'Guardado en favoritos'}), 201
    except Exception:
        return jsonify({'error': 'Ya está en favoritos'}), 409

@app.route('/api/favoritos/<int:fav_id>', methods=['DELETE'])
@login_required
def api_eliminar_favorito(fav_id):
    db = get_db()
    cur = db.cursor()
    cur.execute(
        "DELETE FROM favoritos WHERE id=%s AND usuario_id=%s",
        (fav_id, session['usuario_id'])
    )
    db.commit()
    cur.close()
    return jsonify({'mensaje': 'Eliminado de favoritos'})


if __name__ == '__main__':
    app.run(debug=True)