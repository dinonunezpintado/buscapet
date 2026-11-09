import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';
import 'chat_page.dart';

class ConversacionesPage extends StatelessWidget {
  const ConversacionesPage({super.key});

  static const Color _verde = Color(0xFF20A39E);
  static const Color _fondo = Color(0xFFF7F9F6);

  @override
  Widget build(BuildContext context) {
    final usuario = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: _fondo,
      appBar: AppBar(
        title: const Text('Mis conversaciones'),
        centerTitle: true,
        backgroundColor: _verde,
        foregroundColor: Colors.white,
      ),
      body: usuario == null
          ? const Center(child: Text('Iniciá sesión para ver tus conversaciones.'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: ChatService().conversacionesDelUsuario(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No se pudieron cargar las conversaciones. Revisá las reglas de Firestore.',
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

                final docs = snapshot.data!.docs.toList()
                  ..sort((a, b) {
                    final fa = a.data()['fechaCreacion'];
                    final fb = b.data()['fechaCreacion'];
                    final ta = fa is Timestamp ? fa.millisecondsSinceEpoch : 0;
                    final tb = fb is Timestamp ? fb.millisecondsSinceEpoch : 0;
                    return tb.compareTo(ta);
                  });

                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.forum_outlined, size: 58, color: _verde),
                          SizedBox(height: 14),
                          Text(
                            'Todavía no tenés conversaciones',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          SizedBox(height: 7),
                          Text(
                            'Cuando el dueño de una publicación Premium inicie un chat desde un aviso, aparecerá acá.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final datos = doc.data();
                    final dueno = (datos['idDueno'] ?? '').toString();
                    final remitente = (datos['idRemitente'] ?? '').toString();
                    final otro = usuario.uid == dueno ? remitente : dueno;
                    final nombre = (datos['nombreMascota'] ?? 'Mascota').toString();

                    return Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE8F5F4),
                          child: Icon(Icons.pets, color: _verde),
                        ),
                        title: Text(
                          nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Conversación privada · ${otro.isEmpty ? 'Usuario' : 'Participante ${otro.substring(0, otro.length > 7 ? 7 : otro.length)}…'}',
                        ),
                        trailing: const Icon(Icons.chevron_right, color: _verde),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(conversacionId: doc.id),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
