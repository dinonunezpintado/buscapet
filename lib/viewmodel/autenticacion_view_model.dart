import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AutenticacionViewModel extends ChangeNotifier {
  final FirebaseAuth _autenticacion = FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _cargando = false;
  bool get cargando => _cargando;

  String? _mensajeError;
  String? get mensajeError => _mensajeError;

  bool _googleInicializado = false;

  Future<void> inicializarGoogle() async {
    if (_googleInicializado) {
      return;
    }

    await _googleSignIn.initialize();

    _googleInicializado = true;
  }

  Future<void> configurarNotificaciones() async {
    debugPrint(
      'INICIANDO CONFIGURACIÓN DE NOTIFICACIONES',
    );

    try {
      final mensajeria = FirebaseMessaging.instance;

      debugPrint('ANTES DEL PERMISO');

      final configuracion =
          await mensajeria.requestPermission();

      debugPrint(
        'PERMISO: ${configuracion.authorizationStatus}',
      );

      debugPrint('ANTES DEL TOKEN');

      final token = await mensajeria.getToken();

      debugPrint('TOKEN FCM: $token');

      final usuario = _autenticacion.currentUser;

      if (usuario == null) {
        debugPrint(
          'NO HAY USUARIO AUTENTICADO',
        );
        return;
      }

      if (token == null) {
        debugPrint(
          'NO SE PUDO OBTENER EL TOKEN FCM',
        );
        return;
      }

      await _firestore
          .collection('usuarios')
          .doc(usuario.uid)
          .set({
        'tokenFCM': token,
      }, SetOptions(merge: true));

      debugPrint(
        'TOKEN FCM GUARDADO EN FIRESTORE',
      );
    } catch (e) {
      debugPrint(
        'ERROR AL CONFIGURAR NOTIFICACIONES: $e',
      );
    }
  }

  Future<bool> iniciarSesion(
    String email,
    String contrasena,
  ) async {
    _cargando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      await _autenticacion.signInWithEmailAndPassword(
        email: email,
        password: contrasena,
      );

      await configurarNotificaciones();

      _cargando = false;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _cargando = false;

      if (e.code == 'invalid-credential') {
        _mensajeError =
            'El correo electrónico o la contraseña son incorrectos.';
      } else if (e.code == 'user-not-found') {
        _mensajeError =
            'No existe una cuenta con ese correo electrónico.';
      } else if (e.code == 'wrong-password') {
        _mensajeError =
            'La contraseña es incorrecta.';
      } else if (e.code == 'invalid-email') {
        _mensajeError =
            'El correo electrónico no es válido.';
      } else {
        _mensajeError =
            'No se pudo iniciar sesión. Intenta nuevamente.';
      }

      notifyListeners();

      return false;
    }
  }

  Future<bool> iniciarSesionConGoogle() async {
    _cargando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      await inicializarGoogle();

      if (!_googleSignIn.supportsAuthenticate()) {
        _mensajeError =
            'El inicio de sesión con Google no está disponible.';
        _cargando = false;
        notifyListeners();
        return false;
      }

      final cuentaGoogle =
          await _googleSignIn.authenticate();

      final autenticacionGoogle =
          cuentaGoogle.authentication;

      final idToken = autenticacionGoogle.idToken;

      if (idToken == null) {
        _mensajeError =
            'No se pudo obtener la información de Google.';
        _cargando = false;
        notifyListeners();
        return false;
      }

      final credencial = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final resultado =
          await _autenticacion.signInWithCredential(
        credencial,
      );

      final usuario = resultado.user;

      if (usuario == null) {
        _mensajeError =
            'No se pudo obtener el usuario de Google.';
        _cargando = false;
        notifyListeners();
        return false;
      }

      await _crearDocumentoUsuarioSiNoExiste(
        usuario,
      );

      await configurarNotificaciones();

      _cargando = false;
      notifyListeners();

      return true;
    } on GoogleSignInException catch (e) {
      _cargando = false;

      if (e.code == GoogleSignInExceptionCode.canceled) {
        _mensajeError =
            'El inicio de sesión con Google fue cancelado.';
      } else {
        _mensajeError =
            'No se pudo iniciar sesión con Google.';
      }

      notifyListeners();

      return false;
    } on FirebaseAuthException {
      _cargando = false;

      _mensajeError =
          'Firebase no pudo completar el inicio de sesión con Google.';

      notifyListeners();

      return false;
    } on FirebaseException {
      _cargando = false;

      _mensajeError =
          'No se pudieron guardar los datos del usuario.';

      notifyListeners();

      return false;
    } catch (e) {
      _cargando = false;

      _mensajeError =
          'Ocurrió un error al iniciar sesión con Google.';

      notifyListeners();

      return false;
    }
  }

  Future<bool> registrarse(
    String nombre,
    String apellido,
    String email,
    String contrasena,
  ) async {
    _cargando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      final credencialUsuario =
          await _autenticacion.createUserWithEmailAndPassword(
        email: email,
        password: contrasena,
      );

      final usuario = credencialUsuario.user;

      if (usuario == null) {
        _mensajeError =
            'No se pudo obtener el usuario creado.';
        _cargando = false;
        notifyListeners();
        return false;
      }

      await _firestore
          .collection('usuarios')
          .doc(usuario.uid)
          .set({
        'nombre': nombre,
        'apellido': apellido,
        'email': email,
        'fechaRegistro': FieldValue.serverTimestamp(),
        'activo': true,
      });

      await configurarNotificaciones();

      _cargando = false;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _cargando = false;

      if (e.code == 'email-already-in-use') {
        _mensajeError =
            'Ya existe una cuenta con ese correo electrónico.';
      } else if (e.code == 'invalid-email') {
        _mensajeError =
            'El correo electrónico no es válido.';
      } else if (e.code == 'weak-password') {
        _mensajeError =
            'La contraseña es demasiado débil.';
      } else {
        _mensajeError =
            'No se pudo crear la cuenta. Intenta nuevamente.';
      }

      notifyListeners();

      return false;
    } on FirebaseException {
      _cargando = false;

      _mensajeError =
          'La cuenta fue creada, pero no se pudieron guardar tus datos.';

      notifyListeners();

      return false;
    }
  }

  Future<void> _crearDocumentoUsuarioSiNoExiste(
    User usuario,
  ) async {
    final documento = await _firestore
        .collection('usuarios')
        .doc(usuario.uid)
        .get();

    if (documento.exists) {
      return;
    }

    String nombre = '';
    String apellido = '';

    if (usuario.displayName != null &&
        usuario.displayName!.trim().isNotEmpty) {
      final partesNombre =
          usuario.displayName!.trim().split(' ');

      nombre = partesNombre.first;

      if (partesNombre.length > 1) {
        apellido =
            partesNombre.sublist(1).join(' ');
      }
    }

    await _firestore
        .collection('usuarios')
        .doc(usuario.uid)
        .set({
      'nombre': nombre,
      'apellido': apellido,
      'email': usuario.email ?? '',
      'fechaRegistro': FieldValue.serverTimestamp(),
      'activo': true,
    });
  }

  Future<void> cerrarSesion() async {
    await _autenticacion.signOut();
    await _googleSignIn.signOut();
  }
}