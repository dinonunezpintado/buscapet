
const { createHash, randomUUID } = require('node:crypto');
const {
  getApps,
  initializeApp,
  cert,
  applicationDefault,
} = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');

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

module.exports = async function handler(req, res) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');

    return res.status(405).json({
      error: 'Metodo no permitido. Utiliza POST.',
    });
  }

  try {
    const autorizacion = req.headers.authorization || '';
    const coincidencia = autorizacion.match(/^Bearer\s+(.+)$/i);

    if (!coincidencia) {
      return res.status(401).json({
        error: 'Debes iniciar sesion para subir una imagen.',
      });
    }

    const usuario = await getAuth().verifyIdToken(coincidencia[1]);

    const tipoContenido = req.headers['content-type'] || '';

    if (!tipoContenido.toLowerCase().startsWith('application/json')) {
      return res.status(415).json({
        error: 'El contenido debe ser JSON.',
      });
    }

    const { formato, tamanoBytes } = req.body || {};

    const formatosPermitidos = ['jpg', 'jpeg', 'png', 'webp'];
    const formatoNormalizado = String(formato || '').toLowerCase();

    if (!formatosPermitidos.includes(formatoNormalizado)) {
      return res.status(400).json({
        error: 'Formato no permitido. Utiliza JPG, PNG o WebP.',
      });
    }

    if (
      !Number.isSafeInteger(tamanoBytes) ||
      tamanoBytes < 1 ||
      tamanoBytes > 5 * 1024 * 1024
    ) {
      return res.status(400).json({
        error: 'La imagen debe pesar como maximo 5 MB.',
      });
    }

    const cloudName = process.env.CLOUDINARY_CLOUD_NAME;
    const apiKey = process.env.CLOUDINARY_API_KEY;
    const apiSecret = process.env.CLOUDINARY_API_SECRET;

    if (!cloudName || !apiKey || !apiSecret) {
      console.error('Falta configurar alguna variable de Cloudinary.');

      return res.status(500).json({
        error: 'El servicio de imagenes no esta configurado.',
      });
    }

    const timestamp = Math.floor(Date.now() / 1000);
    const publicId = randomUUID();
    const folder = 'buscapet/mascotas';
    const allowedFormats = 'jpg,png,webp';

    const parametros = {
      allowed_formats: allowedFormats,
      folder,
      public_id: publicId,
      timestamp,
    };

    const cadenaFirma = Object.keys(parametros)
      .sort()
      .map((clave) => `${clave}=${parametros[clave]}`)
      .join('&');

    const signature = createHash('sha1')
      .update(cadenaFirma + apiSecret)
      .digest('hex');

    return res.status(200).json({
      cloudName,
      apiKey,
      timestamp,
      folder,
      publicId,
      signature,
      allowedFormats,
      usuarioId: usuario.uid,
    });
  } catch (error) {
    if (
      error.code === 'auth/argument-error' ||
      error.code === 'auth/id-token-expired' ||
      error.code === 'auth/invalid-id-token'
    ) {
      return res.status(401).json({
        error: 'La sesion no es valida o vencio. Inicia sesion nuevamente.',
      });
    }

    console.error('Error al preparar la subida de imagen:', error);

    return res.status(500).json({
      error: 'No se pudo preparar la subida de imagen.',
    });
  }
};
