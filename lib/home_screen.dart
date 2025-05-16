import 'package:control_gastos_personales/db_helper.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allData = [];

  bool _isLoading = true;

  double calcularTotal() {
    return _allData.fold(0.0, (sum, item) => sum + (item['monto'] as double));
  }

  // Get All Data From Database
  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // Add Data
  Future<void> _addData() async {
    await SQLHelper.createData(
      _categoriaController.text,
      _descripcionController.text,
      double.parse(_montoController.text),
      _dateController.text,
    );
    _refreshData();
  }

  // Update Data
  Future<void> _updateData(int id) async {
    await SQLHelper.updateData(
      id,
      _categoriaController.text,
      _descripcionController.text,
      double.parse(_montoController.text),
      _dateController.text,
    );
    _refreshData();
  }

  // Delete Data
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

  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (_picked != null) {
      setState(() {
        _dateController.text = _picked.toString().split(" ")[0];
      });
    }
  }

  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  void showBottomSheet(int? id) async {
    // if ID is not null then it will update other wise it will new data
    // when edit icon is pressed then id will be given to bottomsheet function and
    // it will edit
    if (id != null) {
      final existingData = _allData.firstWhere(
        (element) => element['id'] == id,
      );
      _categoriaController.text = existingData['categoria'];
      _descripcionController.text = existingData['descripcion'];
      _montoController.text = existingData['monto'].toString();
      _dateController.text = existingData['fecha'];
    }

    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder:
          (_) => Container(
            padding: EdgeInsets.only(
              top: 30,
              left: 15,
              right: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom + 50,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _categoriaController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Categoría",
                  ),
                ),

                SizedBox(height: 10),

                TextField(
                  controller: _montoController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Monto",
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),

                TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'DATE',
                    filled: true,
                    prefixIcon: Icon(Icons.calendar_today),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  readOnly: true,
                  onTap: () {
                    _selectDate();
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _descripcionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Description",
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (id == null) {
                        await _addData();
                      }
                      if (id != null) {
                        await _updateData(id);
                      }

                      _categoriaController.text = "";
                      _descripcionController.text = "";
                      _montoController.text = "";
                      _dateController.text = "";

                      // Hide Bottom Sheet
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        id == null ? "Add Data" : "Update",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECEAF4),
      appBar: AppBar(title: Text('Gestor gastos personales')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Card del total gastado
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.all(15),
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
                  // Lista de datos
                  Expanded(
                    child: ListView.builder(
                      itemCount: _allData.length,
                      itemBuilder:
                          (context, index) => Card(
                            margin: EdgeInsets.all(15),
                            child: ListTile(
                              title: Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  _allData[index]['categoria'],
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_allData[index]['descripcion'] ?? ''),
                                  SizedBox(height: 4),
                                  Text(
                                    'Monto: \$${_allData[index]['monto'].toString()}',
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    // 'Fecha: ${DateTime.parse(_allData[index]['createdAt']).toLocal().toString().split(' ')[0]}',
                                    'Fecha: \$${_allData[index]['fecha'].toString()}',
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      showBottomSheet(_allData[index]['id']);
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _deleteData(_allData[index]['id']);
                                    },
                                    icon: Icon(Icons.delete, color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ),
                  ),
                ],
              ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(null),
        child: Icon(Icons.add),
      ),
    );
  }
}
