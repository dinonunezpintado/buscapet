
class Publicacion {
  final String id;
  final String nombreMascota;
  final String tipo;
  final String especie;
  final String raza;
  final String color;
  final String tamano;
  final String sexo;
  final String ubicacion;
  final String descripcion;
  final String urlImagen;
  final bool destacada;
  final DateTime? fechaCreacion;
  final double? latitud;
  final double? longitud;

  Publicacion({
    required this.id,
    required this.nombreMascota,
    required this.tipo,
    required this.especie,
    required this.raza,
    required this.color,
    required this.tamano,
    required this.sexo,
    required this.ubicacion,
    required this.descripcion,
    this.urlImagen = '',
    required this.destacada,
    this.fechaCreacion,
    this.latitud,
    this.longitud,
  });

  factory Publicacion.fromJson(Map<String, dynamic> json) {
    DateTime? fecha;

    final valorFecha = json['fechaCreacion'];

    if (valorFecha is String && valorFecha.isNotEmpty) {
      fecha = DateTime.tryParse(valorFecha);
    } else if (valorFecha is int) {
      fecha = DateTime.fromMillisecondsSinceEpoch(valorFecha);
    }

    double? convertirCoordenada(dynamic valor) {
      if (valor is num) {
        return valor.toDouble();
      }

      if (valor is String) {
        return double.tryParse(valor);
      }

      return null;
    }

    return Publicacion(
      id: json['id']?.toString() ?? '',
      nombreMascota: json['nombreMascota']?.toString() ??
          json['nombre']?.toString() ??
          '',
      tipo: json['tipo']?.toString() ?? '',
      especie: json['especie']?.toString() ?? '',
      raza: json['raza']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      tamano: json['tamano']?.toString() ??
          json['tamaño']?.toString() ??
          '',
      sexo: json['sexo']?.toString() ?? '',
      ubicacion: json['ubicacion']?.toString() ??
          json['localidad']?.toString() ??
          '',
      descripcion: json['descripcion']?.toString() ?? '',
      urlImagen: json['urlImagen']?.toString() ?? '',
      destacada: json['destacada'] == true,
      fechaCreacion: fecha,
      latitud: convertirCoordenada(json['latitud']),
      longitud: convertirCoordenada(json['longitud']),
    );
  }
}
