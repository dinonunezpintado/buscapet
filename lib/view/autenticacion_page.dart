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

  final TextEditingController
      _contrasenaController =
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
                padding:
                    const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.pets,
                      size: 70,
                      color:
                          Color(0xFF20A39E),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'BuscaPet',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF20A39E),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Align(
                      alignment:
                          Alignment.centerLeft,
                      child: Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller:
                          _emailController,
                      keyboardType:
                          TextInputType
                              .emailAddress,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Correo electrónico',
                        prefixIcon:
                            const Icon(
                          Icons
                              .email_outlined,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller:
                          _contrasenaController,
                      obscureText: true,
                      decoration:
                          InputDecoration(
                        labelText:
                            'Contraseña',
                        prefixIcon:
                            const Icon(
                          Icons.lock_outline,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child:
                          ElevatedButton(
                        onPressed:
                            _viewModel.cargando
                                ? null
                                : _iniciarSesion,
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                                  0xFF20A39E),
                          foregroundColor:
                              Colors.white,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(12),
                          ),
                        ),
                        child: _viewModel
                                .cargando
                            ? const CircularProgressIndicator(
                                color:
                                    Colors.white,
                              )
                            : const Text(
                                'INICIAR SESIÓN',
                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child:
                          OutlinedButton
                              .icon(
                        onPressed:
                            _viewModel.cargando
                                ? null
                                : _iniciarSesionConGoogle,
                        icon: const Icon(
                          Icons
                              .account_circle_outlined,
                        ),
                        label: const Text(
                          'CONTINUAR CON GOOGLE',
                        ),
                        style:
                            OutlinedButton
                                .styleFrom(
                          foregroundColor:
                              Colors.black87,
                          side:
                              const BorderSide(
                            color: Colors.grey,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        const Text(
                          '¿No tienes una cuenta? ',
                        ),
                        TextButton(
                          onPressed:
                              _abrirRegistro,
                          child: const Text(
                            'REGÍSTRATE',
                            style:
                                TextStyle(
                              color: Color(
                                  0xFF20A39E),
                              fontWeight:
                                  FontWeight
                                      .bold,
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
}