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
        backgroundColor: const Color(0xFF20A39E),
        foregroundColor: Colors.white,
        title: const Text(
          'Crear cuenta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(
                  Icons.pets,
                  size: 60,
                  color: Color(0xFF20A39E),
                ),
              ),

              const SizedBox(height: 15),

              const Center(
                child: Text(
                  '¡Bienvenido a BuscaPet!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF444444),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 8),

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

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: const Icon(
                          Icons.person_outline,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: TextField(
                      controller: _apellidoController,
                      decoration: InputDecoration(
                        labelText: 'Apellido',
                        prefixIcon: const Icon(
                          Icons.person_outline,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              TextField(
                controller: _emailController,
                keyboardType:
                    TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: _contrasenaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller:
                    _repetirContrasenaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Repetir contraseña',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _viewModel.cargando
                      ? null
                      : _crearCuenta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFFF7A59),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  child: _viewModel.cargando
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child:
                              CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'CREAR CUENTA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '¿Ya tenés una cuenta? INICIÁ SESIÓN',
                    style: TextStyle(
                      color: Color(0xFF20A39E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}