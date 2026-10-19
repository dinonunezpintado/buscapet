
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

function respuestaError(res, estado, error) {
  return res.status(estado).json({ error });
}

async function enviarIndividual(usuarioId, titulo, mensaje) {
  const documento = await db.collection('usuarios').doc(usuarioId).get();

  if (!documento.exists) {
    return {
      estado: 404,
      resultado: { error: 'No se encontró el usuario.' },
    };
  }

  const token = documento.data()?.tokenFCM;

  if (typeof token !== 'string' || !token.trim()) {
    return {
      estado: 400,
      resultado: {
        error: 'El usuario no tiene un token de notificaciones registrado.',
      },
    };
  }

  const idMensaje = await mensajeria.send({
    token: token.trim(),
    notification: {
      title: titulo,
      body: mensaje,
    },
  });

  return {
    estado: 200,
    resultado: {
      mensaje: 'Notificación enviada correctamente.',
      enviados: 1,
      errores: 0,
      idMensaje,
    },
  };
}

async function enviarATodos(titulo, mensaje) {
  const consulta = await db.collection('usuarios').get();

  const tokens = [
    ...new Set(
      consulta.docs
        .map((documento) => documento.data()?.tokenFCM)
        .filter((token) => typeof token === 'string' && token.trim())
        .map((token) => token.trim())
    ),
  ];

  if (tokens.length === 0) {
    return {
      enviados: 0,
      errores: 0,
      totalConToken: 0,
      mensaje: 'No hay usuarios con tokens de notificación registrados.',
    };
  }

  let enviados = 0;
  let errores = 0;

  for (let inicio = 0; inicio < tokens.length; inicio += 500) {
    const grupo = tokens.slice(inicio, inicio + 500);

    const respuesta = await mensajeria.sendEachForMulticast({
      tokens: grupo,
      notification: {
        title: titulo,
        body: mensaje,
      },
    });

    enviados += respuesta.successCount;
    errores += respuesta.failureCount;
  }

  return {
    mensaje: 'Proceso de notificación masiva finalizado.',
    totalConToken: tokens.length,
    enviados,
    errores,
  };
}

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return respuestaError(res, 405, 'Método no permitido. Utilizá POST.');
  }

  if (!claveAdministrativa) {
    return respuestaError(
      res,
      503,
      'El envío de notificaciones no está configurado.'
    );
  }

  if (!validarClave(req.headers['x-admin-key'])) {
    return respuestaError(res, 401, 'No autorizado.');
  }

  const cuerpo = req.body || {};
  const modo = cuerpo.modo || 'individual';
  const usuarioId = cuerpo.usuarioId;
  const titulo = cuerpo.titulo;
  const mensaje = cuerpo.mensaje;

  if (
    typeof titulo !== 'string' ||
    typeof mensaje !== 'string' ||
    !titulo.trim() ||
    !mensaje.trim()
  ) {
    return respuestaError(res, 400, 'Completá el título y el mensaje.');
  }

  if (titulo.trim().length > 100 || mensaje.trim().length > 500) {
    return respuestaError(
      res,
      400,
      'El título admite hasta 100 caracteres y el mensaje hasta 500.'
    );
  }

  if (modo !== 'individual' && modo !== 'todos') {
    return respuestaError(res, 400, 'El modo de envío no es válido.');
  }

  if (modo === 'individual' &&
      (typeof usuarioId !== 'string' || !usuarioId.trim())) {
    return respuestaError(res, 400, 'Seleccioná un destinatario.');
  }

  try {
    if (modo === 'todos') {
      const resultado = await enviarATodos(titulo.trim(), mensaje.trim());
      return res.status(200).json(resultado);
    }

    const respuesta = await enviarIndividual(
      usuarioId.trim(),
      titulo.trim(),
      mensaje.trim()
    );

    return res.status(respuesta.estado).json(respuesta.resultado);
  } catch (error) {
    console.error('Error al enviar notificaciones:', error);

    return respuestaError(
      res,
      500,
      'Ocurrió un error al procesar el envío.'
    );
  }
}
