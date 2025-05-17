import 'package:flutter/material.dart';
import 'package:control_gastos_personales/db_helper.dart';
import 'package:control_gastos_personales/form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  void _deleteData(int id) async {
    await SQLHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text('Gasto eliminado'),
      ),
    );
    _refreshData();
  }

  double calcularTotal() {
    return _allData.fold(0.0, (sum, item) => sum + (item['monto'] as double));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Gastos', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Card del total gastado
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.all(15),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Total Gastado: \$${calcularTotal().toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Lista de gastos
                  Expanded(
                    child: ListView.builder(
                      itemCount: _allData.length,
                      itemBuilder: (context, index) {
                        final gasto = _allData[index];
                        return Card(
                          margin: const EdgeInsets.all(12),
                          child: ListTile(
                            title: Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.black87,
                              child: Text(
                                gasto['categoria'],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(gasto['descripcion'] ?? ''),
                                  const SizedBox(height: 4),
                                  Text("Monto: \$${gasto['monto'].toString()}"),
                                  const SizedBox(height: 2),
                                  Text("Fecha: ${gasto['fecha'].toString()}"),
                                ],
                              ),
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              child: const Text(
                                'Editar',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => FormScreen(
                                          id: gasto['id'],
                                          existingData: gasto,
                                          onSubmit: (updatedData) async {
                                            await SQLHelper.updateData(
                                              updatedData['id'],
                                              updatedData['categoria'],
                                              updatedData['descripcion'],
                                              updatedData['monto'],
                                              updatedData['fecha'],
                                            );
                                            _refreshData();
                                          },
                                        ),
                                  ),
                                );
                              },
                            ),
                            leading: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder:
                                      (ctx) => AlertDialog(
                                        title: const Text('¿Eliminar gasto?'),
                                        content: const Text(
                                          '¿Estás seguro de que quieres eliminar este gasto?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(ctx).pop(),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(ctx).pop();
                                              _deleteData(gasto['id']);
                                            },
                                            child: const Text(
                                              'Eliminar',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      // 🔴 Botón flotante eliminado completamente
    );
  }
}
