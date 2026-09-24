import {
  applicationDefault,
  getApps,
  initializeApp,
} from 'firebase-admin/app';

import { getFirestore } from 'firebase-admin/firestore';

import { getMessaging } from 'firebase-admin/messaging';

if (getApps().length === 0) {
  initializeApp({
    credential: applicationDefault(),
  });
}

const firestore = getFirestore();
const mensajeria = getMessaging();

export default async function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({
      error: 'Este endpoint requiere una solicitud GET.',
    });
  }

  try {
    const usuarioId = req.query.usuarioId;

    if (!usuarioId) {
      return res.status(400).json({
        error: 'Debes enviar el usuarioId.',
      });
    }

    const documentoUsuario = await firestore
      .collection('usuarios')
      .doc(usuarioId)
      .get();

    if (!documentoUsuario.exists) {
      return res.status(404).json({
        error: 'No se encontró el usuario.',
      });
    }

    const datosUsuario = documentoUsuario.data();

    const tokenFCM = datosUsuario?.tokenFCM;

    if (!tokenFCM) {
      return res.status(400).json({
        error: 'El usuario no tiene un token FCM registrado.',
      });
    }

    const respuesta = await mensajeria.send({
      token: tokenFCM,
      notification: {
        title: 'BuscaPet',
        body: 'Esta es una notificación enviada desde la API.',
      },
    });

    return res.status(200).json({
      mensaje: 'Notificación enviada correctamente.',
      messageId: respuesta,
    });
  } catch (error) {
    console.error(
      'ERROR AL ENVIAR NOTIFICACIÓN:',
      error,
    );

    return res.status(500).json({
      error: 'No se pudo enviar la notificación.',
    });
  }
}