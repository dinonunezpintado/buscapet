import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../viewmodel/mapa_view_model.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final MapaViewModel _viewModel = MapaViewModel();

  // Ubicación de ejemplo para esta entrega.
  final LatLng _ubicacionUsuario = const LatLng(
    -30.90914,
    -55.54420,
  );

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

  @override
  Widget build(BuildContext context) {
    final LatLng ubicacionMascota = LatLng(
      _viewModel.latitudMascota,
      _viewModel.longitudMascota,
    );

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
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),

                  const Spacer(),

                  const Icon(
                    Icons.pets,
                    color: Colors.white,
                    size: 45,
                  ),

                  const SizedBox(width: 8),

                  const Text(
                    'BuscaPet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  const SizedBox(width: 50),
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
                    const SizedBox(height: 22),

                    // ==================================
                    // MAPA
                    // ==================================

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),

                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),

                        child: SizedBox(
                          height: 480,

                          child: FlutterMap(
                            options: MapOptions(
                                initialCenter: ubicacionMascota,
                                initialZoom: 15,

                                onTap: (tapPosition, posicion) {
                                _viewModel.seleccionarDestino(posicion);
                                },
                            ),

                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',

                                userAgentPackageName:
                                    'com.example.buscapet',
                              ),

                              if (_viewModel.rutaCalculada)
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: _viewModel.puntosRuta,
                                    strokeWidth: 6,
                                    color: const Color(0xFFFF7A59),
                                  ),
                                ],
                              ),

                              MarkerLayer(
                                markers: [
                                  // ==========================
                                  // UBICACIÓN DEL USUARIO
                                  // ==========================

                                  Marker(
                                    point: _ubicacionUsuario,
                                    width: 70,
                                    height: 70,

                                    child: const Icon(
                                      Icons.my_location,
                                      color:
                                          Color(0xFF20A39E),
                                      size: 48,
                                    ),
                                  ),

                                  // ==========================
                                  // UBICACIÓN DE LA MASCOTA
                                  // ==========================

                                  Marker(
                                    point: ubicacionMascota,
                                    width: 70,
                                    height: 70,

                                    child: const Icon(
                                      Icons.location_on,
                                      color:
                                          Color(0xFFFF7A59),
                                      size: 58,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ==================================
                    // BOTÓN MI UBICACIÓN
                    // ==================================

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),

                      child: SizedBox(
                        width: double.infinity,
                        height: 70,

                        child: ElevatedButton.icon(
                          onPressed: () {},

                          icon: const Icon(
                            Icons.my_location,
                            size: 30,
                          ),

                          label: const Text(
                            'USAR MI UBICACIÓN',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFFF7A59),

                            foregroundColor: Colors.white,

                            elevation: 3,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ==================================
                    // BOTÓN CALCULAR RUTA
                    // ==================================

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),

                      child: SizedBox(
                        width: double.infinity,
                        height: 70,

                        child: ElevatedButton.icon(
                          onPressed: _viewModel.calculandoRuta
                            ? null
                            : () async {
                                await _viewModel.calcularRuta();
                              },

                          icon: const Icon(
                            Icons.alt_route,
                            size: 30,
                          ),

                          label: const Text(
                            'CALCULAR RUTA',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFFF7A59),

                            foregroundColor: Colors.white,

                            elevation: 3,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ==================================
                    // INFORMACIÓN DE LA RUTA
                    // ==================================

                    _tarjetaRuta(),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================================================
  // TARJETA DE RUTA
  // ==================================================

  Widget _tarjetaRuta() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(24),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.10,
              ),

              blurRadius: 8,

              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          children: [
            // ==================================
            // TÍTULO
            // ==================================

            const Text(
              'RUTA HACIA LA MASCOTA',

              style: TextStyle(
                color: Color(0xFF20A39E),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 22),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                // DISTANCIA

                const Icon(
                  Icons.location_on,
                  color: Color(0xFF20A39E),
                  size: 34,
                ),

                const SizedBox(width: 8),

                Text(
                  '${_viewModel.distancia.toStringAsFixed(1)} km',

                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF555555),
                  ),
                ),

                const SizedBox(width: 30),

                Container(
                  height: 40,
                  width: 1,
                  color: const Color(0xFFDDDDDD),
                ),

                const SizedBox(width: 30),

                // TIEMPO

                const Icon(
                  Icons.access_time,
                  color: Color(0xFF20A39E),
                  size: 34,
                ),

                const SizedBox(width: 8),

                Text(
                  '${_viewModel.tiempoEstimado} min',

                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}