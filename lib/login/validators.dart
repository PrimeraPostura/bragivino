String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Por favor ingresa un correo electrónico';
  }
  String pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}\b';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(value)) {
    return 'Por favor ingresa un correo electrónico válido';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Por favor ingresa una contraseña';
  }
  if (value.length < 6) {
    return 'La contraseña debe tener al menos 6 caracteres';
  }
  return null;
}
