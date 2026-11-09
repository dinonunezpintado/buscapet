import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/publicacion.dart';

class AvisoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> enviarAviso({
    required Publicacion publicacion,
    required String mensaje,
  }) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Debés iniciar sesión para enviar un aviso.');
    }

    final texto = mensaje.trim();
    if (texto.length < 5) {
      throw Exception('Escribí un mensaje de al menos 5 caracteres.');
    }

    if (publicacion.usuarioId.isEmpty || publicacion.id.isEmpty) {
      throw Exception('No se pudo identificar al dueño de la publicación.');
    }

    if (usuario.uid == publicacion.usuarioId) {
      throw Exception('No podés enviarte un aviso a tu propia publicación.');
    }

    final tipo = publicacion.tipo.toLowerCase();
    if (!tipo.contains('perd')) {
      throw Exception('Los avisos de contacto están disponibles para mascotas perdidas.');
    }

    await _firestore.collection('avisos').add({
      'publicacionId': publicacion.id,
      'idDueno': publicacion.usuarioId,
      'idRemitente': usuario.uid,
      'nombreMascota': publicacion.nombreMascota,
      'mensaje': texto,
      'estado': 'nuevo',
      'fechaCreacion': FieldValue.serverTimestamp(),
    });
  }

  /// Permite al dueño marcar como leído uno de los avisos que recibió.
  Future<void> marcarComoLeido(String avisoId) async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      throw Exception('Debés iniciar sesión para actualizar tus avisos.');
    }

    if (avisoId.trim().isEmpty) {
      throw Exception('No se pudo identificar el aviso.');
    }

    final referencia = _firestore.collection('avisos').doc(avisoId);
    final documento = await referencia.get();

    if (!documento.exists) {
      throw Exception('El aviso ya no existe.');
    }

    final datos = documento.data();
    if (datos == null || datos['idDueno'] != usuario.uid) {
      throw Exception('No tenés permiso para modificar este aviso.');
    }

    if (datos['estado'] == 'nuevo') {
      await referencia.update({'estado': 'leido'});
    }
  }
}
