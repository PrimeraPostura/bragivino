import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'validators.dart';

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

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = '';
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isLogin) {
          await _authService.loginWithEmailPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
          // Navigate to home screen (example)
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          await _authService.registerWithEmailPassword(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
          // Navigate to home screen (example)
          Navigator.pushReplacementNamed(context, '/home');
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
                  child: Text(_isLogin
                      ? '¿No tienes cuenta? Registrarse'
                      : '¿Ya tienes cuenta? Iniciar Sesión'),
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
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
