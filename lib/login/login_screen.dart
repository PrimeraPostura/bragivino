import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'validators.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true; // Switch between login and register
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = ''; // Variable to hold success message

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = '';
      _successMessage = ''; // Clear success message when switching forms
    });
  }

  // Función para mostrar el cuadro de diálogo de políticas de privacidad
  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // No permitir cerrar el diálogo tocando fuera
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Políticas de Privacidad'),
          content: SingleChildScrollView(
            child: Text(
              '''
              Políticas de privacidad de la aplicación "Bragivino"
              
              1. Recopilación de Datos:
              Solo recopilamos la dirección de correo electrónico del usuario para el registro y la autenticación en la aplicación. No recopilamos información adicional como nombres u otros datos personales.

              2. Uso de los Datos:
              La dirección de correo electrónico se utiliza exclusivamente para la autenticación del usuario y no se compartirá con terceros sin el consentimiento expreso del usuario, salvo por motivos legales.

              3. Seguridad:
              Implementamos medidas de seguridad para proteger la dirección de correo electrónico del usuario, que está gestionada a través del sistema de autenticación de Firebase. Toda la información personal se maneja con estricta confidencialidad.

              4. Acceso a los Datos:
              El único dato que recopilamos es el correo electrónico, y el usuario tiene acceso a su información en cualquier momento a través de la aplicación. Los usuarios pueden eliminar su cuenta si lo desean.

              5. Consentimiento:
              Al utilizar la aplicación, el usuario consiente la recopilación y el uso de su correo electrónico conforme a estas políticas.

              6. Modificaciones:
              Nos reservamos el derecho de modificar estas políticas en cualquier momento. Cualquier cambio será notificado dentro de la aplicación.

              7. Legislación Aplicable:
              Estas políticas se rigen por la legislación vigente en Chile, y en particular por la Ley 19.496 sobre Protección de los Derechos de los Consumidores y la Ley 19.496 de Protección de Datos Personales.

              8. Contacto:
              Si tienes alguna pregunta sobre nuestras políticas de privacidad, puedes ponerte en contacto con nosotros a través de la aplicación.
              ''',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                Navigator.pushReplacementNamed(
                    context, '/home'); // Ir a la pantalla principal
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  // Función para verificar si el correo está verificado
  Future<void> _checkEmailVerification(User user) async {
    if (!user.emailVerified) {
      setState(() {
        _errorMessage = 'Por favor, verifica tu correo electrónico.';
        _isLoading = false;
      });
      _showEmailVerificationMessage();
    } else {
      // Si el correo está verificado, redirige al Home
      _showPrivacyPolicyDialog(
          context); // Mostrar políticas si el correo está verificado
    }
  }

  // Mostrar mensaje de verificación de correo
  void _showEmailVerificationMessage() {
    setState(() {
      _errorMessage =
          'Por favor, verifica tu correo electrónico antes de acceder.';
    });
  }

  // Función para enviar correo de verificación
  void _sendVerificationEmail() async {
    try {
      User? user = _authService.getCurrentUser();
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        setState(() {
          _errorMessage =
              'Correo de verificación reenviado. Revisa tu bandeja de entrada.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al reenviar el correo: ${e.toString()}';
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isLogin) {
          var user = await _authService.loginWithEmailPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

          // Verificar si el correo está verificado
          if (user != null) {
            await _checkEmailVerification(user);
          }
        } else {
          await _authService.registerWithEmailPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

          setState(() {
            _successMessage =
                'Registro exitoso! Un correo de verificación ha sido enviado a tu dirección.';
            _isLoading = false;
          });

          // Redirigir al login después de un registro exitoso
          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              _isLogin = true; // Cambiar a la vista de login
            });
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Iniciar Sesión' : 'Registrarse')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Correo Electrónico'),
                  validator: (value) => validateEmail(value),
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator: (value) => validatePassword(value),
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submit,
                        child:
                            Text(_isLogin ? 'Iniciar Sesión' : 'Registrarse'),
                      ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: _toggleForm,
                  child: Text(
                    _isLogin
                        ? '¿No tienes cuenta? Registrarse'
                        : '¿Ya tienes cuenta? Iniciar Sesión',
                  ),
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                if (_successMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      _successMessage,
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                if (_errorMessage ==
                    'Por favor, verifica tu correo electrónico.')
                  ElevatedButton(
                    onPressed: _sendVerificationEmail,
                    child: Text('Reenviar Correo de Verificación'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
