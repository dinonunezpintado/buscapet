class Publicacion {
  final String id;
  final String usuarioId;
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
  final bool esPremium;
  final String estadoPlan;
  final String estadoPago;
  final DateTime? fechaInicioPremium;
  final DateTime? fechaFinPremium;
  final DateTime? fechaCreacion;
  final double? latitud;
  final double? longitud;
  final String estado;
  final bool reencuentroConfirmado;
  final DateTime? fechaReencuentro;

  Publicacion({
    required this.id,
    this.usuarioId = '',
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
    this.esPremium = false,
    this.estadoPlan = 'free',
    this.estadoPago = 'no_aplica',
    this.fechaInicioPremium,
    this.fechaFinPremium,
    this.fechaCreacion,
    this.latitud,
    this.longitud,
    this.estado = 'activa',
    this.reencuentroConfirmado = false,
    this.fechaReencuentro,
  });

  factory Publicacion.fromJson(Map<String, dynamic> json) {
    DateTime? convertirFecha(dynamic valor) {
      if (valor is String && valor.isNotEmpty) return DateTime.tryParse(valor);
      if (valor is int) return DateTime.fromMillisecondsSinceEpoch(valor);
      return null;
    }

    double? convertirCoordenada(dynamic valor) {
      if (valor is num) return valor.toDouble();
      if (valor is String) return double.tryParse(valor);
      return null;
    }

    return Publicacion(
      id: json['id']?.toString() ?? '',
      usuarioId: json['usuarioId']?.toString() ?? '',
      nombreMascota: json['nombreMascota']?.toString() ?? json['nombre']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      especie: json['especie']?.toString() ?? '',
      raza: json['raza']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      tamano: json['tamano']?.toString() ?? json['tamaño']?.toString() ?? '',
      sexo: json['sexo']?.toString() ?? '',
      ubicacion: json['ubicacion']?.toString() ?? json['localidad']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      urlImagen: json['urlImagen']?.toString() ?? '',
      destacada: json['destacada'] == true,
      esPremium: json['esPremium'] == true,
      estadoPlan: json['estadoPlan']?.toString() ?? 'free',
      estadoPago: json['estadoPago']?.toString() ?? 'no_aplica',
      fechaInicioPremium: convertirFecha(json['fechaInicioPremium']),
      fechaFinPremium: convertirFecha(json['fechaFinPremium']),
      fechaCreacion: convertirFecha(json['fechaCreacion']),
      latitud: convertirCoordenada(json['latitud']),
      longitud: convertirCoordenada(json['longitud']),
      estado: json['estado']?.toString() ?? 'activa',
      reencuentroConfirmado: json['reencuentroConfirmado'] == true,
      fechaReencuentro: convertirFecha(json['fechaReencuentro']),
    );
  }
}
