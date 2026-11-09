import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String conversacionId;
  const ChatPage({super.key, required this.conversacionId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const Color _verde = Color(0xFF20A39E);
  static const Color _naranja = Color(0xFFFF7A59);
  static const Color _fondo = Color(0xFFF7F9F6);

  final ChatService _service = ChatService();
  final TextEditingController _controlador = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _enviando = false;

  @override
  void dispose() {
    _controlador.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_enviando) return;
    final texto = _controlador.text.trim();
    if (texto.isEmpty) return;

    setState(() => _enviando = true);
    try {
      await _service.enviarMensaje(
        conversacionId: widget.conversacionId,
        texto: texto,
      );
      _controlador.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  bool _premiumActivo(Map<String, dynamic>? datos) {
    if (datos == null || datos['esPremium'] != true ||
        datos['estadoPlan'] != 'premium') return false;
    final fin = datos['fechaFinPremium'];
    DateTime? fecha;
    if (fin is Timestamp) fecha = fin.toDate();
    if (fin is DateTime) fecha = fin;
    if (fin is String) fecha = DateTime.tryParse(fin);
    return fecha != null && fecha.isAfter(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: _fondo,
      appBar: AppBar(
        title: const Text('Chat BUSCAPET'),
        backgroundColor: _verde,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _service.conversacion(widget.conversacionId),
        builder: (context, conversacionSnapshot) {
          if (conversacionSnapshot.hasError) {
            return const Center(child: Text('No se pudo abrir la conversación.'));
          }
          if (!conversacionSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: _verde));
          }
          final conversacion = conversacionSnapshot.data!.data();
          if (conversacion == null) {
            return const Center(child: Text('La conversación no existe.'));
          }

          final participantes =
              List<String>.from(conversacion['participantes'] ?? []);
          if (uid == null || !participantes.contains(uid)) {
            return const Center(child: Text('No tenés permiso para ver este chat.'));
          }

          final publicacionId = (conversacion['publicacionId'] ?? '').toString();

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('publicaciones').doc(publicacionId).snapshots(),
            builder: (context, publicacionSnapshot) {
              final premiumActivo = _premiumActivo(publicacionSnapshot.data?.data());

              return Column(
                children: [
                  if (!premiumActivo)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _naranja.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'El período Premium de esta publicación venció. El historial sigue disponible, pero no se pueden enviar nuevos mensajes.',
                        style: TextStyle(color: Color(0xFF8A4938)),
                      ),
                    ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _service.mensajes(widget.conversacionId),
                      builder: (context, mensajesSnapshot) {
                        if (mensajesSnapshot.hasError) {
                          return const Center(child: Text('No se pudieron cargar los mensajes.'));
                        }
                        if (!mensajesSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(color: _verde),
                          );
                        }

                        final mensajes = mensajesSnapshot.data!.docs;
                        if (mensajes.isEmpty) {
                          return const Center(
                            child: Text('Iniciá la conversación con un mensaje.'),
                          );
                        }

                        return ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.all(14),
                          itemCount: mensajes.length,
                          itemBuilder: (context, index) {
                            final datos = mensajes[index].data();
                            final mio = datos['remitenteId'] == uid;
                            final texto = (datos['texto'] ?? '').toString();
                            final fecha = datos['fechaCreacion'];
                            final hora = fecha is Timestamp
                                ? MaterialLocalizations.of(context).formatTimeOfDay(
                                    TimeOfDay.fromDateTime(fecha.toDate()))
                                : '';

                            return Align(
                              alignment: mio ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.78,
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: mio ? _verde : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.035),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      texto,
                                      style: TextStyle(
                                        color: mio ? Colors.white : const Color(0xFF333333),
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (hora.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        hora,
                                        style: TextStyle(
                                          color: mio ? Colors.white70 : Colors.black45,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                      color: Colors.white,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controlador,
                              enabled: premiumActivo && !_enviando,
                              minLines: 1,
                              maxLines: 4,
                              maxLength: 1000,
                              decoration: InputDecoration(
                                hintText: premiumActivo
                                    ? 'Escribí un mensaje...'
                                    : 'Chat no disponible',
                                counterText: '',
                                filled: true,
                                fillColor: _fondo,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onSubmitted: (_) => _enviar(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: premiumActivo && !_enviando ? _enviar : null,
                            icon: _enviando
                                ? const SizedBox(
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.send),
                            style: IconButton.styleFrom(
                              backgroundColor: _verde,
                              disabledBackgroundColor: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
