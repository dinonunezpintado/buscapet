
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/publicacion.dart';
import '../services/publicacion_service.dart';
import '../viewmodel/mapa_view_model.dart';

class MapaPage extends StatefulWidget {
  final bool modoSeleccion;

  const MapaPage({
    super.key,
    this.modoSeleccion = false,
  });

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final MapaViewModel _viewModel = MapaViewModel();
  final MapController _mapController = MapController();
  final PublicacionService _publicacionService =
      PublicacionService();

  bool _puntoSeleccionado = false;
  bool _cargandoPublicaciones = false;
  List<Publicacion> _publicaciones = [];
  Publicacion? _publicacionSeleccionada;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_actualizarPantalla);

    if (!widget.modoSeleccion) {
      _cargarPublicaciones();
    }
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

  Future<void> _cargarPublicaciones() async {
    setState(() {
      _cargandoPublicaciones = true;
    });

    try {
      final publicaciones =
          await _publicacionService.obtenerPublicaciones();

      if (!mounted) return;

      final publicacionesConUbicacion = publicaciones.where((publicacion) {
        final latitud = publicacion.latitud;
        final longitud = publicacion.longitud;

        return latitud != null &&
            longitud != null &&
            latitud >= -90 &&
            latitud <= 90 &&
            longitud >= -180 &&
            longitud <= 180;
      }).toList();

      setState(() {
        _publicaciones = publicacionesConUbicacion;
        _cargandoPublicaciones = false;
      });

      // centra el mapa en las publicaciones que tienen coordenadas
      if (publicacionesConUbicacion.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          final puntos = publicacionesConUbicacion.map((publicacion) {
            return LatLng(
              publicacion.latitud!,
              publicacion.longitud!,
            );
          }).toList();

          if (puntos.length == 1) {
            _mapController.move(puntos.first, 14);
          } else {
            final limites = LatLngBounds.fromPoints(puntos);
            _mapController.fitCamera(
              CameraFit.bounds(
                bounds: limites,
                padding: const EdgeInsets.all(60),
                maxZoom: 15,
              ),
            );
          }
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargandoPublicaciones = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudieron cargar las publicaciones del mapa.',
          ),
        ),
      );
    }
  }

  void _seleccionarPunto(LatLng posicion) {
    _viewModel.seleccionarDestino(posicion);

    if (widget.modoSeleccion) {
      setState(() {
        _puntoSeleccionado = true;
      });
    }
  }

  void _confirmarUbicacion() {
    if (!_puntoSeleccionado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tocá el mapa para marcar la ubicación.',
          ),
        ),
      );
      return;
    }

    final ubicacion = LatLng(
      _viewModel.latitudMascota,
      _viewModel.longitudMascota,
    );

    Navigator.of(context).pop(ubicacion);
  }

  Future<void> _usarMiUbicacion() async {
    await _viewModel.obtenerUbicacion();

    if (!mounted) return;

    if (_viewModel.latitudUsuario != null &&
        _viewModel.longitudUsuario != null) {
      final ubicacionUsuario = LatLng(
        _viewModel.latitudUsuario!,
        _viewModel.longitudUsuario!,
      );

      _mapController.move(ubicacionUsuario, 16);

      if (widget.modoSeleccion) {
        _seleccionarPunto(ubicacionUsuario);
      }
    }
  }

  bool _esMascotaPerdida(Publicacion publicacion) {
    final tipo = publicacion.tipo.toLowerCase();
    return tipo.contains('perd') || tipo.contains('perdida');
  }

  double? _distanciaDesdeMiUbicacion(Publicacion publicacion) {
    final latitudUsuario = _viewModel.latitudUsuario;
    final longitudUsuario = _viewModel.longitudUsuario;
    final latitudMascota = publicacion.latitud;
    final longitudMascota = publicacion.longitud;

    if (latitudUsuario == null ||
        longitudUsuario == null ||
        latitudMascota == null ||
        longitudMascota == null) {
      return null;
    }

    return const Distance().as(
      LengthUnit.Kilometer,
      LatLng(latitudUsuario, longitudUsuario),
      LatLng(latitudMascota, longitudMascota),
    );
  }

  Future<void> _irHaciaPublicacion(Publicacion publicacion) async {
    final latitud = publicacion.latitud;
    final longitud = publicacion.longitud;

    if (latitud == null || longitud == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta publicación no tiene coordenadas válidas.'),
        ),
      );
      return;
    }

    _viewModel.seleccionarDestino(LatLng(latitud, longitud));
    setState(() {
      _publicacionSeleccionada = publicacion;
    });

    if (_viewModel.latitudUsuario == null ||
        _viewModel.longitudUsuario == null) {
      await _viewModel.obtenerUbicacion();
    }

    if (!mounted) return;

    if (_viewModel.latitudUsuario == null ||
        _viewModel.longitudUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.mensajeError ??
                'No se pudo obtener tu ubicación actual.',
          ),
        ),
      );
      return;
    }

    await _viewModel.calcularRuta();

    if (!mounted) return;

    if (_viewModel.rutaCalculada) {
      final puntos = _viewModel.puntosRuta;
      if (puntos.isNotEmpty) {
        final bounds = LatLngBounds.fromPoints(puntos);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(48),
          ),
        );
      }
    } else if (_viewModel.mensajeError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.mensajeError!)),
      );
    }
  }

  void _mostrarPublicacion(Publicacion publicacion) {
    _viewModel.seleccionarDestino(
      LatLng(publicacion.latitud!, publicacion.longitud!),
    );

    setState(() {
      _publicacionSeleccionada = publicacion;
    });

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final encontrada = !_esMascotaPerdida(publicacion);
        final distancia = _distanciaDesdeMiUbicacion(publicacion);

        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 94,
                        height: 94,
                        child: _construirFoto(publicacion, iconSize: 38),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: encontrada
                                  ? const Color(0xFFFF7A59)
                                  : const Color(0xFF20A39E),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              encontrada
                                  ? 'Mascota encontrada'
                                  : 'Mascota perdida',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            publicacion.nombreMascota.isNotEmpty
                                ? publicacion.nombreMascota
                                : 'Mascota sin nombre',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF343A40),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (publicacion.especie.isNotEmpty)
                            Text(
                              publicacion.especie,
                              style: const TextStyle(
                                color: Color(0xFF737B80),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (publicacion.ubicacion.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF20A39E),
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          publicacion.ubicacion,
                          style: const TextStyle(
                            color: Color(0xFF596268),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (publicacion.descripcion.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    publicacion.descripcion,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF596268),
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F8F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.near_me_outlined,
                        color: Color(0xFF20A39E),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          distancia == null
                              ? 'Obtené tu ubicación para ver la distancia'
                              : 'A ${distancia < 1 ? '${(distancia * 1000).round()} m' : '${distancia.toStringAsFixed(1)} km'} de tu ubicación',
                          style: const TextStyle(
                            color: Color(0xFF3D5553),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('Cerrar'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF20A39E),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _irHaciaPublicacion(publicacion);
                        },
                        icon: const Icon(Icons.navigation_outlined),
                        label: const Text('Cómo llegar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF20A39E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _construirFoto(
    Publicacion publicacion, {
    double iconSize = 25,
  }) {
    final url = publicacion.urlImagen.trim();

    if (url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _iconoMascota(iconSize),
      );
    }

    return _iconoMascota(iconSize);
  }

  Widget _iconoMascota(double iconSize) {
    return Container(
      color: const Color(0xFFF0F7F5),
      child: Center(
        child: Icon(
          Icons.pets,
          color: const Color(0xFF20A39E),
          size: iconSize,
        ),
      ),
    );
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
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Text(
                        widget.modoSeleccion
                            ? 'Tocá el mapa para indicar dónde se perdió o encontraste la mascota.'
                            : 'Las mascotas con ubicación aparecen señaladas en el mapa.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
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
                              initialZoom: 13,
                              onTap: (tapPosition, posicion) {
                                _seleccionarPunto(posicion);
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'com.example.buscapet',
                              ),
                              if (!widget.modoSeleccion &&
                                  _viewModel.rutaCalculada)
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: _viewModel.puntosRuta,
                                      strokeWidth: 7,
                                      color: const Color(0xFF20A39E),
                                      borderStrokeWidth: 2,
                                      borderColor: Colors.white,
                                    ),
                                  ],
                                ),
                              MarkerLayer(
                                markers: [
                                  if (_viewModel.latitudUsuario != null &&
                                      _viewModel.longitudUsuario != null)
                                    Marker(
                                      point: LatLng(
                                        _viewModel.latitudUsuario!,
                                        _viewModel.longitudUsuario!,
                                      ),
                                      width: 48,
                                      height: 48,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.18,
                                              ),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.my_location,
                                          color: Color(0xFF20A39E),
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  if (widget.modoSeleccion ||
                                      _viewModel.rutaCalculada)
                                    Marker(
                                      point: ubicacionMascota,
                                      width: 44,
                                      height: 50,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Color(0xFFFF7A59),
                                        size: 42,
                                      ),
                                    ),
                                  if (!widget.modoSeleccion)
                                    ..._publicaciones.map((publicacion) {
                                      final esPerdida =
                                          _esMascotaPerdida(publicacion);
                                      final seleccionada =
                                          identical(
                                            _publicacionSeleccionada,
                                            publicacion,
                                          );

                                      return Marker(
                                        point: LatLng(
                                          publicacion.latitud!,
                                          publicacion.longitud!,
                                        ),
                                        width: seleccionada ? 68 : 58,
                                        height: seleccionada ? 76 : 66,
                                        child: GestureDetector(
                                          onTap: () async {
                                            if (_viewModel.latitudUsuario == null ||
                                                _viewModel.longitudUsuario == null) {
                                              await _viewModel.obtenerUbicacion();
                                            }

                                            if (!mounted) return;

                                            _mostrarPublicacion(publicacion);
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: seleccionada ? 54 : 46,
                                                height: seleccionada ? 54 : 46,
                                                padding: const EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  color: esPerdida
                                                      ? const Color(0xFFFF7A59)
                                                      : const Color(0xFF20A39E),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: seleccionada ? 3 : 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(alpha: 0.22),
                                                      blurRadius: 7,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: ClipOval(
                                                  child: _construirFoto(
                                                    publicacion,
                                                    iconSize: 24,
                                                  ),
                                                ),
                                              ),
                                              Icon(
                                                Icons.location_on,
                                                color: esPerdida
                                                    ? const Color(0xFFFF7A59)
                                                    : const Color(0xFF20A39E),
                                                size: 19,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _viewModel.obteniendoUbicacion
                              ? null
                              : _usarMiUbicacion,
                          icon: const Icon(Icons.my_location),
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
                            backgroundColor: const Color(0xFFFF7A59),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_viewModel.mensajeError != null)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          _viewModel.mensajeError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    if (widget.modoSeleccion) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: _puntoSeleccionado
                                ? _confirmarUbicacion
                                : null,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text(
                              'CONFIRMAR UBICACIÓN',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF20A39E),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'La ubicación es opcional. Podés volver al formulario sin seleccionarla.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ] else ...[
                      if (_cargandoPublicaciones)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            color: Color(0xFF20A39E),
                          ),
                        ),
                      if (!_cargandoPublicaciones)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          child: Text(
                            _publicaciones.isEmpty
                                ? 'No hay publicaciones con coordenadas para mostrar.'
                                : '${_publicaciones.length} publicaciones con ubicación en el mapa',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF596268),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFFFF7A59),
                            ),
                            const SizedBox(width: 4),
                            const Expanded(
                              child: Text('Mascota perdida'),
                            ),
                            const Icon(
                              Icons.location_on,
                              color: Color(0xFF20A39E),
                            ),
                            const SizedBox(width: 4),
                            const Expanded(
                              child: Text('Mascota encontrada'),
                            ),
                            IconButton(
                              tooltip: 'Actualizar publicaciones',
                              onPressed: _cargarPublicaciones,
                              icon: const Icon(Icons.refresh),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _viewModel.calculandoRuta
                                ? null
                                : () async {
                                    await _viewModel.calcularRuta();
                                  },
                            icon: const Icon(Icons.alt_route),
                            label: Text(
                              _viewModel.calculandoRuta
                                  ? 'CALCULANDO...'
                                  : _publicacionSeleccionada == null
                                      ? 'CALCULAR RUTA'
                                      : 'CÓMO LLEGAR A LA MASCOTA',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF20A39E),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _tarjetaRuta(),
                    ],
                    const SizedBox(height: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
              color: Colors.black.withValues(alpha: 0.08),
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
              mainAxisAlignment: MainAxisAlignment.center,
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
                  color: Color(0xFFDDDDDD),
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
