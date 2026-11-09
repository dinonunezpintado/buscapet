import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final usuario = _auth.currentUser;
    if (usuario == null) throw Exception('Debés iniciar sesión.');
    return usuario.uid;
  }

  bool _premiumVigente(Map<String, dynamic>? datos) {
    if (datos == null || datos['esPremium'] != true ||
        datos['estadoPlan'] != 'premium') return false;

    final fin = datos['fechaFinPremium'];
    DateTime? fechaFin;
    if (fin is Timestamp) fechaFin = fin.toDate();
    if (fin is DateTime) fechaFin = fin;
    if (fin is String) fechaFin = DateTime.tryParse(fin);
    return fechaFin != null && fechaFin.isAfter(DateTime.now());
  }

  Future<bool> premiumVigente(String publicacionId) async {
    final doc = await _db.collection('publicaciones').doc(publicacionId).get();
    return _premiumVigente(doc.data());
  }

  /// Crea una conversación única por aviso. Solo funciona con Premium vigente.
  Future<String> iniciarDesdeAviso(String avisoId) async {
    final uid = _uid;
    final avisoRef = _db.collection('avisos').doc(avisoId);
    final avisoDoc = await avisoRef.get();

    if (!avisoDoc.exists) throw Exception('El aviso ya no existe.');
    final aviso = avisoDoc.data()!;
    final dueno = (aviso['idDueno'] ?? '').toString();
    final remitente = (aviso['idRemitente'] ?? '').toString();
    final publicacionId = (aviso['publicacionId'] ?? '').toString();

    if (uid != dueno && uid != remitente) {
      throw Exception('No tenés permiso para abrir esta conversación.');
    }
    if (dueno.isEmpty || remitente.isEmpty || publicacionId.isEmpty) {
      throw Exception('El aviso no tiene todos los datos necesarios.');
    }

    final publicacionDoc =
        await _db.collection('publicaciones').doc(publicacionId).get();
    if (!_premiumVigente(publicacionDoc.data())) {
      throw Exception('El chat está disponible únicamente mientras el Premium de esta publicación esté vigente.');
    }

    // El ID del aviso evita crear conversaciones duplicadas.
    final conversacionRef = _db.collection('conversaciones').doc(avisoId);
    final existente = await conversacionRef.get();

    if (!existente.exists) {
      await conversacionRef.set({
        'avisoId': avisoId,
        'publicacionId': publicacionId,
        'idDueno': dueno,
        'idRemitente': remitente,
        'participantes': [dueno, remitente],
        'nombreMascota': (aviso['nombreMascota'] ?? 'Mascota').toString(),
        'fechaCreacion': FieldValue.serverTimestamp(),
      });
    } else {
      final datos = existente.data()!;
      final participantes = List<String>.from(datos['participantes'] ?? []);
      if (!participantes.contains(uid) ||
          datos['publicacionId'] != publicacionId) {
        throw Exception('No tenés permiso para acceder a esta conversación.');
      }
    }
    return avisoId;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> conversacionesDelUsuario() {
    return _db.collection('conversaciones')
        .where('participantes', arrayContains: _uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> mensajes(String conversacionId) {
    return _db.collection('conversaciones')
        .doc(conversacionId)
        .collection('mensajes')
        .orderBy('fechaCreacion')
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> conversacion(
      String conversacionId) {
    return _db.collection('conversaciones').doc(conversacionId).snapshots();
  }

  Future<void> enviarMensaje({
    required String conversacionId,
    required String texto,
  }) async {
    final contenido = texto.trim();
    if (contenido.isEmpty) throw Exception('Escribí un mensaje.');
    if (contenido.length > 1000) {
      throw Exception('El mensaje no puede superar los 1000 caracteres.');
    }

    final conversacionRef =
        _db.collection('conversaciones').doc(conversacionId);
    final conversacionDoc = await conversacionRef.get();
    if (!conversacionDoc.exists) {
      throw Exception('La conversación ya no existe.');
    }

    final datos = conversacionDoc.data()!;
    final participantes = List<String>.from(datos['participantes'] ?? []);
    if (!participantes.contains(_uid)) {
      throw Exception('No tenés permiso para enviar mensajes acá.');
    }

    final publicacionId = (datos['publicacionId'] ?? '').toString();
    final publicacionDoc =
        await _db.collection('publicaciones').doc(publicacionId).get();
    if (!_premiumVigente(publicacionDoc.data())) {
      throw Exception('El Premium venció. Podés consultar el historial, pero ya no enviar mensajes.');
    }

    await conversacionRef.collection('mensajes').add({
      'remitenteId': _uid,
      'texto': contenido,
      'fechaCreacion': FieldValue.serverTimestamp(),
    });
  }
}
