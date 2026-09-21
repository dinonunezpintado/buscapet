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

  final MapController _mapController = MapController();

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

  Future<void> _usarMiUbicacion() async {
    await _viewModel.obtenerUbicacion();

    if (_viewModel.latitudUsuario != null &&
        _viewModel.longitudUsuario != null) {
      final ubicacionUsuario = LatLng(
        _viewModel.latitudUsuario!,
        _viewModel.longitudUsuario!,
      );

      _mapController.move(
        ubicacionUsuario,
        16,
      );
    }
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
            // encabezado
            Container(
              height: 64,
              width: double.infinity,
              color: const Color(0xFF20A39E),
              child: Row(
                children: [
                  const SizedBox(width: 8),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),

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

                  const SizedBox(width: 42),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // mapa
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          height: 360,
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: ubicacionMascota,
                              initialZoom: 16,
                              onTap: (
                                tapPosition,
                                posicion,
                              ) {
                                _viewModel.seleccionarDestino(
                                  posicion,
                                );
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'com.example.buscapet',
                              ),

                              // muestra el trayecto por calles
                              if (_viewModel.rutaCalculada)
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points:
                                          _viewModel.puntosRuta,
                                      strokeWidth: 5,
                                      color:
                                          const Color(0xFFFF7A59),
                                    ),
                                  ],
                                ),

                              MarkerLayer(
                                markers: [
                                  // ubicación del usuario
                                  if (_viewModel.latitudUsuario !=
                                          null &&
                                      _viewModel.longitudUsuario !=
                                          null)
                                    Marker(
                                      point: LatLng(
                                        _viewModel.latitudUsuario!,
                                        _viewModel.longitudUsuario!,
                                      ),
                                      width: 50,
                                      height: 50,
                                      child: const Icon(
                                        Icons.my_location,
                                        color:
                                            Color(0xFF20A39E),
                                        size: 34,
                                      ),
                                    ),

                                  // ubicación de la mascota
                                  Marker(
                                    point: ubicacionMascota,
                                    width: 50,
                                    height: 50,
                                    child: const Icon(
                                      Icons.location_on,
                                      color:
                                          Color(0xFFFF7A59),
                                      size: 42,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // botón ubicación
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed:
                              _viewModel.obteniendoUbicacion
                                  ? null
                                  : _usarMiUbicacion,
                          icon: const Icon(
                            Icons.my_location,
                            size: 21,
                          ),
                          label: Text(
                            _viewModel.obteniendoUbicacion
                                ? 'OBTENIENDO...'
                                : 'USAR MI UBICACIÓN',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFFF7A59),
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (_viewModel.mensajeError != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                          left: 16,
                          right: 16,
                        ),
                        child: Text(
                          _viewModel.mensajeError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),

                    // botón calcular ruta
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed:
                              _viewModel.calculandoRuta
                                  ? null
                                  : () async {
                                      await _viewModel
                                          .calcularRuta();
                                    },
                          icon: const Icon(
                            Icons.alt_route,
                            size: 21,
                          ),
                          label: Text(
                            _viewModel.calculandoRuta
                                ? 'CALCULANDO...'
                                : 'CALCULAR RUTA',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF20A39E),
                            foregroundColor: Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // información de la ruta
                    _tarjetaRuta(),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // tarjeta de ruta
  Widget _tarjetaRuta() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.08,
              ),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'RUTA HACIA LA MASCOTA',
              style: TextStyle(
                color: Color(0xFF20A39E),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF20A39E),
                  size: 25,
                ),

                const SizedBox(width: 5),

                Text(
                  '${_viewModel.distancia.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF555555),
                  ),
                ),

                const SizedBox(width: 22),

                Container(
                  height: 28,
                  width: 1,
                  color: const Color(0xFFDDDDDD),
                ),

                const SizedBox(width: 22),

                const Icon(
                  Icons.access_time,
                  color: Color(0xFF20A39E),
                  size: 25,
                ),

                const SizedBox(width: 5),

                Text(
                  '${_viewModel.tiempoEstimado} min',
                  style: const TextStyle(
                    fontSize: 18,
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