import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapaViewModel extends ChangeNotifier {
  double? _latitudUsuario;
  double? _longitudUsuario;

  double? get latitudUsuario => _latitudUsuario;
  double? get longitudUsuario => _longitudUsuario;

  double _latitudMascota = -30.90500;
  double _longitudMascota = -55.55000;

  double get latitudMascota => _latitudMascota;
  double get longitudMascota => _longitudMascota;

  bool _rutaCalculada = false;
  bool get rutaCalculada => _rutaCalculada;

  bool _calculandoRuta = false;
  bool get calculandoRuta => _calculandoRuta;

  bool _obteniendoUbicacion = false;
  bool get obteniendoUbicacion => _obteniendoUbicacion;

  String? _mensajeError;
  String? get mensajeError => _mensajeError;

  List<LatLng> _puntosRuta = [];

  List<LatLng> get puntosRuta => _puntosRuta;

  double _distancia = 0;
  double get distancia => _distancia;

  int _tiempoEstimado = 0;
  int get tiempoEstimado => _tiempoEstimado;

  void seleccionarDestino(LatLng posicion) {
    _latitudMascota = posicion.latitude;
    _longitudMascota = posicion.longitude;

    _rutaCalculada = false;
    _puntosRuta = [];

    notifyListeners();
  }

  Future<void> obtenerUbicacion() async {
    _obteniendoUbicacion = true;
    _mensajeError = null;

    notifyListeners();

    try {
      final servicioActivado =
          await Geolocator.isLocationServiceEnabled();

      if (!servicioActivado) {
        _mensajeError =
            'El servicio de ubicación está desactivado.';
        _obteniendoUbicacion = false;
        notifyListeners();
        return;
      }

      LocationPermission permiso =
          await Geolocator.checkPermission();

      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.deniedForever) {
        _mensajeError =
            'El permiso de ubicación fue denegado permanentemente.';
        _obteniendoUbicacion = false;
        notifyListeners();
        return;
      }

      if (permiso == LocationPermission.denied) {
        _mensajeError =
            'El permiso de ubicación fue denegado.';
        _obteniendoUbicacion = false;
        notifyListeners();
        return;
      }

      final posicion =
          await Geolocator.getCurrentPosition();

      _latitudUsuario = posicion.latitude;
      _longitudUsuario = posicion.longitude;

      _rutaCalculada = false;
      _puntosRuta = [];
    } catch (e) {
      _mensajeError =
          'No se pudo obtener la ubicación.';
    }

    _obteniendoUbicacion = false;

    notifyListeners();
  }

  Future<void> calcularRuta() async {
    if (_latitudUsuario == null ||
        _longitudUsuario == null) {
      _mensajeError =
          'Primero debes obtener tu ubicación.';
      notifyListeners();
      return;
    }

    _calculandoRuta = true;
    _rutaCalculada = false;
    _mensajeError = null;

    notifyListeners();

    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '$_longitudUsuario,$_latitudUsuario;'
        '$_longitudMascota,$_latitudMascota'
        '?overview=full&geometries=geojson',
      );

      final respuesta = await http.get(url);

      if (respuesta.statusCode != 200) {
        _mensajeError =
            'No se pudo calcular la ruta.';
        _calculandoRuta = false;
        notifyListeners();
        return;
      }

      final datos = jsonDecode(respuesta.body);

      if (datos['routes'] == null ||
          datos['routes'].isEmpty) {
        _mensajeError =
            'No se encontró una ruta.';
        _calculandoRuta = false;
        notifyListeners();
        return;
      }

      final ruta = datos['routes'][0];

      final coordenadas =
          ruta['geometry']['coordinates'] as List;

      _puntosRuta = coordenadas.map<LatLng>((coordenada) {
        return LatLng(
          coordenada[1].toDouble(),
          coordenada[0].toDouble(),
        );
      }).toList();

      _distancia = ruta['distance'] / 1000;

      _tiempoEstimado =
          (ruta['duration'] / 60).round();

      _rutaCalculada = true;
    } catch (e) {
      _mensajeError =
          'Ocurrió un error al calcular la ruta.';
    }

    _calculandoRuta = false;

    notifyListeners();
  }
}