
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
  if (req.method !== 'GET') {
    res.setHeader('Allow', 'GET');

    return res.status(405).json({
      error: 'Método no permitido.',
    });
  }

  try {
    const resultado = await getFirestore()
      .collection('publicaciones')
      .get();

    const publicaciones = resultado.docs.map((documento) => {
      const datos = documento.data();
      const valorFecha = datos.fechaCreacion;

      let fechaCreacion = null;

      if (valorFecha && typeof valorFecha.toDate === 'function') {
        fechaCreacion = valorFecha.toDate().toISOString();
      } else if (valorFecha instanceof Date) {
        fechaCreacion = valorFecha.toISOString();
      } else if (typeof valorFecha === 'string') {
        fechaCreacion = valorFecha;
      } else if (typeof valorFecha === 'number') {
        fechaCreacion = new Date(valorFecha).toISOString();
      }

      return {
        id: documento.id,
        nombreMascota: datos.nombreMascota || '',
        tipo: datos.tipo || '',
        especie: datos.especie || '',
        raza: datos.raza || '',
        color: datos.color || '',
        tamano: datos.tamano || datos['tamaño'] || '',
        sexo: datos.sexo || '',
        ubicacion: datos.ubicacion || '',
        descripcion: datos.descripcion || '',
        urlImagen: datos.urlImagen || '',
        destacada: datos.destacada === true,
        fechaCreacion,
      };
    });

    publicaciones.sort((a, b) => {
      if (!a.fechaCreacion && !b.fechaCreacion) return 0;
      if (!a.fechaCreacion) return 1;
      if (!b.fechaCreacion) return -1;

      return new Date(b.fechaCreacion) - new Date(a.fechaCreacion);
    });

    return res.status(200).json({
      cantidad: publicaciones.length,
      publicaciones,
    });
  } catch (error) {
    console.error('Error al obtener publicaciones:', error);

    return res.status(500).json({
      error: 'No se pudieron cargar las publicaciones.',
    });
  }
};
