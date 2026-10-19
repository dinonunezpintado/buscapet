import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  static const Color _verde = Color(0xFF20A39E);
  static const Color _naranja = Color(0xFFFF7A59);
  static const Color _fondo = Color(0xFFF7F9F6);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get _usuario => _auth.currentUser;

  Future<void> _eliminarPublicacion(String id, String nombre) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: Text('¿Querés eliminar la publicación de $nombre? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _naranja),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      final usuario = _usuario;
      if (usuario == null) throw Exception('Debés iniciar sesión nuevamente.');

      final referencia = _firestore.collection('publicaciones').doc(id);
      final documento = await referencia.get();

      if (!documento.exists || documento.data()?['usuarioId'] != usuario.uid) {
        throw Exception('Solo podés eliminar tus propias publicaciones.');
      }

      await referencia.delete();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicación eliminada.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar: $e')),
      );
    }
  }

  Future<void> _marcarEncontrada(String id, String nombre) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Mascota reencontrada?'),
        content: Text('Confirmá que $nombre volvió con su dueño. La publicación quedará marcada como encontrada.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Todavía no'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _verde),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      final usuario = _usuario;
      if (usuario == null) throw Exception('Debés iniciar sesión nuevamente.');

      final referencia = _firestore.collection('publicaciones').doc(id);
      final documento = await referencia.get();
      final datos = documento.data();

      if (!documento.exists || datos?['usuarioId'] != usuario.uid) {
        throw Exception('Solo el dueño de la publicación puede confirmar el reencuentro.');
      }

      await referencia.update({
        'estado': 'encontrada',
        'fechaReencuentro': FieldValue.serverTimestamp(),
        'reencuentroConfirmado': true,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Reencuentro confirmado! Gracias por actualizar BUSCAPET.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo actualizar: $e')),
      );
    }
  }

  String _nombreDesdeDatos(Map<String, dynamic>? datos) {
    final nombre = (datos?['nombre'] ?? '').toString().trim();
    final apellido = (datos?['apellido'] ?? '').toString().trim();
    final completo = '$nombre $apellido'.trim();
    if (completo.isNotEmpty) return completo;
    if ((_usuario?.displayName ?? '').trim().isNotEmpty) return _usuario!.displayName!;
    return 'Usuario BUSCAPET';
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _usuario;

    if (usuario == null) {
      return Scaffold(
        backgroundColor: _fondo,
        appBar: AppBar(title: const Text('Mi perfil'), backgroundColor: _verde, foregroundColor: Colors.white),
        body: const Center(child: Text('Iniciá sesión para ver tu perfil.')),
      );
    }

    return Scaffold(
      backgroundColor: _fondo,
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: _verde,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _firestore.collection('usuarios').doc(usuario.uid).snapshots(),
        builder: (context, usuarioSnapshot) {
          final datosUsuario = usuarioSnapshot.data?.data();
          final nombre = _nombreDesdeDatos(datosUsuario);
          final email = (datosUsuario?['email'] ?? usuario.email ?? 'Sin correo').toString();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: _verde.withValues(alpha: 0.13),
                      backgroundImage: usuario.photoURL != null ? NetworkImage(usuario.photoURL!) : null,
                      child: usuario.photoURL == null ? const Icon(Icons.person, size: 44, color: _verde) : null,
                    ),
                    const SizedBox(height: 12),
                    Text(nombre, textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                    const SizedBox(height: 5),
                    Text(email, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(color: _verde.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: const Text('Mi cuenta BUSCAPET', style: TextStyle(color: _verde, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Row(
                children: [
                  Icon(Icons.pets, color: _verde, size: 24),
                  SizedBox(width: 8),
                  Expanded(child: Text('Mis publicaciones', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF444444)))),
                ],
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestore
                    .collection('publicaciones')
                    .where('usuarioId', isEqualTo: usuario.uid)
                    .snapshots(),
                builder: (context, publicacionesSnapshot) {
                  if (publicacionesSnapshot.hasError) {
                    return _mensajeEstado('No se pudieron cargar tus publicaciones. Revisá la conexión e intentá nuevamente.', Icons.cloud_off);
                  }
                  if (!publicacionesSnapshot.hasData) {
                    return const Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator(color: _verde)));
                  }

                  final documentos = publicacionesSnapshot.data!.docs.toList();
                  documentos.sort((a, b) {
                    final fechaA = a.data()['fechaCreacion'];
                    final fechaB = b.data()['fechaCreacion'];
                    final millisA = fechaA is Timestamp ? fechaA.millisecondsSinceEpoch : 0;
                    final millisB = fechaB is Timestamp ? fechaB.millisecondsSinceEpoch : 0;
                    return millisB.compareTo(millisA);
                  });

                  if (documentos.isEmpty) {
                    return _mensajeEstado('Todavía no publicaste ninguna mascota.', Icons.photo_camera_outlined);
                  }

                  return Column(
                    children: documentos.map((documento) {
                      final datos = documento.data();
                      final nombreMascota = (datos['nombreMascota'] ?? 'Mascota sin nombre').toString();
                      final tipo = (datos['tipo'] ?? 'Publicación').toString();
                      final estado = (datos['estado'] ?? 'activa').toString().toLowerCase();
                      final imagen = (datos['urlImagen'] ?? '').toString();
                      final encontrada = estado == 'encontrada' || estado == 'encontrado';
                      final tipoNormalizado = tipo.toLowerCase().replaceAll('í', 'i');
                      final esPerdida = tipoNormalizado.contains('perdi') || tipoNormalizado.contains('perd');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE7ECE8))),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      width: 88,
                                      height: 88,
                                      child: imagen.isNotEmpty
                                          ? Image.network(imagen, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imagenVacia())
                                          : _imagenVacia(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(nombreMascota, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text(tipo, style: TextStyle(color: tipoNormalizado.contains('encontre') ? _naranja : _verde, fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 5),
                                        Text((datos['ubicacion'] ?? 'Ubicación no indicada').toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                                        const SizedBox(height: 7),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                          decoration: BoxDecoration(color: encontrada ? const Color(0xFFE3F5E9) : const Color(0xFFEAF5F4), borderRadius: BorderRadius.circular(12)),
                                          child: Text(encontrada ? 'Encontrada' : 'Activa', style: TextStyle(fontSize: 11, color: encontrada ? Colors.green.shade800 : _verde, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                alignment: WrapAlignment.end,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (esPerdida && !encontrada)
                                    OutlinedButton.icon(
                                      onPressed: () => _marcarEncontrada(documento.id, nombreMascota),
                                      icon: const Icon(Icons.check_circle_outline, size: 18),
                                      label: const Text('Marcar encontrada'),
                                      style: OutlinedButton.styleFrom(foregroundColor: _verde, side: const BorderSide(color: _verde)),
                                    ),
                                  OutlinedButton.icon(
                                    onPressed: () => _eliminarPublicacion(documento.id, nombreMascota),
                                    icon: const Icon(Icons.delete_outline, size: 18),
                                    label: const Text('Eliminar'),
                                    style: OutlinedButton.styleFrom(foregroundColor: _naranja, side: const BorderSide(color: _naranja)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _mensajeEstado(String texto, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icono, color: _verde, size: 38),
          const SizedBox(height: 10),
          Text(texto, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _imagenVacia() {
    return Container(
      color: const Color(0xFFEAF5F4),
      child: const Icon(Icons.pets, color: _verde, size: 34),
    );
  }
}
