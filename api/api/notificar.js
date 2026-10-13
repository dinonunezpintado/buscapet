
import { applicationDefault, getApps, initializeApp } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';

if (getApps().length === 0) {
  initializeApp({
    credential: applicationDefault(),
    projectId: 'buscapet-89e1e',
  });
}

const db = getFirestore();
const mensajeria = getMessaging();

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({
      error: 'Método no permitido. Utilizá POST.',
    });
  }

  try {
    const { usuarioId, titulo, mensaje } = req.body || {};

    if (!usuarioId || !titulo || !mensaje) {
      return res.status(400).json({
        error: 'Debés completar el ID del usuario, el título y el mensaje.',
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
      token: token,
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
      error: 'No se pudo enviar la notificación. Revisá la terminal de la API.',
    });
  }
}
