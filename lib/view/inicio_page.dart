
import 'package:flutter/material.dart';

import '../models/publicacion.dart';
import '../viewmodel/inicio_view_model.dart';
import 'mapa_page.dart';
import 'detalle_publicacion_page.dart';
import 'publicar_mascota_page.dart';
import 'publicaciones_page.dart';
import 'perfil_page.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  final InicioViewModel _viewModel = InicioViewModel();

  int _opcionSeleccionada = 0;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_actualizarPantalla);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_actualizarPantalla);
    _viewModel.dispose();
    super.dispose();
  }

  void _actualizarPantalla() {
    if (mounted) {
      setState(() {});
    }
  }

  void _abrirMapa() {
    setState(() {
      _opcionSeleccionada = 2;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapaPage(),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _opcionSeleccionada = 0;
        });
      }
    });
  }

  Future<void> _abrirPublicaciones() async {
    setState(() {
      _opcionSeleccionada = 1;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PublicacionesPage(),
      ),
    );

    if (!mounted) return;

    setState(() {
      _opcionSeleccionada = 0;
    });

    await _viewModel.cargarPublicaciones();
  }

  Future<void> _abrirPerfil() async {
    setState(() {
      _opcionSeleccionada = 3;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PerfilPage(),
      ),
    );

    if (!mounted) return;

    setState(() {
      _opcionSeleccionada = 0;
    });

    await _viewModel.cargarPublicaciones();
  }

  Future<void> _volverAlInicio() async {
    setState(() {
      _opcionSeleccionada = 0;
    });

    await _viewModel.cargarPublicaciones();
  }

  Future<void> _abrirFormularioPublicacion({
    String tipoInicial = 'Perdí mi mascota',
  }) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PublicarMascotaPage(
          tipoInicial: tipoInicial,
        ),
      ),
    );

    if (!mounted) return;

    if (resultado == true) {
      await _viewModel.cargarPublicaciones();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      body: SafeArea(
        child: Column(
          children: [
            // encabezado
            Container(
              height: 64,
              width: double.infinity,
              color: const Color(0xFF20A39E),
              child: Row(
                children: [
                  const Spacer(),
                  const Icon(
                    Icons.pets,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'BuscaPet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // contenido
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // imagen principal
                    SizedBox(
                      width: double.infinity,
                      height: 210,
                      child: Image.asset(
                        'assets/images/hero.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // banner con el total de reencuentros confirmados
                    _bannerReencuentros(),

                    const SizedBox(height: 18),

                    // botones principales
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _botonPrincipal(
                              texto: 'PERDÍ MI\nMASCOTA',
                              color: const Color(0xFF20A39E),
                              icono: Icons.pets,
                              onPressed: () => _abrirFormularioPublicacion(
                                tipoInicial: 'Perdí mi mascota',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _botonPrincipal(
                              texto: 'ENCONTRÉ UNA\nMASCOTA',
                              color: const Color(0xFFFF7A59),
                              icono: Icons.search,
                              onPressed: () => _abrirFormularioPublicacion(
                                tipoInicial: 'Encontré una mascota',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // título publicaciones
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.description_outlined,
                            color: Color(0xFF20A39E),
                            size: 25,
                          ),
                          const SizedBox(width: 7),
                          const Expanded(
                            child: Text(
                              'Últimas publicaciones',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF555555),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _abrirPublicaciones,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Ver todas',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF20A39E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // publicaciones
                    SizedBox(
                      height: 285,
                      child: _construirPublicaciones(),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // navegación inferior
      bottomNavigationBar: _barraNavegacion(),
    );
  }

  Widget _bannerReencuentros() {
    final cantidad = _viewModel.publicaciones
        .where((p) => p.reencuentroConfirmado)
        .length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F5E9), Color(0xFFF0FAF2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFB8E2C5)),
      ),
      child: Row(children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(color: Color(0xFF25834A), shape: BoxShape.circle),
          child: const Icon(Icons.favorite, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('¡Buenas noticias!', style: TextStyle(color: Color(0xFF25834A), fontWeight: FontWeight.bold, fontSize: 15)),
          Text('Ya reencontramos $cantidad ${cantidad == 1 ? 'mascota' : 'mascotas'}', style: const TextStyle(color: Color(0xFF206D3E), fontSize: 18, fontWeight: FontWeight.bold)),
          const Text('con sus familias gracias a BUSCAPET', style: TextStyle(color: Color(0xFF39734D), fontSize: 12)),
        ])),
      ]),
    );
  }

  Widget _construirPublicaciones() {
    if (_viewModel.cargando) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF20A39E),
        ),
      );
    }

    if (_viewModel.mensajeError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off,
                color: Color(0xFFFF7A59),
                size: 35,
              ),
              const SizedBox(height: 8),
              Text(
                _viewModel.mensajeError!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _viewModel.cargarPublicaciones,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final activas = _viewModel.publicaciones
        .where((p) => !p.reencuentroConfirmado)
        .toList();

    if (activas.isEmpty) {
      return const Center(
        child: Text('No hay mascotas pendientes de reencuentro.'),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: activas.length,
      itemBuilder: (context, index) {
        final publicacion = activas[index];
        return _tarjetaMascota(publicacion);
      },
    );
  }

  // botón principal
  Widget _botonPrincipal({
    required String texto,
    required Color color,
    required IconData icono,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icono,
                color: color,
                size: 23,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                texto,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  // tarjeta de publicación
  Widget _tarjetaMascota(Publicacion publicacion) {
    final bool encontrada =
        publicacion.tipo.toLowerCase().contains('encontr');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetallePublicacionPage(
              publicacion: publicacion,
            ),
          ),
        );
      },
      child: Container(
        width: 165,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // foto de cloudinary o imagen local de respaldo
              SizedBox(
                height: 125,
                width: double.infinity,
                child: _construirImagenMascota(publicacion),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // nombre
                      Text(
                        publicacion.nombreMascota.isEmpty
                            ? 'Sin nombre'
                            : publicacion.nombreMascota,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF555555),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),

                      // estado
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: encontrada
                              ? const Color(0xFF20A39E)
                              : const Color(0xFFFF7A59),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          publicacion.tipo.isEmpty
                              ? 'Publicación'
                              : publicacion.tipo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ubicación
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFF20A39E),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              publicacion.ubicacion.isEmpty
                                  ? 'Ubicación no indicada'
                                  : publicacion.ubicacion,
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 11,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // indicador de publicación destacada
                      if (publicacion.destacada)
                        const Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Color(0xFFFF7A59),
                              size: 15,
                            ),
                            SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                'Destacada',
                                style: TextStyle(
                                  color: Color(0xFFFF7A59),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // muestra la foto publicada o una imagen local si no hay url
  Widget _construirImagenMascota(Publicacion publicacion) {
    final String urlImagen = publicacion.urlImagen.trim();

    if (urlImagen.isNotEmpty) {
      return Image.network(
        urlImagen,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF20A39E),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _imagenSinDisponible();
        },
      );
    }

    return Image.asset(
      _imagenMascota(publicacion.nombreMascota),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return _imagenSinDisponible();
      },
    );
  }

  // muestra un icono si no se puede cargar ninguna foto
  Widget _imagenSinDisponible() {
    return Container(
      color: const Color(0xFFF7F9F6),
      child: const Center(
        child: Icon(
          Icons.pets,
          color: Color(0xFF20A39E),
          size: 50,
        ),
      ),
    );
  }

  // selecciona una imagen local según el nombre
  String _imagenMascota(String nombre) {
    switch (nombre.toLowerCase()) {
      case 'milo':
        return 'assets/images/milo.jpg';
      case 'lola':
        return 'assets/images/lola.jpg';
      case 'simba':
        return 'assets/images/simba.jpg';
      case 'tomy':
        return 'assets/images/tomy.jpg';
      default:
        return 'assets/images/hero.jpg';
    }
  }

  // barra de navegación
  Widget _barraNavegacion() {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Color(0xFF20A39E),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _itemNavegacion(
            icono: Icons.home,
            texto: 'Inicio',
            indice: 0,
            onTap: _volverAlInicio,
          ),
          _itemNavegacion(
            icono: Icons.description,
            texto: 'Publicaciones',
            indice: 1,
            onTap: _abrirPublicaciones,
          ),

          // botón central
          GestureDetector(
            onTap: () => _abrirFormularioPublicacion(),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFFF7A59),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),

          _itemNavegacion(
            icono: Icons.map_outlined,
            texto: 'Mapa',
            indice: 2,
            onTap: _abrirMapa,
          ),
          _itemNavegacion(
            icono: Icons.person_outline,
            texto: 'Perfil',
            indice: 3,
            onTap: _abrirPerfil,
          ),
        ],
      ),
    );
  }

  // elemento de navegación
  Widget _itemNavegacion({
    required IconData icono,
    required String texto,
    required int indice,
    VoidCallback? onTap,
  }) {
    final bool seleccionado = _opcionSeleccionada == indice;

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
        } else {
          setState(() {
            _opcionSeleccionada = indice;
          });
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icono,
            color: Colors.white,
            size: seleccionado ? 25 : 23,
          ),
          const SizedBox(height: 2),
          Text(
            texto,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: seleccionado
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
