
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ImagenService {
  final String urlBase = 'https://buscapet-api.vercel.app';

  Future<String> subirImagen(File imagen) async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      throw Exception('Debes iniciar sesion para subir una imagen');
    }

    final token = await usuario.getIdToken();

    if (token == null || token.isEmpty) {
      throw Exception('No se pudo obtener el token de autenticacion');
    }

    final tamanoBytes = await imagen.length();

    if (tamanoBytes <= 0 || tamanoBytes > 5 * 1024 * 1024) {
      throw Exception('La imagen debe pesar como maximo 5 MB');
    }

    final extension = imagen.path.split('.').last.toLowerCase();

    const formatosPermitidos = ['jpg', 'jpeg', 'png', 'webp'];

    if (!formatosPermitidos.contains(extension)) {
      throw Exception('El formato de imagen no esta permitido');
    }

    final respuestaFirma = await http.post(
      Uri.parse('$urlBase/api/subir-imagen'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'formato': extension,
        'tamanoBytes': tamanoBytes,
      }),
    );

    if (respuestaFirma.statusCode != 200) {
      throw Exception(
        'No se pudo preparar la subida de imagen: '
        '${respuestaFirma.statusCode}',
      );
    }

    final datos = jsonDecode(respuestaFirma.body);

    final cloudName = datos['cloudName'] as String;
    final apiKey = datos['apiKey'] as String;
    final timestamp = datos['timestamp'].toString();
    final folder = datos['folder'] as String;
    final publicId = datos['publicId'] as String;
    final signature = datos['signature'] as String;
    final allowedFormats = datos['allowedFormats'] as String;

    final solicitud = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      ),
    );

    solicitud.fields.addAll({
      'api_key': apiKey,
      'timestamp': timestamp,
      'folder': folder,
      'public_id': publicId,
      'allowed_formats': allowedFormats,
      'signature': signature,
    });

    solicitud.files.add(
      await http.MultipartFile.fromPath('file', imagen.path),
    );

    final respuestaSubida = await solicitud.send();
    final cuerpo = await respuestaSubida.stream.bytesToString();

    if (respuestaSubida.statusCode != 200) {
      throw Exception(
        'No se pudo subir la imagen a Cloudinary: '
        '${respuestaSubida.statusCode}',
      );
    }

    final resultado = jsonDecode(cuerpo);
    final urlImagen = resultado['secure_url'];

    if (urlImagen is! String || urlImagen.isEmpty) {
      throw Exception('Cloudinary no devolvio la URL de la imagen');
    }

    return urlImagen;
  }
}
