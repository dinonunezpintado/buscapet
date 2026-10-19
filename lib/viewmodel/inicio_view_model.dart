
import 'package:flutter/foundation.dart';

import '../models/publicacion.dart';
import '../services/publicacion_service.dart';

class InicioViewModel extends ChangeNotifier {
  final PublicacionService _servicio = PublicacionService();

  List<Publicacion> publicaciones = [];

  bool cargando = false;

  String? mensajeError;

  InicioViewModel() {
    cargarPublicaciones();
  }

  Future<void> cargarPublicaciones() async {
    cargando = true;
    mensajeError = null;
    notifyListeners();

    try {
      publicaciones = await _servicio.obtenerPublicaciones();
    } catch (error, stackTrace) {
      debugPrint('error al cargar publicaciones: $error');
      debugPrintStack(stackTrace: stackTrace);

      mensajeError =
          'No se pudieron cargar las publicaciones.\n\nDetalle: $error';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }
}
