import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../models/publicacion.dart';

class PublicacionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _urlApi =
      'https://buscapet-api.vercel.app/api/publicaciones';

  Future<List<Publicacion>> obtenerPublicaciones() async {
    final respuesta = await http.get(Uri.parse(_urlApi));
    if (respuesta.statusCode != 200) {
      throw Exception('No se pudieron obtener las publicaciones. Código: ${respuesta.statusCode}');
    }
    final dynamic datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
    final dynamic listaDatos = datos is List
        ? datos
        : datos is Map
            ? datos['publicaciones']
            : null;
    if (listaDatos is! List) {
      throw Exception('La respuesta de publicaciones no tiene el formato esperado.');
    }
    final publicaciones = listaDatos.map((elemento) => Publicacion.fromJson(
      Map<String, dynamic>.from(elemento as Map),
    )).toList();

    // Primero las publicaciones Premium vigentes; dentro de cada grupo, más nuevas primero.
    publicaciones.sort((a, b) {
      final aPremium = a.esPremium && (a.fechaFinPremium?.isAfter(DateTime.now()) ?? false);
      final bPremium = b.esPremium && (b.fechaFinPremium?.isAfter(DateTime.now()) ?? false);
      if (aPremium != bPremium) return aPremium ? -1 : 1;
      final fechaA = a.fechaCreacion;
      final fechaB = b.fechaCreacion;
      if (fechaA == null && fechaB == null) return 0;
      if (fechaA == null) return 1;
      if (fechaB == null) return -1;
      return fechaB.compareTo(fechaA);
    });
    return publicaciones;
  }

  Future<String> guardarPublicacion({
    required String tipo,
    required String nombreMascota,
    required String especie,
    required String raza,
    required String color,
    required String tamano,
    required String sexo,
    required String ubicacion,
    required String descripcion,
    required String urlImagen,
    double? latitud,
    double? longitud,
  }) async {
    final usuario = _auth.currentUser;
    if (usuario == null) {
      throw Exception('Debés iniciar sesión para publicar una mascota.');
    }
    final referencia = await _firestore.collection('publicaciones').add({
      'usuarioId': usuario.uid,
      'tipo': tipo,
      'nombreMascota': nombreMascota.trim(),
      'especie': especie,
      'raza': raza.trim(),
      'color': color.trim(),
      'tamano': tamano,
      'sexo': sexo,
      'ubicacion': ubicacion.trim(),
      'latitud': latitud,
      'longitud': longitud,
      'descripcion': descripcion.trim(),
      'urlImagen': urlImagen,
      'destacada': false,
      'esPremium': false,
      'estadoPlan': 'free',
      'estadoPago': 'no_aplica',
      'fechaInicioPremium': null,
      'fechaFinPremium': null,
      'estado': 'activa',
      'fechaCreacion': FieldValue.serverTimestamp(),
    });
    return referencia.id;
  }

  /// SIMULACIÓN ACADÉMICA: no representa un cobro real ni debe usarse en producción.
  Future<void> activarPremiumSimulado(String idPublicacion) async {
    final usuario = _auth.currentUser;
    if (usuario == null) throw Exception('Debés iniciar sesión.');
    final referencia = _firestore.collection('publicaciones').doc(idPublicacion);
    final documento = await referencia.get();
    if (!documento.exists) throw Exception('La publicación no existe.');
    final datos = documento.data()!;
    if (datos['usuarioId'] != usuario.uid) {
      throw Exception('Solo el dueño puede destacar esta publicación.');
    }
    final tipo = (datos['tipo'] ?? '').toString().toLowerCase();
    if (tipo.contains('encontr')) {
      throw Exception('Las publicaciones de mascotas encontradas son gratuitas.');
    }
    final inicio = DateTime.now();
    final fin = inicio.add(const Duration(days: 7));
    await referencia.update({
      'esPremium': true,
      'destacada': true,
      'estadoPlan': 'premium',
      'estadoPago': 'simulado',
      'montoPremium': 99,
      'monedaPremium': 'UYU',
      'fechaInicioPremium': Timestamp.fromDate(inicio),
      'fechaFinPremium': Timestamp.fromDate(fin),
    });
  }
}
