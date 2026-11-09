import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/publicacion.dart';
import '../services/aviso_service.dart';

class DetallePublicacionPage extends StatelessWidget {
  final Publicacion publicacion;

  const DetallePublicacionPage({
    super.key,
    required this.publicacion,
  });

  Future<void> _mostrarFormularioAviso(BuildContext context) async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debés iniciar sesión para contactar al dueño.'),
        ),
      );
      return;
    }

    final paginaContext = context;
    final controlador = TextEditingController();
    bool enviando = false;

    await showDialog<void>(
      context: paginaContext,
      barrierDismissible: !enviando,
      builder: (dialogoContext) {
        return StatefulBuilder(
          builder: (dialogoContext, actualizarDialogo) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Text(
                'Tengo información sobre esta mascota',
                style: TextStyle(
                  color: Color(0xFF20A39E),
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu mensaje privado será enviado al dueño de ${publicacion.nombreMascota.isEmpty ? 'esta mascota' : publicacion.nombreMascota}.',
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controlador,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 500,
                    enabled: !enviando,
                    decoration: InputDecoration(
                      hintText: 'Contale qué información tenés...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF20A39E),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: enviando
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF20A39E),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: enviando
                      ? null
                      : () async {
                          final mensaje = controlador.text.trim();
                          if (mensaje.length < 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Escribí un mensaje de al menos 5 caracteres.',
                                ),
                              ),
                            );
                            return;
                          }

                          actualizarDialogo(() => enviando = true);
                          try {
                            await AvisoService().enviarAviso(
                              publicacion: publicacion,
                              mensaje: mensaje,
                            );

                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Tu aviso fue enviado al dueño.',
                                ),
                                backgroundColor: Color(0xFF25834A),
                              ),
                            );
                          } catch (e) {
                            actualizarDialogo(() => enviando = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceFirst('Exception: ', ''),
                                ),
                              ),
                            );
                          }
                        },
                  icon: enviando
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, size: 18),
                  label: Text(enviando ? 'Enviando...' : 'Enviar aviso'),
                ),
              ],
            );
          },
        );
      },
    );

    controlador.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool encontrada =
        publicacion.tipo.toLowerCase().contains('encontr');

    final bool esMascotaPerdida =
        publicacion.tipo.toLowerCase().contains('perd');

    final bool usuarioEsDueno =
        FirebaseAuth.instance.currentUser?.uid == publicacion.usuarioId;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF20A39E),
        foregroundColor: Colors.white,
        title: const Text('Detalle de la publicación'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: double.infinity,
                height: 260,
                child: publicacion.urlImagen.trim().isNotEmpty
                    ? Image.network(
                        publicacion.urlImagen,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF20A39E),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _imagenRespaldo();
                        },
                      )
                    : _imagenRespaldo(),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                publicacion.nombreMascota.isEmpty
                    ? 'Mascota sin nombre'
                    : publicacion.nombreMascota,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF555555),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: encontrada
                      ? const Color(0xFF20A39E)
                      : const Color(0xFFFF7A59),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  publicacion.tipo.isEmpty
                      ? 'Publicación'
                      : publicacion.tipo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Información de la mascota',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 12),
            _dato('Especie', publicacion.especie),
            _dato('Raza', publicacion.raza),
            _dato('Color', publicacion.color),
            _dato('Tamaño', publicacion.tamano),
            _dato('Sexo', publicacion.sexo),
            const SizedBox(height: 20),
            const Text(
              'Ubicación',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 8),
            _dato('Localidad', publicacion.ubicacion),
            const SizedBox(height: 20),
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF555555),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              publicacion.descripcion.isEmpty
                  ? 'Sin descripción disponible.'
                  : publicacion.descripcion,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
            if (publicacion.destacada) ...[
              const SizedBox(height: 20),
              const Row(
                children: [
                  Icon(Icons.star, color: Color(0xFFFF7A59)),
                  SizedBox(width: 8),
                  Text(
                    'Publicación destacada',
                    style: TextStyle(
                      color: Color(0xFFFF7A59),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            if (esMascotaPerdida && !usuarioEsDueno) ...[
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _mostrarFormularioAviso(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF20A39E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.mark_chat_unread_outlined),
                  label: const Text(
                    'Tengo información sobre esta mascota',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _imagenRespaldo() {
    return Container(
      color: const Color(0xFFF7F9F6),
      child: const Center(
        child: Icon(
          Icons.pets,
          size: 100,
          color: Color(0xFF20A39E),
        ),
      ),
    );
  }

  Widget _dato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$titulo:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF555555),
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor.isEmpty ? 'No indicado' : valor,
              style: const TextStyle(
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
