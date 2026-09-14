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
        15,
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
            // ENCABEZADO

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


            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 22),

                    // MAPA

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),

                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),

                        child: SizedBox(
                          height: 480,

                          child: FlutterMap(
                            mapController: _mapController,

                            options: MapOptions(
                              initialCenter: ubicacionMascota,
                              initialZoom: 15,

                              onTap: (tapPosition, posicion) {
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

                              // aqui me indica el trayecto por calles
                              if (_viewModel.rutaCalculada)
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points:
                                          _viewModel.puntosRuta,
                                      strokeWidth: 6,
                                      color:
                                          const Color(0xFFFF7A59),
                                    ),
                                  ],
                                ),

                             

                              MarkerLayer(
                                markers: [
                                  // aquí me muestra mi ubicación en el mapa

                                  if (_viewModel.latitudUsuario !=
                                          null &&
                                      _viewModel.longitudUsuario !=
                                          null)
                                    Marker(
                                      point: LatLng(
                                        _viewModel.latitudUsuario!,
                                        _viewModel.longitudUsuario!,
                                      ),
                                      width: 70,
                                      height: 70,

                                      child: const Icon(
                                        Icons.my_location,
                                        color:
                                            Color(0xFF20A39E),
                                        size: 48,
                                      ),
                                    ),

                                  // aquí me muestra la ubicación de la mascota en el mapa

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

                    
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),

                      child: SizedBox(
                        width: double.infinity,
                        height: 70,

                        child: ElevatedButton.icon(
                          onPressed: _viewModel.obteniendoUbicacion
                              ? null
                              : _usarMiUbicacion,

                          icon: const Icon(
                            Icons.my_location,
                            size: 30,
                          ),

                          label: Text(
                            _viewModel.obteniendoUbicacion
                                ? 'OBTENIENDO...'
                                : 'USAR MI UBICACIÓN',

                            style: const TextStyle(
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

                    
                    if (_viewModel.mensajeError != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 12,
                          left: 20,
                          right: 20,
                        ),

                        child: Text(
                          _viewModel.mensajeError!,
                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    
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

                          label: Text(
                            _viewModel.calculandoRuta
                                ? 'CALCULANDO...'
                                : 'CALCULAR RUTA',

                            style: const TextStyle(
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
            // TÍTULO

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