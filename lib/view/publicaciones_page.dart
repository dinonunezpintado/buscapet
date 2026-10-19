import 'package:flutter/material.dart';

import '../models/publicacion.dart';
import '../services/publicacion_service.dart';
import 'detalle_publicacion_page.dart';

class PublicacionesPage extends StatefulWidget {
  const PublicacionesPage({super.key});

  @override
  State<PublicacionesPage> createState() => _PublicacionesPageState();
}

class _PublicacionesPageState extends State<PublicacionesPage> {
  final PublicacionService _servicio = PublicacionService();
  final TextEditingController _busqueda = TextEditingController();
  late Future<List<Publicacion>> _publicaciones;
  String _filtroCategoria = 'Todas';

  @override
  void initState() {
    super.initState();
    _publicaciones = _cargarPublicaciones();
  }

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<List<Publicacion>> _cargarPublicaciones() async {
    final lista = await _servicio.obtenerPublicaciones();
    return lista.where((p) => p.id.isNotEmpty).toList();
  }

  Future<void> _recargar() async {
    final nuevaCarga = _cargarPublicaciones();
    setState(() => _publicaciones = nuevaCarga);
    await nuevaCarga;
  }

  String _categoriaVisual(Publicacion p) {
    if (p.reencuentroConfirmado) return 'Mascota reencontrada';
    final tipo = p.tipo.toLowerCase();
    if (tipo.contains('perd')) return 'Mascota perdida';
    return 'Mascota encontrada';
  }

  Color _colorEstado(String categoria) {
    switch (categoria) {
      case 'Mascota reencontrada':
        return const Color(0xFF25834A);
      case 'Mascota encontrada':
        return const Color(0xFF20A39E);
      default:
        return const Color(0xFFFF7A59);
    }
  }

  bool _coincide(Publicacion p) {
    final texto = _busqueda.text.trim().toLowerCase();
    final categoria = _categoriaVisual(p);
    final coincideTexto = texto.isEmpty ||
        [
          p.nombreMascota,
          p.ubicacion,
          p.raza,
          p.especie,
          p.color,
          p.tipo,
          p.descripcion,
        ].any((valor) => valor.toLowerCase().contains(texto));
    final coincideCategoria = _filtroCategoria == 'Todas' ||
        categoria == _filtroCategoria;
    return coincideTexto && coincideCategoria;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF20A39E),
        foregroundColor: Colors.white,
        title: const Text('Publicaciones', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Publicacion>>(
        future: _publicaciones,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF20A39E)));
          }
          if (snapshot.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.cloud_off, color: Color(0xFFFF7A59), size: 44),
                const SizedBox(height: 12),
                const Text('No se pudieron cargar las publicaciones.', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: () => setState(() => _publicaciones = _cargarPublicaciones()), child: const Text('Reintentar')),
              ]),
            ));
          }
          final todas = snapshot.data ?? [];
          final lista = todas.where(_coincide).toList();
          return Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: TextField(
                controller: _busqueda,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Buscar por mascota, ubicación, raza...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF20A39E)),
                  suffixIcon: _busqueda.text.isEmpty ? null : IconButton(icon: const Icon(Icons.close), onPressed: () { _busqueda.clear(); setState(() {}); }),
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Wrap(
                spacing: 7,
                runSpacing: 4,
                children: [
                  _filtroChip('Mascota perdida', const Color(0xFFFF7A59)),
                  _filtroChip('Mascota encontrada', const Color(0xFF20A39E)),
                  _filtroChip('Mascota reencontrada', const Color(0xFF25834A)),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(16, 6, 16, 4), child: Row(children: [
              Expanded(child: Text('${lista.length} de ${todas.length} publicaciones', style: const TextStyle(color: Color(0xFF666666), fontWeight: FontWeight.w600))),
              IconButton(tooltip: 'Actualizar', onPressed: _recargar, icon: const Icon(Icons.refresh, color: Color(0xFF20A39E))),
            ])),
            Expanded(child: RefreshIndicator(
              color: const Color(0xFF20A39E), onRefresh: _recargar,
              child: lista.isEmpty
                  ? ListView(children: const [SizedBox(height: 100), Center(child: Text('No hay publicaciones que coincidan con la búsqueda.'))])
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                      itemCount: lista.length,
                      itemBuilder: (context, index) {
                        final p = lista[index];
                        final categoria = _categoriaVisual(p);
                        final color = _colorEstado(categoria);
                        final esPerdida = categoria == 'Mascota perdida';
                        return Card(
                          color: Colors.white, margin: const EdgeInsets.only(bottom: 12), clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: color.withValues(alpha: 0.35))),
                          child: InkWell(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetallePublicacionPage(publicacion: p))),
                            child: Padding(padding: const EdgeInsets.all(10), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              ClipRRect(borderRadius: BorderRadius.circular(10), child: Container(
                                width: 112, height: 132, color: const Color(0xFFF7F9F6), alignment: Alignment.center,
                                child: p.urlImagen.trim().isNotEmpty
                                    ? Image.network(p.urlImagen, width: 112, height: 132, fit: BoxFit.contain, errorBuilder: (_, __, ___) => _imagenAlternativa())
                                    : _imagenAlternativa(),
                              )),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(p.nombreMascota.isEmpty ? 'Mascota sin nombre' : p.nombreMascota, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF444444))),
                                const SizedBox(height: 6),
                                Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: (esPerdida ? const Color(0xFFFF7A59) : const Color(0xFF20A39E)).withValues(alpha: 0.13), borderRadius: BorderRadius.circular(20)), child: Text(categoria, style: TextStyle(color: esPerdida ? const Color(0xFFCE5A40) : (categoria == 'Mascota reencontrada' ? const Color(0xFF25834A) : const Color(0xFF16827D)), fontWeight: FontWeight.bold, fontSize: 12))),
                                const SizedBox(height: 7),
                                if (p.reencuentroConfirmado) Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(20)), child: Text('Reencuentro confirmado', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12))),
                                const SizedBox(height: 8),
                                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF20A39E)), const SizedBox(width: 3), Expanded(child: Text(p.ubicacion.isEmpty ? 'Ubicación no indicada' : p.ubicacion, style: const TextStyle(color: Color(0xFF666666), fontSize: 13))) ]),
                                if (p.destacada) const Padding(padding: EdgeInsets.only(top: 6), child: Row(children: [Icon(Icons.star, color: Color(0xFFFF7A59), size: 16), SizedBox(width: 4), Text('Destacada', style: TextStyle(color: Color(0xFFFF7A59), fontWeight: FontWeight.bold, fontSize: 12))])),
                              ])),
                              const Icon(Icons.chevron_right, color: Color(0xFF20A39E)),
                            ])),
                          ),
                        );
                      },
                    ),
            )),
          ]);
        },
      ),
    );
  }


  Widget _filtroChip(String categoria, Color color) {
    final seleccionado = _filtroCategoria == categoria;
    return ChoiceChip(
      label: Text(categoria),
      selected: seleccionado,
      onSelected: (_) => setState(() {
        _filtroCategoria = seleccionado ? 'Todas' : categoria;
      }),
      selectedColor: color.withValues(alpha: 0.18),
      backgroundColor: Colors.white,
      side: BorderSide(color: seleccionado ? color : const Color(0xFFE0E0E0)),
      labelStyle: TextStyle(
        color: seleccionado ? color : const Color(0xFF555555),
        fontWeight: FontWeight.bold,
      ),
      checkmarkColor: color,
    );
  }

  Widget _imagenAlternativa() => const Center(child: Icon(Icons.pets, color: Color(0xFF20A39E), size: 38));
}
