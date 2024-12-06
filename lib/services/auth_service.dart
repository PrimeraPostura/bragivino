import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Registro de usuario
  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Enviar correo de verificación
      await userCredential.user?.sendEmailVerification();
      return userCredential.user;
    } catch (e) {
      throw e;
    }
  }

  // Iniciar sesión
  Future<User?> loginWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verificar si el correo ha sido confirmado
      if (userCredential.user?.emailVerified == false) {
        throw FirebaseAuthException(
            code: 'email-not-verified',
            message: 'Correo electrónico no verificado');
      }

      return userCredential.user;
    } catch (e) {
      throw e;
    }
  }

  // Recuperar contraseña
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Eliminar cuenta
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.delete(); // Eliminar la cuenta
      }
    } catch (e) {
      throw e; // Maneja el error si ocurre
    }
  }

  // Verificar si el correo está verificado
  Future<void> verifyEmail() async {
    User? user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Obtener el usuario actual
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
