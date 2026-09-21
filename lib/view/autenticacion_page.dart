import 'package:flutter/material.dart';

import '../viewmodel/autenticacion_view_model.dart';
import 'inicio_page.dart';
import 'registro_page.dart';

class AutenticacionPage extends StatefulWidget {
  const AutenticacionPage({super.key});

  @override
  State<AutenticacionPage> createState() =>
      _AutenticacionPageState();
}

class _AutenticacionPageState
    extends State<AutenticacionPage> {
  final AutenticacionViewModel _viewModel =
      AutenticacionViewModel();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _contrasenaController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _contrasenaController.dispose();
    _viewModel.dispose();

    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final email =
        _emailController.text.trim();

    final contrasena =
        _contrasenaController.text.trim();

    if (email.isEmpty || contrasena.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa el correo y la contraseña.',
          ),
        ),
      );

      return;
    }

    final inicioCorrecto =
        await _viewModel.iniciarSesion(
      email,
      contrasena,
    );

    if (!mounted) {
      return;
    }

    if (inicioCorrecto) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const InicioPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.mensajeError ??
                'No se pudo iniciar sesión.',
          ),
        ),
      );
    }
  }

  Future<void> _iniciarSesionConGoogle() async {
    final inicioCorrecto =
        await _viewModel.iniciarSesionConGoogle();

    if (!mounted) {
      return;
    }

    if (inicioCorrecto) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const InicioPage(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _viewModel.mensajeError ??
                'No se pudo iniciar sesión con Google.',
          ),
        ),
      );
    }
  }

  void _abrirRegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const RegistroPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, child) {
        return Scaffold(
          backgroundColor:
              const Color(0xFFF7F9F6),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    // logo
                    const Icon(
                      Icons.pets,
                      size: 52,
                      color: Color(0xFF20A39E),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'BuscaPet',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF20A39E),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // título
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

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

                    const SizedBox(height: 18),

                    // botón iniciar sesión
                    _botonPrincipal(),

                    const SizedBox(height: 12),

                    // botón de google
                    _botonGoogle(),

                    const SizedBox(height: 18),

                    // registro
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿No tienes una cuenta?',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF555555),
                          ),
                        ),

                        TextButton(
                          onPressed: _abrirRegistro,
                          style: TextButton.styleFrom(
                            padding:
                                const EdgeInsets.only(
                              left: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize:
                                MaterialTapTargetSize
                                    .shrinkWrap,
                          ),
                          child: const Text(
                            'REGÍSTRATE',
                            style: TextStyle(
                              color: Color(0xFF20A39E),
                              fontSize: 14,
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
          ),
        );
      },
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

  // botón principal
  Widget _botonPrincipal() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF20A39E)
                .withValues(alpha: 0.20),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _viewModel.cargando
            ? null
            : _iniciarSesion,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFF20A39E),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFF20A39E)
                  .withValues(alpha: 0.55),
          elevation: 0,
          shape: RoundedRectangleBorder(
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
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Text(
                'INICIAR SESIÓN',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  // botón de google
  Widget _botonGoogle() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _viewModel.cargando
            ? null
            : _iniciarSesionConGoogle,
        style: OutlinedButton.styleFrom(
          foregroundColor:
              const Color(0xFF333333),
          backgroundColor: Colors.white,
          side: const BorderSide(
            color: Color(0xFFD9DEDC),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/google_logo.png',
              width: 22,
              height: 22,
            ),

            const SizedBox(width: 10),

            const Text(
              'Continuar con Google',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}