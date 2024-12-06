import 'package:bragivino/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'mis_vinos_screen.dart';
import 'catalogo_screen.dart';
import 'estadisticas_screen.dart';
import '../services/auth_service.dart';
import 'package:flutter/services.dart'; // Importar para cerrar la app

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    MyWinesScreen(),
    CatalogScreen(),
    StatisticsScreen(),
  ];

  final TextEditingController _deleteAccountController =
      TextEditingController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Función de confirmación antes de realizar una acción crítica
  Future<void> _showConfirmationDialog(String action) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // El usuario debe confirmar la acción
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: action == 'deleteAccount'
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        'Escribe "CONFIRMAR" para eliminar tu cuenta. Esta acción es irreversible.'),
                    SizedBox(height: 10),
                    TextField(
                      controller: _deleteAccountController,
                      decoration:
                          InputDecoration(labelText: 'Escribir CONFIRMAR'),
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                )
              : Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo sin hacer nada
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (action == 'signOut') {
                  await _authService.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                } else if (action == 'deleteAccount') {
                  // Verificar si el texto ingresado es "CONFIRMAR"
                  if (_deleteAccountController.text.toUpperCase() ==
                      'CONFIRMAR') {
                    // Cerrar el cuadro de diálogo
                    Navigator.of(context).pop();

                    // Mostrar un mensaje temporal mientras se procesa la eliminación
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Eliminando cuenta...')),
                      );
                    }

                    // Agregar un retraso antes de eliminar y redirigir
                    await Future.delayed(Duration(seconds: 4));

                    // Eliminar la cuenta
                    try {
                      await _authService.deleteAccount();

                      // Cerrar la aplicación después de eliminar la cuenta
                      SystemNavigator.pop(); // Esto cierra la app
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Hubo un problema al eliminar la cuenta: ${e.toString()}'),
                          ),
                        );
                      }
                    }
                  } else {
                    // Si no se escribe "CONFIRMAR", mostrar un mensaje de error
                    if (mounted) {
                      setState(() {
                        _deleteAccountController.text = '';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Escribe "CONFIRMAR" para eliminar la cuenta')));
                    }
                  }
                }
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  // Mostrar el cuadro de información de contacto
  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Información de Contacto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Correo de contacto: contacto@bragivino.com'),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: 'contacto@bragivino.com'));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Correo copiado al portapapeles')),
                    );
                  }
                  Navigator.of(context).pop();
                },
                child: Text('Copiar Correo'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // Mostrar el menú lateral con opciones
  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Cerrar Sesión'),
                onTap: () {
                  _showConfirmationDialog('signOut');
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Eliminar Cuenta'),
                onTap: () {
                  _showConfirmationDialog('deleteAccount');
                },
              ),
              ListTile(
                leading: Icon(Icons.contact_mail),
                title: Text('Contactarnos'),
                onTap: () {
                  _showContactDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bragivino'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: _showMenu,
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Mis Vinos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_bar),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estadísticas',
          ),
        ],
      ),
    );
  }
}
