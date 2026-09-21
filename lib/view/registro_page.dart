import 'package:flutter/material.dart';

import '../viewmodel/autenticacion_view_model.dart';
import 'inicio_page.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final AutenticacionViewModel _viewModel =
      AutenticacionViewModel();

  final TextEditingController _nombreController =
      TextEditingController();

  final TextEditingController _apellidoController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _contrasenaController =
      TextEditingController();

  final TextEditingController _repetirContrasenaController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    _viewModel.addListener(_actualizarPantalla);
  }

  void _actualizarPantalla() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_actualizarPantalla);

    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _contrasenaController.dispose();
    _repetirContrasenaController.dispose();

    _viewModel.dispose();

    super.dispose();
  }

  Future<void> _crearCuenta() async {
    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    final email = _emailController.text.trim();
    final contrasena = _contrasenaController.text;
    final repetirContrasena =
        _repetirContrasenaController.text;

    if (nombre.isEmpty ||
        apellido.isEmpty ||
        email.isEmpty ||
        contrasena.isEmpty ||
        repetirContrasena.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completá todos los campos.',
          ),
        ),
      );

      return;
    }

    if (contrasena != repetirContrasena) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Las contraseñas no coinciden.',
          ),
        ),
      );

      return;
    }

    final registroCorrecto =
        await _viewModel.registrarse(
      nombre,
      apellido,
      email,
      contrasena,
    );

    if (!mounted) {
      return;
    }

    if (registroCorrecto) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const InicioPage(),
        ),
      );
    } else if (_viewModel.mensajeError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.mensajeError!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: const Color(0xFF20A39E),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          'Crear cuenta',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // logo
              const Center(
                child: Icon(
                  Icons.pets,
                  size: 52,
                  color: Color(0xFF20A39E),
                ),
              ),

              const SizedBox(height: 8),

              // título
              const Center(
                child: Text(
                  '¡Bienvenido a BuscaPet!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 5),

              // subtítulo
              const Center(
                child: Text(
                  'Creá tu cuenta para comenzar.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),

              // nombre y apellido
              Row(
                children: [
                  Expanded(
                    child: _campoTexto(
                      controller: _nombreController,
                      etiqueta: 'Nombre',
                      icono: Icons.person_outline,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _campoTexto(
                      controller: _apellidoController,
                      etiqueta: 'Apellido',
                      icono: Icons.person_outline,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // correo
              _campoTexto(
                controller: _emailController,
                etiqueta: 'Correo electrónico',
                icono: Icons.email_outlined,
                tipoTeclado:
                    TextInputType.emailAddress,
              ),

              const SizedBox(height: 12),

              // contraseña
              _campoTexto(
                controller: _contrasenaController,
                etiqueta: 'Contraseña',
                icono: Icons.lock_outline,
                ocultarTexto: true,
              ),

              const SizedBox(height: 12),

              // repetir contraseña
              _campoTexto(
                controller:
                    _repetirContrasenaController,
                etiqueta: 'Repetir contraseña',
                icono: Icons.lock_outline,
                ocultarTexto: true,
              ),

              const SizedBox(height: 18),

              // botón crear cuenta
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF7A59)
                          .withValues(alpha: 0.22),
                      blurRadius: 9,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _viewModel.cargando
                      ? null
                      : _crearCuenta,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFFF7A59),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFFFF7A59)
                            .withValues(alpha: 0.55),
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  child: _viewModel.cargando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'CREAR CUENTA',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 14),

              // volver al inicio de sesión
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize:
                        MaterialTapTargetSize
                            .shrinkWrap,
                  ),
                  child: const Text(
                    '¿Ya tenés una cuenta? INICIÁ SESIÓN',
                    style: TextStyle(
                      color: Color(0xFF20A39E),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // campo de texto
  Widget _campoTexto({
    required TextEditingController controller,
    required String etiqueta,
    required IconData icono,
    TextInputType? tipoTeclado,
    bool ocultarTexto = false,
  }) {
    return SizedBox(
      height: 60,
      child: TextField(
        controller: controller,
        keyboardType: tipoTeclado,
        obscureText: ocultarTexto,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF444444),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: etiqueta,
          labelStyle: const TextStyle(
            fontSize: 15,
            color: Color(0xFF666666),
          ),
          prefixIcon: Icon(
            icono,
            color: const Color(0xFF20A39E),
            size: 22,
          ),
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFD9DEDC),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF20A39E),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}