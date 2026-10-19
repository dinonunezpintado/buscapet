
import { timingSafeEqual } from 'node:crypto';
import {
  applicationDefault,
  cert,
  getApps,
  initializeApp,
} from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';

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
const mensajeria = getMessaging();

function validarClave(claveRecibida) {
  if (
    typeof claveAdministrativa !== 'string' ||
    claveAdministrativa.length === 0 ||
    typeof claveRecibida !== 'string'
  ) {
    return false;
  }

  const claveEsperada = Buffer.from(claveAdministrativa, 'utf8');
  const claveIngresada = Buffer.from(claveRecibida, 'utf8');

  if (claveEsperada.length !== claveIngresada.length) {
    return false;
  }

  return timingSafeEqual(claveEsperada, claveIngresada);
}

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({
      error: 'Método no permitido. Utilizá POST.',
    });
  }

  if (!claveAdministrativa) {
    return res.status(503).json({
      error: 'El envío de notificaciones no está configurado.',
    });
  }

  const claveRecibida = req.headers['x-admin-key'];

  if (!validarClave(claveRecibida)) {
    return res.status(401).json({
      error: 'No autorizado.',
    });
  }

  try {
    const { usuarioId, titulo, mensaje } = req.body || {};

    if (
      typeof usuarioId !== 'string' ||
      typeof titulo !== 'string' ||
      typeof mensaje !== 'string' ||
      !usuarioId.trim() ||
      !titulo.trim() ||
      !mensaje.trim()
    ) {
      return res.status(400).json({
        error: 'Debés completar el usuario, el título y el mensaje.',
      });
    }

    if (titulo.trim().length > 100 || mensaje.trim().length > 500) {
      return res.status(400).json({
        error: 'El título admite hasta 100 caracteres y el mensaje hasta 500.',
      });
    }

    const documento = await db
      .collection('usuarios')
      .doc(usuarioId.trim())
      .get();

    if (!documento.exists) {
      return res.status(404).json({
        error: 'No se encontró el usuario en Firestore.',
      });
    }

    const token = documento.data()?.tokenFCM;

    if (!token) {
      return res.status(400).json({
        error: 'El usuario no tiene un token de notificaciones registrado.',
      });
    }

    const respuesta = await mensajeria.send({
      token,
      notification: {
        title: titulo.trim(),
        body: mensaje.trim(),
      },
    });

    return res.status(200).json({
      mensaje: 'Notificación enviada correctamente.',
      idMensaje: respuesta,
    });
  } catch (error) {
    console.error('Error al enviar la notificación:', error);

    return res.status(500).json({
      error: 'No se pudo procesar la solicitud.',
    });
  }
}
