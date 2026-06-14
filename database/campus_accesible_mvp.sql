-- Campus Accesible - Import para Railway (base de datos 'railway')

CREATE TABLE IF NOT EXISTS usuarios (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(100)  NOT NULL,
  email         VARCHAR(100)  NOT NULL UNIQUE,
  password_hash VARCHAR(255)  NOT NULL,
  rol           ENUM('estudiante','funcionario','admin') DEFAULT 'estudiante',
  creado_en     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS nodos (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  svg_id        VARCHAR(100)  NOT NULL UNIQUE,
  nombre        VARCHAR(150)  NOT NULL,
  tipo          ENUM('sala','edificio','bano_accesible','ascensor','rampa','zona_tranquila','entrada','escalera','punto_interes') NOT NULL,
  descripcion   TEXT,
  piso          TINYINT DEFAULT 0,
  activo        BOOLEAN DEFAULT TRUE,
  coord_x       FLOAT NOT NULL,
  coord_y       FLOAT NOT NULL
);

CREATE TABLE IF NOT EXISTS conexiones (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  nodo_origen    INT NOT NULL,
  nodo_destino   INT NOT NULL,
  distancia      FLOAT NOT NULL DEFAULT 1.0,
  tiene_escalera BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (nodo_origen)  REFERENCES nodos(id) ON DELETE CASCADE,
  FOREIGN KEY (nodo_destino) REFERENCES nodos(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS reportes (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  nodo_id       INT NOT NULL,
  usuario_id    INT,
  tipo          ENUM('rampa_bloqueada','ascensor_fuera','camino_cortado','otro') NOT NULL,
  descripcion   TEXT,
  estado        ENUM('activo','resuelto') DEFAULT 'activo',
  creado_en     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  resuelto_en   TIMESTAMP NULL,
  FOREIGN KEY (nodo_id)    REFERENCES nodos(id) ON DELETE CASCADE,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS favoritos (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id  INT NOT NULL,
  nodo_id     INT NOT NULL,
  alias       VARCHAR(100),
  creado_en   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_usuario_nodo (usuario_id, nodo_id),
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  FOREIGN KEY (nodo_id)    REFERENCES nodos(id)    ON DELETE CASCADE
);

-- Nodos
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('entrada-1', 'Entrada Principal', 'entrada', 'Acceso principal del campus (sector poniente)', 0, 15, 233.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('entrada-2', 'Entrada Secundaria', 'entrada', 'Acceso secundario del campus (sector oriente)', 0, 428, 368.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('edificio-m1', 'Edificio M1', 'edificio', 'Edificio M1', 0, 63, 191);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('edificio-m2', 'Edificio M2', 'edificio', 'Edificio M2', 0, 148, 178.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('edificio-m3', 'Edificio M3', 'edificio', 'Edificio M3', 0, 250, 178.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('edificio-m5', 'Edificio M5', 'edificio', 'Edificio M5', 0, 426.5, 322.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('edificio-m6', 'Edificio M6', 'edificio', 'Edificio M6', 0, 493, 192);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('edificio-m7', 'Edificio M7', 'edificio', 'Edificio M7', 0, 329, 91);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('edificio-m8', 'Edificio M8', 'edificio', 'Edificio M8', 0, 427, 214);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('edificio-biblioteca', 'Biblioteca', 'edificio', 'Biblioteca central del campus', 0, 63, 80);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('edificio-gimnasio', 'Gimnasio', 'edificio', 'Gimnasio del campus', 0, 176.5, 356);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('edificio-sesaes', 'SESAES', 'edificio', 'SESAES (servicios estudiantiles)', 0, 63, 309);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('edificio-transa', 'Transa', 'edificio', 'Casino / cafeteria Transa', 0, 336, 174.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('rampa-entrada-1', 'Rampa Entrada Principal', 'rampa', 'Rampa de acceso en la entrada principal', 0, 15, 229);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('rampa-entrada-2', 'Rampa Entrada Secundaria', 'rampa', 'Rampa de acceso en la entrada secundaria', 0, 443.5, 368.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('rampa-biblioteca', 'Rampa Biblioteca', 'rampa', 'Rampa de acceso a la biblioteca', 0, 138, 122.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('rampa-transa', 'Rampa Transa', 'rampa', 'Rampa de acceso al sector Transa', 0, 304.5, 230);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('rampa-m7-1', 'Rampa M7 norte', 'rampa', 'Rampa de acceso a Edificio M7 lado norte', 0, 261.5, 117.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('rampa-m7-2', 'Rampa M7 sur', 'rampa', 'Rampa de acceso a Edificio M7 lado sur', 0, 413.5, 117.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('ascensor-m7', 'Ascensor M7', 'ascensor', 'Ascensor del Edificio M7', 0, 328.5, 93.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('ascensor-biblioteca', 'Ascensor Biblioteca', 'ascensor', 'Ascensor de la Biblioteca', 0, 60.5, 104.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('bano-m2-mujer', 'Bano Accesible M2 Mujeres', 'bano_accesible', 'Bano accesible sector mujeres', 0, 193.5, 245.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('bano-m2-hombre', 'Bano Accesible M2 Hombres', 'bano_accesible', 'Bano accesible sector hombres', 0, 205.5, 245.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('kiosko-1', 'Kiosko 1', 'punto_interes', 'Kiosko al aire libre cerca de Biblioteca', 0, 183, 74);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('kiosko-2', 'Kiosko 2', 'punto_interes', 'Kiosko al aire libre cerca de Transa', 0, 332, 280);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('cancha-baby', 'Cancha Baby', 'punto_interes', 'Cancha de baby futbol', 0, 260, 261.3);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('mesas-m2-m3', 'Mesas M2-M3', 'zona_tranquila', 'Zona de mesas exteriores entre M2 y M3', 0, 199, 178.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('bancas-m6', 'Bancas M6', 'punto_interes', 'Zona de bancas cerca de M6', 0, 544, 185);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('escaleras-m1-1', 'Escaleras acceso M1', 'escalera', 'Escaleras de acceso exterior al Edificio M1', 0, 57.5, 259.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('escaleras-m1-2', 'Escaleras M1 sector M2', 'escalera', 'Escaleras exteriores de M1 colindantes con M2', 0, 101, 161);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('escaleras-m2', 'Escaleras acceso M2', 'escalera', 'Escaleras de acceso exterior al Edificio M2', 0, 141.5, 246.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('escaleras-m3', 'Escaleras acceso M3', 'escalera', 'Escaleras de acceso exterior al Edificio M3', 0, 243.5, 246.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('escaleras-m7', 'Escaleras acceso M7', 'escalera', 'Escaleras de acceso exterior al Edificio M7', 0, 261.5, 126);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('escaleras-biblioteca', 'Escaleras Biblioteca', 'escalera', 'Escaleras de acceso a la Biblioteca', 0, 144.5, 107);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('escaleras-transa', 'Escaleras Transa', 'escalera', 'Escaleras de acceso al sector Transa', 0, 304.5, 236.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-desarrollo-estudiantil', 'Desarrollo Estudiantil', 'sala', 'Oficina de Desarrollo Estudiantil M1 piso 1', 1, 30.5, 35);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-bienestar-estudiantil', 'Bienestar Estudiantil', 'sala', 'Oficina de Bienestar Estudiantil M1 piso 1', 1, 123.5, 35);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-escaleras-mecanica', 'Escaleras Escuela de Mecanica', 'escalera', 'Escalera principal M1 piso 1', 1, 89.4, 88.8);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('escaleras-m1-1-2-p1', 'Escaleras M1 piso1-piso2 lado piso1', 'escalera', 'Escalera M1 piso 1 a piso 2', 1, 117, 197.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-laboratorio-a', 'Laboratorio A', 'sala', 'Laboratorio A M1 piso 2', 2, 36.5, 130.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-laboratorio-b', 'Laboratorio B', 'sala', 'Laboratorio B M1 piso 2', 2, 36.5, 101.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-laboratorio-c', 'Laboratorio C', 'sala', 'Laboratorio C M1 piso 2', 2, 36.5, 72.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-laboratorio-d', 'Laboratorio D', 'sala', 'Laboratorio D M1 piso 2', 2, 36.5, 43.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-laboratorio-e', 'Laboratorio E', 'sala', 'Laboratorio E M1 piso 2', 2, 36.5, 14.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-laboratorio-f', 'Laboratorio F', 'sala', 'Laboratorio F M1 piso 2', 2, 144.5, 14.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-laboratorio-g', 'Laboratorio G', 'sala', 'Laboratorio G M1 piso 2', 2, 145.5, 85);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-laboratorio-h', 'Laboratorio H', 'sala', 'Laboratorio H M1 piso 2', 2, 144.5, 119);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-escuela-fisica', 'Escuela de Fisica', 'sala', 'Escuela de Fisica M1 piso 2', 2, 36.5, 184);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('escaleras-m1-1-2-p2', 'Escaleras M1 piso1-piso2 lado piso2', 'escalera', 'Escalera M1 piso 1 a piso 2 lado piso2', 2, 127, 196.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('escaleras-m1-2-3-p2', 'Escaleras M1 piso2-piso3 lado piso2', 'escalera', 'Escalera M1 piso 2 a piso 3', 2, 127, 196.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-301', 'Sala M1-301', 'sala', 'Sala M1-301 piso 3', 3, 36.5, 193);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-302', 'Sala M1-302', 'sala', 'Sala M1-302 piso 3', 3, 36.5, 135.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-303', 'Sala M1-303', 'sala', 'Sala M1-303 piso 3', 3, 36.5, 80.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-304', 'Sala M1-304', 'sala', 'Sala M1-304 piso 3', 3, 36.5, 27.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-305', 'Sala M1-305', 'sala', 'Sala M1-305 piso 3', 3, 144.5, 118);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-306', 'Sala M1-306', 'sala', 'Sala M1-306 piso 3', 3, 144.5, 84);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-307', 'Sala M1-307', 'sala', 'Sala M1-307 piso 3', 3, 144.5, 14.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('escaleras-m1-2-3-p3', 'Escaleras M1 piso2-piso3 lado piso3', 'escalera', 'Escalera M1 piso 2 a piso 3 lado piso3', 3, 127, 199.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('escaleras-m1-3-4-p3', 'Escaleras M1 piso3-piso4 lado piso3', 'escalera', 'Escalera M1 piso 3 a piso 4', 3, 127, 199.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-laboratorio-1', 'Laboratorio 1', 'sala', 'Laboratorio 1 M1 piso 4', 4, 36.5, 122.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-laboratorio-2', 'Laboratorio 2', 'sala', 'Laboratorio 2 M1 piso 4', 4, 36.5, 52.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-laboratorio-3', 'Laboratorio 3', 'sala', 'Laboratorio 3 M1 piso 4', 4, 36.5, 17.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-laboratorio-4', 'Laboratorio 4', 'sala', 'Laboratorio 4 M1 piso 4', 4, 36.5, 87.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-laboratorio-5', 'Laboratorio 5', 'sala', 'Laboratorio 5 M1 piso 4', 4, 144.5, 120);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-laboratorio-6', 'Laboratorio 6', 'sala', 'Laboratorio 6 M1 piso 4', 4, 144.5, 80);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m1-laboratorio-7', 'Laboratorio 7', 'sala', 'Laboratorio 7 M1 piso 4', 4, 144.5, 14.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('escaleras-m1-3-4-p4', 'Escaleras M1 piso3-piso4 lado piso4', 'escalera', 'Escalera M1 piso 3 a piso 4 lado piso4', 4, 127, 205.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m3-101', 'Sala M3-101', 'sala', 'Sala M3-101 piso 1', 1, 128, 139.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m3-102', 'Sala M3-102', 'sala', 'Sala M3-102 piso 1', 1, 128.5, 100.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m3-103', 'Sala M3-103', 'sala', 'Sala M3-103 piso 1', 1, 128.5, 60.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m3-104', 'Sala M3-104', 'sala', 'Sala M3-104 piso 1', 1, 129, 20);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m3-sala-industria', 'Sala de Industria', 'sala', 'Sala de Industria M3 piso 1', 1, 38, 111.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('escaleras-m3-1-2-p1', 'Escaleras M3 piso1-piso2 lado piso1', 'escalera', 'Escalera M3 piso 1 a piso 2', 1, 129.5, 199);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m3-201', 'Sala M3-201', 'sala', 'Sala M3-201 piso 2', 2, 127, 135.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m3-202', 'Sala M3-202', 'sala', 'Sala M3-202 piso 2', 2, 127.5, 97.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m3-203', 'Sala M3-203', 'sala', 'Sala M3-203 piso 2', 2, 127.5, 58);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m3-204', 'Sala M3-204', 'sala', 'Sala M3-204 piso 2', 2, 128, 19);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('bano-m3-piso2', 'Bano Accesible M3 piso 2', 'bano_accesible', 'Bano accesible M3 piso 2', 2, 36, 13);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('escaleras-m3-1-2-p2', 'Escaleras M3 piso1-piso2 lado piso2', 'escalera', 'Escalera M3 piso 1 a piso 2 lado piso2', 2, 97, 207.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('escaleras-m3-2-3-p2', 'Escaleras M3 piso2-piso3 lado piso2', 'escalera', 'Escalera M3 piso 2 a piso 3', 2, 97, 207.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m3-301', 'Sala M3-301', 'sala', 'Sala M3-301 piso 3', 3, 132, 137.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m3-302', 'Sala M3-302', 'sala', 'Sala M3-302 piso 3', 3, 132.5, 103);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m3-303', 'Sala M3-303', 'sala', 'Sala M3-303 piso 3', 3, 132.5, 52);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m3-304', 'Sala M3-304', 'sala', 'Sala M3-304 piso 3', 3, 133, 17);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('bano-m3-piso3', 'Bano Accesible M3 piso 3', 'bano_accesible', 'Bano accesible M3 piso 3', 3, 41, 13);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('escaleras-m3-2-3-p3', 'Escaleras M3 piso2-piso3 lado piso3', 'escalera', 'Escalera M3 piso 2 a piso 3 lado piso3', 3, 97, 207.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('escaleras-m3-3-4-p3', 'Escaleras M3 piso3-piso4 lado piso3', 'escalera', 'Escalera M3 piso 3 a piso 4', 3, 148, 79.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m3-sala-computacion-1', 'Sala de Computacion 1', 'sala', 'Sala de Computacion 1 M3 piso 4', 4, 90.5, 39.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('m3-sala-computacion-2', 'Sala de Computacion 2', 'sala', 'Sala de Computacion 2 M3 piso 4', 4, 90.5, 187.5);
INSERT INTO nodos (svg_id, nombre, tipo, descripcion, piso, coord_x, coord_y) VALUES ('escaleras-m3-3-4-p4', 'Escaleras M3 piso3-piso4 lado piso4', 'escalera', 'Escalera M3 piso 3 a piso 4 lado piso4', 4, 155, 113.5);

-- Conexiones
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-escaleras-mecanica'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-1-2-p1'),11.2,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-desarrollo-estudiantil'),(SELECT id FROM nodos WHERE svg_id='m1-escaleras-mecanica'),8.0,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-bienestar-estudiantil'),(SELECT id FROM nodos WHERE svg_id='m1-escaleras-mecanica'),6.4,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='escaleras-m1-1-2-p1'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-1-2-p2'),5,TRUE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='escaleras-m1-2-3-p2'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-2-3-p3'),5,TRUE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='escaleras-m1-3-4-p3'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-3-4-p4'),5,TRUE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='escaleras-m1-1-2-p2'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-2-3-p2'),1,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='escaleras-m1-2-3-p3'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-3-4-p3'),1,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-laboratorio-a'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-1-2-p2'),11.2,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-laboratorio-b'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-1-2-p2'),13.1,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-laboratorio-c'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-1-2-p2'),15.4,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-laboratorio-d'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-1-2-p2'),17.8,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-laboratorio-e'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-1-2-p2'),20.3,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-laboratorio-f'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-1-2-p2'),18.3,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-laboratorio-g'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-1-2-p2'),11.3,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-laboratorio-h'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-1-2-p2'),7.9,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-escuela-fisica'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-1-2-p2'),9.1,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-301'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-2-3-p3'),9.1,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-302'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-2-3-p3'),11.1,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-303'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-2-3-p3'),15.0,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-304'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-2-3-p3'),19.4,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-305'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-2-3-p3'),8.3,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-306'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-2-3-p3'),11.7,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-307'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-2-3-p3'),18.6,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-laboratorio-1'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-3-4-p4'),12.3,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-laboratorio-2'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-3-4-p4'),17.8,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-laboratorio-3'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-3-4-p4'),20.9,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-laboratorio-4'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-3-4-p4'),14.9,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-laboratorio-5'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-3-4-p4'),8.7,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-laboratorio-6'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-3-4-p4'),12.7,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m1-laboratorio-7'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-3-4-p4'),19.2,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m3-101'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-1-2-p1'),6.0,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m3-102'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-1-2-p1'),9.9,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m3-103'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-1-2-p1'),13.9,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m3-104'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-1-2-p1'),17.9,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m3-sala-industria'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-1-2-p1'),12.7,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='escaleras-m3-1-2-p1'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-1-2-p2'),5,TRUE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='escaleras-m3-1-2-p2'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-2-3-p2'),1,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='escaleras-m3-2-3-p2'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-2-3-p3'),5,TRUE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='escaleras-m3-2-3-p3'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-3-4-p3'),1,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='escaleras-m3-3-4-p3'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-3-4-p4'),5,TRUE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m3-201'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-2-3-p2'),7.8,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m3-202'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-2-3-p2'),11.4,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m3-203'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-2-3-p2'),15.3,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m3-204'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-2-3-p2'),19.1,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='bano-m3-piso2'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-2-3-p2'),20.4,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m3-301'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-2-3-p3'),7.8,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m3-302'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-2-3-p3'),11.0,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m3-303'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-2-3-p3'),16.0,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m3-304'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-2-3-p3'),19.4,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='bano-m3-piso3'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-2-3-p3'),20.2,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m3-sala-computacion-1'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-3-4-p4'),9.8,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='m3-sala-computacion-2'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-3-4-p4'),9.8,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='escaleras-m1-1'),(SELECT id FROM nodos WHERE svg_id='m1-escaleras-mecanica'),8,TRUE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='escaleras-m3'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3-1-2-p1'),8,TRUE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='entrada-1'),(SELECT id FROM nodos WHERE svg_id='rampa-entrada-1'),0.5,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='rampa-entrada-1'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-1'),5.2,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='entrada-1'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-1'),5.0,TRUE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='escaleras-m1-1'),(SELECT id FROM nodos WHERE svg_id='edificio-m1'),6.9,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-m1'),(SELECT id FROM nodos WHERE svg_id='escaleras-m1-2'),4.8,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='escaleras-m1-2'),(SELECT id FROM nodos WHERE svg_id='edificio-m2'),5.0,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-m2'),(SELECT id FROM nodos WHERE svg_id='escaleras-m2'),6.8,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='escaleras-m2'),(SELECT id FROM nodos WHERE svg_id='mesas-m2-m3'),8.9,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='mesas-m2-m3'),(SELECT id FROM nodos WHERE svg_id='edificio-m3'),5.1,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-m3'),(SELECT id FROM nodos WHERE svg_id='escaleras-m3'),6.8,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='mesas-m2-m3'),(SELECT id FROM nodos WHERE svg_id='bano-m2-mujer'),6.7,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='mesas-m2-m3'),(SELECT id FROM nodos WHERE svg_id='bano-m2-hombre'),6.7,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-m1'),(SELECT id FROM nodos WHERE svg_id='edificio-biblioteca'),11.1,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-biblioteca'),(SELECT id FROM nodos WHERE svg_id='escaleras-biblioteca'),8.6,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='escaleras-biblioteca'),(SELECT id FROM nodos WHERE svg_id='rampa-biblioteca'),1.7,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-biblioteca'),(SELECT id FROM nodos WHERE svg_id='ascensor-biblioteca'),2.5,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-biblioteca'),(SELECT id FROM nodos WHERE svg_id='kiosko-1'),12.0,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-m3'),(SELECT id FROM nodos WHERE svg_id='edificio-transa'),8.6,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-transa'),(SELECT id FROM nodos WHERE svg_id='escaleras-transa'),7.0,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='escaleras-transa'),(SELECT id FROM nodos WHERE svg_id='rampa-transa'),0.7,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-transa'),(SELECT id FROM nodos WHERE svg_id='kiosko-2'),10.6,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-transa'),(SELECT id FROM nodos WHERE svg_id='escaleras-m7'),8.9,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='escaleras-m7'),(SELECT id FROM nodos WHERE svg_id='rampa-m7-1'),0.8,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='rampa-m7-1'),(SELECT id FROM nodos WHERE svg_id='edificio-m7'),7.3,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-m7'),(SELECT id FROM nodos WHERE svg_id='ascensor-m7'),0.5,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-m7'),(SELECT id FROM nodos WHERE svg_id='rampa-m7-2'),8.9,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='rampa-m7-2'),(SELECT id FROM nodos WHERE svg_id='edificio-m8'),9.7,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-m8'),(SELECT id FROM nodos WHERE svg_id='edificio-m5'),10.9,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-m5'),(SELECT id FROM nodos WHERE svg_id='edificio-m6'),14.6,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-m6'),(SELECT id FROM nodos WHERE svg_id='bancas-m6'),5.1,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-m5'),(SELECT id FROM nodos WHERE svg_id='rampa-entrada-2'),4.9,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='rampa-entrada-2'),(SELECT id FROM nodos WHERE svg_id='entrada-2'),1.6,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-m8'),(SELECT id FROM nodos WHERE svg_id='cancha-baby'),17.4,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='cancha-baby'),(SELECT id FROM nodos WHERE svg_id='edificio-gimnasio'),12.6,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-gimnasio'),(SELECT id FROM nodos WHERE svg_id='edificio-sesaes'),12.3,FALSE);
INSERT INTO conexiones (nodo_origen, nodo_destino, distancia, tiene_escalera) VALUES ((SELECT id FROM nodos WHERE svg_id='edificio-sesaes'),(SELECT id FROM nodos WHERE svg_id='edificio-m1'),11.8,FALSE);

-- Usuario admin
INSERT IGNORE INTO usuarios (nombre, email, password_hash, rol) VALUES ('Administrador', 'admin@utem.cl', 'pbkdf2:sha256:260000$placeholder$hash', 'admin');