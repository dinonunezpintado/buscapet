const {
  getApps,
  initializeApp,
  cert,
  applicationDefault,
} = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

const credencialesFirebase = process.env.FIREBASE_SERVICE_ACCOUNT;
if (getApps().length === 0) {
  if (credencialesFirebase) {
    initializeApp({ credential: cert(JSON.parse(credencialesFirebase)), projectId: 'buscapet-89e1e' });
  } else {
    initializeApp({ credential: applicationDefault(), projectId: 'buscapet-89e1e' });
  }
}

function convertirFecha(valor) {
  if (valor && typeof valor.toDate === 'function') return valor.toDate().toISOString();
  if (valor instanceof Date) return valor.toISOString();
  if (typeof valor === 'string' && valor.trim() !== '') {
    const fecha = new Date(valor);
    return Number.isNaN(fecha.getTime()) ? null : fecha.toISOString();
  }
  if (typeof valor === 'number') {
    const fecha = new Date(valor);
    return Number.isNaN(fecha.getTime()) ? null : fecha.toISOString();
  }
  return null;
}

function convertirCoordenada(valor) {
  if (typeof valor === 'number' && Number.isFinite(valor)) return valor;
  if (typeof valor === 'string' && valor.trim() !== '') {
    const numero = Number(valor);
    return Number.isFinite(numero) ? numero : null;
  }
  return null;
}

module.exports = async function handler(req, res) {
  if (req.method !== 'GET') {
    res.setHeader('Allow', 'GET');
    return res.status(405).json({ error: 'Método no permitido.' });
  }
  try {
    const resultado = await getFirestore().collection('publicaciones').get();
    const ahora = Date.now();
    const publicaciones = resultado.docs.map((documento) => {
      const datos = documento.data();
      const fechaInicioPremium = convertirFecha(datos.fechaInicioPremium);
      const fechaFinPremium = convertirFecha(datos.fechaFinPremium);
      const tipo = datos.tipo || '';
      const esPerdida = !String(tipo).toLowerCase().includes('encontr');
      // El estado "simulado" solo habilita la demostración académica. En producción,
      // debe reemplazarse por "aprobado" confirmado por el backend/proveedor de pagos.
      const pagoValido = datos.estadoPago === 'aprobado' || datos.estadoPago === 'simulado';
      const premiumVigente = esPerdida && datos.esPremium === true && pagoValido &&
        fechaFinPremium !== null && new Date(fechaFinPremium).getTime() > ahora;
      return {
        id: documento.id,
        usuarioId: datos.usuarioId || '',
        nombreMascota: datos.nombreMascota || '',
        tipo,
        especie: datos.especie || '',
        raza: datos.raza || '',
        color: datos.color || '',
        tamano: datos.tamano || datos['tamaño'] || '',
        sexo: datos.sexo || '',
        ubicacion: datos.ubicacion || '',
        descripcion: datos.descripcion || '',
        urlImagen: datos.urlImagen || '',
        esPremium: premiumVigente,
        destacada: premiumVigente,
        estadoPlan: premiumVigente ? 'premium' : 'free',
        estadoPago: datos.estadoPago || 'no_aplica',
        fechaInicioPremium,
        fechaFinPremium,
        estado: datos.estado || 'activa',
        reencuentroConfirmado: datos.reencuentroConfirmado === true,
        fechaReencuentro: convertirFecha(datos.fechaReencuentro),
        fechaCreacion: convertirFecha(datos.fechaCreacion),
        latitud: convertirCoordenada(datos.latitud),
        longitud: convertirCoordenada(datos.longitud),
      };
    });
    publicaciones.sort((a, b) => {
      if (a.esPremium !== b.esPremium) return a.esPremium ? -1 : 1;
      if (!a.fechaCreacion && !b.fechaCreacion) return 0;
      if (!a.fechaCreacion) return 1;
      if (!b.fechaCreacion) return -1;
      return new Date(b.fechaCreacion) - new Date(a.fechaCreacion);
    });
    return res.status(200).json({ cantidad: publicaciones.length, publicaciones });
  } catch (error) {
    console.error('Error al obtener publicaciones:', error);
    return res.status(500).json({ error: 'No se pudieron cargar las publicaciones.' });
  }
};
