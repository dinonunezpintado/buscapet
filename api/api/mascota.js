export default function handler(req, res) {
  if (req.method !== 'GET') {
    return res.status(405).json({
      error: 'Método no permitido.',
    });
  }

  const mascotas = [
    {
      id: 'mas001',
      nombre: 'Milo',
      especie: 'Perro',
      raza: 'Golden Retriever',
      color: 'Dorado',
      tamaño: 'Grande',
      sexo: 'Macho',
      caracteristicas: 'Lleva collar azul.',
    },
    {
      id: 'mas002',
      nombre: 'Lola',
      especie: 'Perro',
      raza: 'Labrador',
      color: 'Negro',
      tamaño: 'Mediano',
      sexo: 'Hembra',
      caracteristicas: 'Tiene una mancha blanca en el pecho.',
    },
    {
      id: 'mas003',
      nombre: 'Simba',
      especie: 'Gato',
      raza: 'Común europeo',
      color: 'Atigrado',
      tamaño: 'Pequeño',
      sexo: 'Macho',
      caracteristicas: 'Tiene ojos verdes.',
    },
  ];

  const id = req.query.id;

  const mascota = mascotas.find(
    (item) => item.id === id
  );

  if (!mascota) {
    return res.status(404).json({
      error: 'No se encontró la mascota.',
    });
  }

  return res.status(200).json({
    mascota: mascota,
  });
}