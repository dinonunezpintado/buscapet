import 'package:flutter/material.dart';

import '../viewmodel/inicio_view_model.dart';
import 'mapa_page.dart';

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
    setState(() {});
  }

  void _abrirMapa() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapaPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),

      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // ENCABEZADO
            // ==========================================

            Container(
              height: 90,
              width: double.infinity,
              color: const Color(0xFF20A39E),

              child: Row(
                children: [
                  const SizedBox(width: 18),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),

                  const Spacer(),

                  const Icon(
                    Icons.pets,
                    color: Colors.white,
                    size: 52,
                  ),

                  const SizedBox(width: 8),

                  const Text(
                    'BuscaPet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  const SizedBox(width: 56),
                ],
              ),
            ),

            // ==========================================
            // CONTENIDO
            // ==========================================

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ==================================
                    // IMAGEN PRINCIPAL
                    // ==================================

                    SizedBox(
                      width: double.infinity,
                      height: 330,

                      child: Image.asset(
                        'assets/images/hero.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ==================================
                    // BOTONES PRINCIPALES
                    // ==================================

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),

                      child: Row(
                        children: [
                          Expanded(
                            child: _botonPrincipal(
                              texto: 'PERDÍ MI\nMASCOTA',
                              color:
                                  const Color(0xFF20A39E),
                              icono: Icons.pets,
                              onPressed: () {},
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: _botonPrincipal(
                              texto:
                                  'ENCONTRÉ UNA\nMASCOTA',
                              color:
                                  const Color(0xFFFF7A59),
                              icono: Icons.pets,
                              onPressed: _abrirMapa,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 34),

                    // ==================================
                    // TÍTULO PUBLICACIONES
                    // ==================================

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),

                      child: Row(
  children: [
    const Icon(
      Icons.description_outlined,
      color: Color(0xFF20A39E),
      size: 34,
    ),

    const SizedBox(width: 10),

    Expanded(
      child: const Text(
        'Últimas publicaciones',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Color(0xFF555555),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),

    const SizedBox(width: 8),

    const Text(
      'Ver todas',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF20A39E),
      ),
    ),
  ],
),
                    ),

                    const SizedBox(height: 18),

                    // ==================================
                    // PUBLICACIONES
                    // ==================================

                    SizedBox(
                      height: 390,

                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),

                        itemCount:
                            _viewModel.publicaciones.length,

                        itemBuilder: (
                          context,
                          index,
                        ) {
                          final publicacion =
                              _viewModel.publicaciones[index];

                          return _tarjetaMascota(
                            publicacion,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ============================================
      // NAVEGACIÓN INFERIOR
      // ============================================

      bottomNavigationBar: _barraNavegacion(),
    );
  }

  // ==================================================
  // BOTÓN PRINCIPAL
  // ==================================================

  Widget _botonPrincipal({
    required String texto,
    required Color color,
    required IconData icono,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 125,

      child: ElevatedButton(
        onPressed: onPressed,

        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,

          elevation: 4,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
        ),

        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,

              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),

              child: Icon(
                icono,
                color: const Color(0xFF555555),
                size: 34,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                texto,

                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // TARJETA DE MASCOTA
  // ==================================================

  Widget _tarjetaMascota(
    Map<String, String> publicacion,
  ) {
    final bool encontrada =
        publicacion['estado'] == 'Encontrada';

    return Container(
      width: 205,

      margin: const EdgeInsets.only(
        right: 14,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // FOTO

            SizedBox(
              height: 175,
              width: double.infinity,

              child: Image.asset(
                publicacion['imagen']!,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // NOMBRE

                  Text(
                    publicacion['nombre']!,

                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF555555),
                    ),
                  ),

                  const SizedBox(height: 7),

                  // ESTADO

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: encontrada
                          ? const Color(0xFF20A39E)
                          : const Color(0xFFFF7A59),

                      borderRadius:
                          BorderRadius.circular(20),
                    ),

                    child: Text(
                      publicacion['estado']!,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // UBICACIÓN

                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF20A39E),
                        size: 19,
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: Text(
                          publicacion['ubicacion']!,
                          style: const TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // TIEMPO

                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Color(0xFF20A39E),
                        size: 19,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        publicacion['tiempo']!,
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // BARRA DE NAVEGACIÓN
  // ==================================================

  Widget _barraNavegacion() {
    return Container(
      height: 82,

      decoration: const BoxDecoration(
        color: Color(0xFF20A39E),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,

        children: [
          _itemNavegacion(
            icono: Icons.home,
            texto: 'Inicio',
            indice: 0,
          ),

          _itemNavegacion(
            icono: Icons.description,
            texto: 'Publicaciones',
            indice: 1,
          ),

          // BOTÓN CENTRAL +

          Container(
            width: 68,
            height: 68,

            decoration: BoxDecoration(
              color: const Color(0xFFFF7A59),
              shape: BoxShape.circle,

              border: Border.all(
                color: Colors.white,
                width: 4,
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                ),
              ],
            ),

            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 42,
            ),
          ),

          _itemNavegacion(
            icono: Icons.favorite_border,
            texto: 'Favoritos',
            indice: 2,
          ),

          _itemNavegacion(
            icono: Icons.person_outline,
            texto: 'Perfil',
            indice: 3,
          ),
        ],
      ),
    );
  }

  // ==================================================
  // ITEM DE NAVEGACIÓN
  // ==================================================

  Widget _itemNavegacion({
    required IconData icono,
    required String texto,
    required int indice,
  }) {
    final bool seleccionado =
        _opcionSeleccionada == indice;

    return GestureDetector(
      onTap: () {
        setState(() {
          _opcionSeleccionada = indice;
        });
      },

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            icono,
            color: Colors.white,
            size: seleccionado ? 30 : 27,
          ),

          const SizedBox(height: 3),

          Text(
            texto,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
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