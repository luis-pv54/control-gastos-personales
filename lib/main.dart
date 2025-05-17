import 'package:control_gastos_personales/db_helper.dart';
import 'package:control_gastos_personales/form_screen.dart';
import 'package:control_gastos_personales/home_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Control de Gastos',
      theme: ThemeData(primarySwatch: Colors.grey),
      home: const HomeButtonScreen(),
    );
  }
}

class HomeButtonScreen extends StatelessWidget {
  const HomeButtonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor gastos personales'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Agregar Productos',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (_) => FormScreen(
                      onSubmit: (gasto) async {
                        // print("Nuevo gasto agregado: $gasto");
                        await SQLHelper.createData(
                          gasto['categoria'],
                          gasto['descripcion'],
                          gasto['monto'],
                          gasto['fecha'],
                        );
                      },
                    ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.format_list_bulleted),
        onPressed: () {
          // Aquí rediriges a home_screen.dart o a la pantalla que desees
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const HomeScreen()));
        },
      ),
    );
  }
}
