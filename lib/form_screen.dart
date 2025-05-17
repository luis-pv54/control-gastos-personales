import 'package:flutter/material.dart';

class FormScreen extends StatefulWidget {
  final int? id;
  final Map<String, dynamic>? existingData;
  final Function(Map<String, dynamic>) onSubmit;

  const FormScreen({
    super.key,
    this.id,
    this.existingData,
    required this.onSubmit,
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _categoriaController.text = widget.existingData!['categoria'];
      _descripcionController.text = widget.existingData!['descripcion'];
      _montoController.text = widget.existingData!['monto'].toString();
      _dateController.text = widget.existingData!['fecha'];
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toString().split(" ")[0];
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit({
        'id': widget.id,
        'categoria': _categoriaController.text,
        'descripcion': _descripcionController.text,
        'monto': double.parse(_montoController.text),
        'fecha': _dateController.text,
      });
      Navigator.of(context).pop();
    }
  }

  InputDecoration _underlineDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      // filled: true,
      // fillColor: Colors.white,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: const UnderlineInputBorder(),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.id != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Gasto' : 'Agregar Gasto')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _categoriaController,
                decoration: _underlineDecoration('Categoría'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'La categoría es obligatoria'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montoController,
                decoration: _underlineDecoration('Monto'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'El monto es obligatorio';
                  if (double.tryParse(value) == null) return 'Monto inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: _underlineDecoration(
                  'Fecha',
                  icon: Icons.calendar_today,
                ),
                readOnly: true,
                onTap: _selectDate,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'La fecha es obligatoria'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: _underlineDecoration('Descripción'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'La descripción es obligatoria'
                            : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(isEditing ? "Actualizar" : "Agregar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
