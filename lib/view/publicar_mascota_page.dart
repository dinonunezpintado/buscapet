import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../services/imagen_service.dart';
import '../services/publicacion_service.dart';
import 'mapa_page.dart';

class PublicarMascotaPage extends StatefulWidget {
  final String tipoInicial;

  const PublicarMascotaPage({
    super.key,
    this.tipoInicial = 'Perdí mi mascota',
  });

  @override
  State<PublicarMascotaPage> createState() =>
      _PublicarMascotaPageState();
}

class _PublicarMascotaPageState
    extends State<PublicarMascotaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _razaController = TextEditingController();
  final _colorController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _descripcionController = TextEditingController();

  final ImagePicker _selectorImagen = ImagePicker();

  late String _tipo;
  String _especie = 'Perro';
  String _tamano = 'Mediano';
  String _sexo = 'No especificado';

  File? _imagenSeleccionada;
  LatLng? _ubicacionSeleccionada;

  bool _seleccionandoImagen = false;
  bool _publicando = false;

  final Color _colorFondo = const Color(0xFFF7F9F6);
  final Color _colorPrincipal = const Color(0xFF20A39E);
  final Color _colorAcento = const Color(0xFFFF7A59);

  @override
  void initState() {
    super.initState();
    _tipo = widget.tipoInicial;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _razaController.dispose();
    _colorController.dispose();
    _ubicacionController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarUbicacionEnMapa() async {
    FocusScope.of(context).unfocus();

    final LatLng? ubicacion = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (context) => const MapaPage(
          modoSeleccion: true,
        ),
      ),
    );

    if (!mounted || ubicacion == null) return;

    setState(() {
      _ubicacionSeleccionada = ubicacion;
    });
  }

  void _quitarUbicacionSeleccionada() {
    setState(() {
      _ubicacionSeleccionada = null;
    });
  }

  Future<void> _seleccionarImagen() async {
    if (_seleccionandoImagen || _publicando) return;

    setState(() {
      _seleccionandoImagen = true;
    });

    try {
      final XFile? archivo = await _selectorImagen.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (!mounted) return;

      if (archivo != null) {
        setState(() {
          _imagenSeleccionada = File(archivo.path);
        });
      }
    } catch (error) {
      debugPrint('Error al seleccionar imagen: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo seleccionar la foto. Intentá nuevamente.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _seleccionandoImagen = false;
        });
      }
    }
  }

  void _quitarImagen() {
    if (_publicando) return;

    setState(() {
      _imagenSeleccionada = null;
    });
  }

  Future<void> _continuar() async {
    FocusScope.of(context).unfocus();

    if (_publicando) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final imagen = _imagenSeleccionada;

    if (imagen == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Seleccioná una foto de la mascota para continuar.',
          ),
        ),
      );
      return;
    }

    final tipo = _tipo;
    final nombreMascota = _nombreController.text;
    final especie = _especie;
    final raza = _razaController.text;
    final color = _colorController.text;
    final tamano = _tamano;
    final sexo = _sexo;
    final ubicacion = _ubicacionController.text;
    final descripcion = _descripcionController.text;

    setState(() {
      _publicando = true;
    });

    try {
      final urlImagen = await ImagenService().subirImagen(imagen);

      
await PublicacionService().guardarPublicacion(
  tipo: tipo,
  nombreMascota: nombreMascota,
  especie: especie,
  raza: raza,
  color: color,
  tamano: tamano,
  sexo: sexo,
  ubicacion: ubicacion,
  descripcion: descripcion,
  urlImagen: urlImagen,
  latitud: _ubicacionSeleccionada?.latitude,
  longitud: _ubicacionSeleccionada?.longitude,
);


      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);

      Navigator.of(context).pop(true);

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            '¡Publicación creada correctamente!',
          ),
        ),
      );
    } catch (error) {
      debugPrint('Error al publicar mascota: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo publicar la mascota. '
            'Revisá tu conexión e intentá nuevamente.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _publicando = false;
        });
      }
    }
  }

  InputDecoration _decoracionCampo({
    required String etiqueta,
    required IconData icono,
    String? ayuda,
  }) {
    return InputDecoration(
      labelText: etiqueta,
      hintText: ayuda,
      prefixIcon: Icon(
        icono,
        color: _colorPrincipal,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: _colorPrincipal,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }

  Widget _tituloSeccion(String titulo, IconData icono) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 22,
        bottom: 12,
      ),
      child: Row(
        children: [
          Icon(
            icono,
            color: _colorPrincipal,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoTexto({
    required TextEditingController controller,
    required String etiqueta,
    required IconData icono,
    String? ayuda,
    int maxLineas = 1,
    bool obligatorio = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLineas,
      textCapitalization: TextCapitalization.sentences,
      decoration: _decoracionCampo(
        etiqueta: etiqueta,
        icono: icono,
        ayuda: ayuda,
      ),
      validator: (valor) {
        if (obligatorio &&
            (valor == null || valor.trim().isEmpty)) {
          return 'Este campo es obligatorio';
        }

        return null;
      },
    );
  }

  Widget _campoSeleccion({
    required String etiqueta,
    required IconData icono,
    required String valor,
    required List<String> opciones,
    required ValueChanged<String?> alCambiar,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: valor,
      isExpanded: true,
      decoration: _decoracionCampo(
        etiqueta: etiqueta,
        icono: icono,
      ),
      items: opciones.map((opcion) {
        return DropdownMenuItem<String>(
          value: opcion,
          child: Text(opcion),
        );
      }).toList(),
      onChanged: alCambiar,
    );
  }

  Widget _seccionFoto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _tituloSeccion(
          'Foto de la mascota',
          Icons.camera_alt_outlined,
        ),
        Text(
          'Agregá una foto para ayudar a reconocer a la mascota.',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        if (_imagenSeleccionada == null)
          InkWell(
            onTap: _seleccionandoImagen || _publicando
                ? null
                : _seleccionarImagen,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              height: 190,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _colorPrincipal,
                  width: 1.5,
                ),
              ),
              child: _seleccionandoImagen
                  ? Center(
                      child: CircularProgressIndicator(
                        color: _colorPrincipal,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          color: _colorPrincipal,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Seleccionar una foto',
                          style: TextStyle(
                            color: _colorPrincipal,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tocá aquí para abrir la galería',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
            ),
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Image.file(
                  _imagenSeleccionada!,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: _publicando ? null : _quitarImagen,
                    tooltip: 'Quitar foto',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                    ),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: ElevatedButton.icon(
                    onPressed: _seleccionandoImagen || _publicando
                        ? null
                        : _seleccionarImagen,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Cambiar foto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _colorPrincipal,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _seccionUbicacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _campoTexto(
          controller: _ubicacionController,
          etiqueta: 'Localidad o dirección (opcional)',
          ayuda: 'Ej.: Rivera, barrio o calle',
          icono: Icons.place_outlined,
          obligatorio: false,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _publicando
                ? null
                : _seleccionarUbicacionEnMapa,
            icon: const Icon(Icons.map_outlined),
            label: Text(
              _ubicacionSeleccionada == null
                  ? 'Marcar ubicación en el mapa'
                  : 'Cambiar ubicación del mapa',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _colorPrincipal,
              side: BorderSide(
                color: _colorPrincipal,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        if (_ubicacionSeleccionada != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _colorPrincipal.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: _colorPrincipal,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Punto seleccionado',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Latitud: ${_ubicacionSeleccionada!.latitude.toStringAsFixed(6)}\n'
                        'Longitud: ${_ubicacionSeleccionada!.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _publicando
                      ? null
                      : _quitarUbicacionSeleccionada,
                  tooltip: 'Quitar ubicación',
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          'Podés escribir la ubicación, marcarla en el mapa o dejar ambas opciones vacías.',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colorFondo,
      appBar: AppBar(
        title: const Text(
          'Publicar mascota',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _colorPrincipal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: AbsorbPointer(
            absorbing: _publicando,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                28,
              ),
              children: [
                Text(
                  'Ayudanos a reunir mascotas con sus familias.',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 15,
                  ),
                ),
                _tituloSeccion(
                  'Tipo de publicación',
                  Icons.pets,
                ),
                _campoSeleccion(
                  etiqueta: '¿Qué sucedió?',
                  icono: Icons.campaign_outlined,
                  valor: _tipo,
                  opciones: [
                    'Perdí mi mascota',
                    'Encontré una mascota',
                  ],
                  alCambiar: (valor) {
                    if (valor != null) {
                      setState(() {
                        _tipo = valor;
                      });
                    }
                  },
                ),
                _seccionFoto(),
                _tituloSeccion(
                  'Datos de la mascota',
                  Icons.pets_outlined,
                ),
                _campoTexto(
                  controller: _nombreController,
                  etiqueta: 'Nombre de la mascota',
                  ayuda: 'Si no lo sabés, podés dejarlo vacío',
                  icono: Icons.badge_outlined,
                  obligatorio: false,
                ),
                const SizedBox(height: 14),
                _campoSeleccion(
                  etiqueta: 'Especie',
                  icono: Icons.category_outlined,
                  valor: _especie,
                  opciones: [
                    'Perro',
                    'Gato',
                    'Otra',
                  ],
                  alCambiar: (valor) {
                    if (valor != null) {
                      setState(() {
                        _especie = valor;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                _campoTexto(
                  controller: _razaController,
                  etiqueta: 'Raza',
                  ayuda: 'Ej.: mestizo, labrador, siamés',
                  icono: Icons.pets,
                ),
                const SizedBox(height: 14),
                _campoTexto(
                  controller: _colorController,
                  etiqueta: 'Color y características',
                  ayuda: 'Ej.: marrón, manchas blancas',
                  icono: Icons.palette_outlined,
                ),
                const SizedBox(height: 14),
                _campoSeleccion(
                  etiqueta: 'Tamaño',
                  icono: Icons.straighten,
                  valor: _tamano,
                  opciones: [
                    'Pequeño',
                    'Mediano',
                    'Grande',
                  ],
                  alCambiar: (valor) {
                    if (valor != null) {
                      setState(() {
                        _tamano = valor;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                _campoSeleccion(
                  etiqueta: 'Sexo',
                  icono: Icons.wc_outlined,
                  valor: _sexo,
                  opciones: [
                    'Macho',
                    'Hembra',
                    'No especificado',
                  ],
                  alCambiar: (valor) {
                    if (valor != null) {
                      setState(() {
                        _sexo = valor;
                      });
                    }
                  },
                ),
                _tituloSeccion(
                  'Ubicación (opcional)',
                  Icons.location_on_outlined,
                ),
                _seccionUbicacion(),
                _tituloSeccion(
                  'Descripción',
                  Icons.description_outlined,
                ),
                _campoTexto(
                  controller: _descripcionController,
                  etiqueta: 'Contanos qué pasó',
                  ayuda: 'Agregá detalles útiles para identificarla.',
                  icono: Icons.notes_outlined,
                  maxLineas: 4,
                ),
                const SizedBox(height: 26),
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _publicando ? null : _continuar,
                    icon: _publicando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                      _publicando
                          ? 'Publicando...'
                          : 'Publicar mascota',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorAcento,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          _colorAcento.withValues(alpha: 0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}