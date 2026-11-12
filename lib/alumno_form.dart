import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlumnoForm extends StatefulWidget {
  const AlumnoForm({super.key});

  @override
  _AlumnoFormState createState() => _AlumnoFormState();
}

class _AlumnoFormState extends State<AlumnoForm> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _carreraController = TextEditingController();

  Future<void> _enviarDatos() async {
    
    var url = Uri.parse('http://192.168.100.15:8000/alumnos/');

    if (_nombreController.text.isEmpty ||
        _edadController.text.isEmpty ||
        _carreraController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos')),
      );
      return;
    }

    try {
     
      int? edad = int.tryParse(_edadController.text);
      if (edad == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La edad debe ser un número entero')),
        );
        return;
      }

      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          'nombre': _nombreController.text,
          'edad': edad,
          'carrera': _carreraController.text,
        }),
      );

      print('Código de estado HTTP: ${response.statusCode}');
      print('Respuesta del servidor: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alumno registrado exitosamente')),
        );
        Navigator.pop(context); // Regresa a la lista
      } else {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error (${response.statusCode}): ${response.body}')),
        );
      }
    } catch (e) {
      print('Error de conexión: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulario de Alumno'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _edadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Edad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _carreraController,
              decoration: const InputDecoration(
                labelText: 'Carrera',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _enviarDatos,
              child: const Text('Guardar Datos (POST)'),
            ),
          ],
        ),
      ),
    );
  }
}