import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/aviso_service.dart';
import '../services/chat_service.dart';
import 'chat_page.dart';

class AvisosPage extends StatefulWidget {
  const AvisosPage({super.key});

  @override
  State<AvisosPage> createState() => _AvisosPageState();
}

class _AvisosPageState extends State<AvisosPage> {
  static const Color _verde = Color(0xFF20A39E);
  static const Color _naranja = Color(0xFFFF7A59);
  static const Color _fondo = Color(0xFFF7F9F6);

  final AvisoService _avisoService = AvisoService();
  final ChatService _chatService = ChatService();
  final Set<String> _avisosActualizando = {};
  final Set<String> _chatsAbriendo = {};

  String _fecha(BuildContext context, dynamic valor) {
    if (valor is! Timestamp) return 'Fecha pendiente';

    final fecha = valor.toDate();
    final dia = MaterialLocalizations.of(context).formatMediumDate(fecha);
    final hora = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(fecha),
    );
    return '$dia · $hora';
  }

  Future<void> _marcarComoLeido(String avisoId) async {
    if (_avisosActualizando.contains(avisoId)) return;

    setState(() => _avisosActualizando.add(avisoId));

    try {
      await _avisoService.marcarComoLeido(avisoId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aviso marcado como leído.'),
          backgroundColor: _verde,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo actualizar el aviso: $error'),
          backgroundColor: _naranja,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _avisosActualizando.remove(avisoId));
      }
    }
  }


  Future<void> _abrirChat(String avisoId) async {
    if (_chatsAbriendo.contains(avisoId)) return;
    setState(() => _chatsAbriendo.add(avisoId));
    try {
      final conversacionId = await _chatService.iniciarDesdeAviso(avisoId);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(conversacionId: conversacionId),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: _naranja,
        ),
      );
    } finally {
      if (mounted) setState(() => _chatsAbriendo.remove(avisoId));
    }
  }

  Widget _botonChat(String avisoId, String publicacionId) {
    return FutureBuilder<bool>(
      future: _chatService.premiumVigente(publicacionId),
      builder: (context, snapshot) {
        final disponible = snapshot.data == true;
        final abriendo = _chatsAbriendo.contains(avisoId);
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: disponible && !abriendo
                ? () => _abrirChat(avisoId)
                : null,
            icon: abriendo
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.chat_bubble_outline),
            label: Text(
              snapshot.connectionState == ConnectionState.waiting
                  ? 'Verificando Premium...'
                  : disponible
                      ? 'Responder por chat'
                      : 'Chat disponible con Premium vigente',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _verde,
              disabledBackgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      return Scaffold(
        backgroundColor: _fondo,
        appBar: AppBar(
          title: const Text('Mis avisos'),
          backgroundColor: _verde,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Iniciá sesión para consultar tus avisos.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _fondo,
      appBar: AppBar(
        title: const Text('Mis avisos'),
        centerTitle: true,
        backgroundColor: _verde,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('avisos')
            .where('idDueno', isEqualTo: usuario.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No se pudieron cargar tus avisos. Revisá la conexión y las reglas de Firestore.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: _verde),
            );
          }

          final documentos = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final fechaA = a.data()['fechaCreacion'];
              final fechaB = b.data()['fechaCreacion'];
              final aMillis =
                  fechaA is Timestamp ? fechaA.millisecondsSinceEpoch : 0;
              final bMillis =
                  fechaB is Timestamp ? fechaB.millisecondsSinceEpoch : 0;
              return bMillis.compareTo(aMillis);
            });

          if (documentos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mark_chat_unread_outlined,
                      size: 64,
                      color: _verde.withValues(alpha: 0.65),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Todavía no recibiste avisos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF444444),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cuando alguien tenga información sobre una de tus mascotas perdidas, el aviso aparecerá acá.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            );
          }

          final nuevos =
              documentos.where((doc) => doc.data()['estado'] == 'nuevo').length;

          return Column(
            children: [
              if (nuevos > 0)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _verde.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Tenés $nuevos aviso(s) sin leer.',
                    style: const TextStyle(
                      color: _verde,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: documentos.length,
                  itemBuilder: (context, indice) {
                    final documento = documentos[indice];
                    final datos = documento.data();
                    final mensaje = (datos['mensaje'] ?? '').toString();
                    final nombreMascota =
                        (datos['nombreMascota'] ?? '').toString().trim();
                    final estado = (datos['estado'] ?? 'nuevo').toString();
                    final remitente =
                        (datos['idRemitente'] ?? '').toString();
                    final publicacionId =
                        (datos['publicacionId'] ?? '').toString();
                    final fecha = _fecha(context, datos['fechaCreacion']);
                    final esNuevo = estado == 'nuevo';
                    final actualizando =
                        _avisosActualizando.contains(documento.id);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: esNuevo
                              ? _verde.withValues(alpha: 0.5)
                              : const Color(0xFFE7ECE8),
                          width: esNuevo ? 1.6 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.035),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    _verde.withValues(alpha: 0.12),
                                child: Icon(
                                  esNuevo
                                      ? Icons.mark_chat_unread_outlined
                                      : Icons.mark_chat_read_outlined,
                                  color: _verde,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Alguien tiene información',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: esNuevo
                                      ? _naranja.withValues(alpha: 0.13)
                                      : _verde.withValues(alpha: 0.11),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  esNuevo ? 'Nuevo' : 'Leído',
                                  style: TextStyle(
                                    color: esNuevo ? _naranja : _verde,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (nombreMascota.isNotEmpty) ...[
                            Text(
                              'Mascota: $nombreMascota',
                              style: const TextStyle(
                                color: Color(0xFF555555),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: _fondo,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              mensaje,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF444444),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                size: 15,
                                color: Colors.black45,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  fecha,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Remitente: ${remitente.isEmpty ? 'No disponible' : '${remitente.substring(0, remitente.length > 8 ? 8 : remitente.length)}…'}',
                            style: const TextStyle(
                              color: Colors.black45,
                              fontSize: 11,
                            ),
                          ),
                          if (esNuevo) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: actualizando
                                    ? null
                                    : () => _marcarComoLeido(documento.id),
                                icon: actualizando
                                    ? const SizedBox(
                                        width: 17,
                                        height: 17,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.done),
                                label: Text(
                                  actualizando
                                      ? 'Actualizando...'
                                      : 'Marcar como leído',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _verde,
                                  side: const BorderSide(color: _verde),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (publicacionId.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _botonChat(documento.id, publicacionId),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
