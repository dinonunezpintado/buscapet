import 'package:flutter/foundation.dart';

class InicioViewModel extends ChangeNotifier {
  // ==========================================
  // DATOS FALSOS DE LAS PUBLICACIONES
  // ==========================================

  final List<Map<String, String>> publicaciones = [
    {
      'nombre': 'Milo',
      'estado': 'Perdida',
      'ubicacion': 'Palermo, CABA',
      'tiempo': '2 horas atrás',
      'imagen': 'assets/images/milo.jpg',
    },
    {
      'nombre': 'Lola',
      'estado': 'Encontrada',
      'ubicacion': 'Villa Urquiza, CABA',
      'tiempo': '5 horas atrás',
      'imagen': 'assets/images/lola.jpg',
    },
    {
      'nombre': 'Simba',
      'estado': 'Perdida',
      'ubicacion': 'Belgrano, CABA',
      'tiempo': '1 día atrás',
      'imagen': 'assets/images/simba.jpg',
    },
    {
      'nombre': 'Tomy',
      'estado': 'Encontrada',
      'ubicacion': 'Caballito, CABA',
      'tiempo': '1 día atrás',
      'imagen': 'assets/images/tomy.jpg',
    },
  ];
}