
import { timingSafeEqual } from 'node:crypto';
import {
  applicationDefault,
  cert,
  getApps,
  initializeApp,
} from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const claveAdministrativa = process.env.ADMIN_NOTIFICATION_KEY;
const credencialesFirebase = process.env.FIREBASE_SERVICE_ACCOUNT;

if (getApps().length === 0) {
  if (credencialesFirebase) {
    initializeApp({
      credential: cert(JSON.parse(credencialesFirebase)),
      projectId: 'buscapet-89e1e',
    });
  } else {
    initializeApp({
      credential: applicationDefault(),
      projectId: 'buscapet-89e1e',
    });
  }
}

const db = getFirestore();

function validarClave(claveRecibida) {
  if (
    typeof claveAdministrativa !== 'string' ||
    !claveAdministrativa ||
    typeof claveRecibida !== 'string'
  ) {
    return false;
  }

  const esperada = Buffer.from(claveAdministrativa, 'utf8');
  const recibida = Buffer.from(claveRecibida, 'utf8');

  if (esperada.length !== recibida.length) {
    return false;
  }

  return timingSafeEqual(esperada, recibida);
}

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Método no permitido.' });
  }

  if (!claveAdministrativa) {
    return res.status(503).json({
      error: 'La búsqueda administrativa no está configurada.',
    });
  }

  if (!validarClave(req.headers['x-admin-key'])) {
    return res.status(401).json({ error: 'No autorizado.' });
  }

  const termino = String(req.query?.q || '').trim().toLowerCase();

  if (termino.length < 2) {
    return res.status(400).json({
      error: 'Ingresá al menos dos caracteres para buscar.',
    });
  }

  try {
    const consulta = await db.collection('usuarios').limit(500).get();

    const usuarios = consulta.docs
      .map((documento) => {
        const datos = documento.data();

        return {
          uid: documento.id,
          nombre: String(datos.nombre || '').trim(),
          apellido: String(datos.apellido || '').trim(),
          email: String(datos.email || '').trim(),
        };
      })
      .filter((usuario) => {
        const texto = [
          usuario.nombre,
          usuario.apellido,
          usuario.email,
        ].join(' ').toLowerCase();

        return texto.includes(termino);
      })
      .slice(0, 30);

    return res.status(200).json({ usuarios });
  } catch (error) {
    console.error('Error al buscar usuarios:', error);

    return res.status(500).json({
      error: 'No se pudo completar la búsqueda de usuarios.',
    });
  }
}
