import 'package:control_gastos_personales/home_screen.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class Producto {
  String nombre;
  String precio;
  String descripcion;

  Producto({required this.nombre, required this.precio, required this.descripcion});
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<Producto> productos = [];

  void _eliminarProducto(int index) {
    setState(() {
      productos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control de Gastos',
      theme: ThemeData(primarySwatch: Colors.grey),
      home: HomeScreen(
        productos: productos,
        onAgregar: (prod) {
          setState(() {
            productos.add(prod);
          });
        },
        onActualizar: (index, prod) {
          setState(() {
            productos[index] = prod;
          });
        },
        onEliminar: _eliminarProducto,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<Producto> productos;
  final void Function(Producto) onAgregar;
  final void Function(int, Producto) onActualizar;
  final void Function(int) onEliminar;

  const HomeScreen({
    super.key, 
    required this.productos,
    required this.onAgregar, 
    required this.onActualizar,
    required this.onEliminar,
    });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Agregar Productos', style: TextStyle(fontSize: 18, color: Colors.white)),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => AddProductScreen(
                onGuardar: (prod) {
                  onAgregar(prod);
                  Navigator.pop(context);
                },
              ),
            ));
          },
        ),
      ),
      floatingActionButton: productos.isEmpty
    ? null
    : FloatingActionButton(
        child: const Icon(Icons.list),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ProductListScreen(
              productos: productos,
              onActualizar: onActualizar, 
              onEliminar: onEliminar,     
            ),
          ));
        },
      ),
    );
  }
}

class AddProductScreen extends StatefulWidget {
  final void Function(Producto) onGuardar;
  const AddProductScreen({super.key, required this.onGuardar});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final nombreController = TextEditingController();
  final precioController = TextEditingController();
  final descripcionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Producto/Servicio'),
                validator: (value) => (value == null || value.isEmpty) ? 'Ingrese un nombre' : null,
              ),
              TextFormField(
                controller: precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un precio';
                  if (double.tryParse(value) == null) return 'Ingrese un número válido';
                  return null;
                },
              ),
              TextFormField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
                child: const Text('Agregar', style: TextStyle(fontSize: 18, color: Colors.white)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onGuardar(Producto(
                      nombre: nombreController.text,
                      precio: precioController.text,
                      descripcion: descripcionController.text,
                    ));
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ProductListScreen extends StatelessWidget {
  final List<Producto> productos;
  final void Function(int, Producto) onActualizar;
  final void Function(int) onEliminar;

  const ProductListScreen({
    super.key, 
    required this.productos, 
    required this.onActualizar,
    required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: ListView.builder(
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final prod = productos[index];
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black87,
                child: Text(prod.nombre, style: const TextStyle(color: Colors.white)),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Precio: ${prod.precio}'),
                    const SizedBox(height: 4),
                    Text('Descripción: ${prod.descripcion}'),
                  ],
                ),
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text('Actualizar', style: TextStyle(color: Colors.white)),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => UpdateProductScreen(
                      producto: prod,
                      onActualizar: (nuevoProd) {
                        onActualizar(index, nuevoProd);
                        Navigator.pop(context);
                      },
                    ),
                  ));
                },
              ),
              leading: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Confirmar eliminación'),
                      content: const Text('¿Quieres eliminar este producto?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            onEliminar(index);
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
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
    );
  }
}

class UpdateProductScreen extends StatefulWidget {
  final Producto producto;
  final void Function(Producto) onActualizar;

  const UpdateProductScreen({super.key, required this.producto, required this.onActualizar});

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  late TextEditingController nombreController;
  late TextEditingController precioController;
  late TextEditingController descripcionController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.producto.nombre);
    precioController = TextEditingController(text: widget.producto.precio);
    descripcionController = TextEditingController(text: widget.producto.descripcion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Actualizar Producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Producto/Servicio'),
                validator: (value) => (value == null || value.isEmpty) ? 'Ingrese un nombre' : null,
              ),
              TextFormField(
                controller: precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un precio';
                  if (double.tryParse(value) == null) return 'Ingrese un número válido';
                  return null;
                },
              ),
              TextFormField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
                child: const Text('Actualizar', style: TextStyle(fontSize: 18, color: Colors.white)),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onActualizar(Producto(
                      nombre: nombreController.text,
                      precio: precioController.text,
                      descripcion: descripcionController.text,
                    ));
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
