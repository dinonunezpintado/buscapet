
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
      throw Exception(
        'No se pudieron obtener las publicaciones. '
        'Código: ${respuesta.statusCode}',
      );
    }

    final dynamic datos = jsonDecode(
      utf8.decode(respuesta.bodyBytes),
    );

    // acepta tanto una lista directa como el objeto de la api
    final dynamic listaDatos = datos is List
        ? datos
        : datos is Map
            ? datos['publicaciones']
            : null;

    if (listaDatos is! List) {
      throw Exception(
        'La respuesta de publicaciones no tiene el formato esperado.',
      );
    }

    final publicaciones = listaDatos.map((elemento) {
      return Publicacion.fromJson(
        Map<String, dynamic>.from(elemento as Map),
      );
    }).toList();

    publicaciones.sort((a, b) {
      final fechaA = a.fechaCreacion;
      final fechaB = b.fechaCreacion;

      if (fechaA == null && fechaB == null) return 0;
      if (fechaA == null) return 1;
      if (fechaB == null) return -1;

      return fechaB.compareTo(fechaA);
    });

    return publicaciones;
  }

  Future<void> guardarPublicacion({
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
      throw Exception(
        'Debés iniciar sesión para publicar una mascota.',
      );
    }

    await _firestore.collection('publicaciones').add({
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
      'estado': 'activa',
      'fechaCreacion': FieldValue.serverTimestamp(),
    });
  }
}
