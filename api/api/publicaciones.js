
export default function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({
      error: 'Método no permitido.',
    });
  }

  const publicaciones = [
    {
      id: 'pub001',
      nombreMascota: 'Milo',
      tipo: 'Perdida',
      especie: 'Perro',
      raza: 'Golden Retriever',
      color: 'Dorado',
      tamaño: 'Grande',
      sexo: 'Macho',
      ubicacion: 'Rivera',
      descripcion: 'Se perdió y lleva collar azul.',
      destacada: false,
    },
    {
      id: 'pub002',
      nombreMascota: 'Lola',
      tipo: 'Encontrada',
      especie: 'Perro',
      raza: 'Labrador',
      color: 'Negro',
      tamaño: 'Mediano',
      sexo: 'Hembra',
      ubicacion: 'Tranqueras',
      descripcion: 'Fue encontrada cerca de una plaza.',
      destacada: true,
    },
  ];

  return res.status(200).json({
    cantidad: publicaciones.length,
    publicaciones: publicaciones,
  });
}
