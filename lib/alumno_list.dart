import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'alumno_form.dart';
import 'main.dart';

class AlumnoList extends StatefulWidget {
  const AlumnoList({super.key});

  @override
  _AlumnoListState createState() => _AlumnoListState();
}

class _AlumnoListState extends State<AlumnoList> {
  List _alumnos = [];
  bool _cargando = true;

  Future<void> _obtenerAlumnos() async {
    setState(() {
      _cargando = true;
    });

    var url = Uri.parse('http:// 192.168.100.15:8000/alumnos/');

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _alumnos = json.decode(response.body);
          _cargando = false;
        });
      } else {
        setState(() {
          _cargando = false;
        });
        print('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _cargando = false;
      });
      print('Error al obtener alumnos: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _obtenerAlumnos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Alumnos (GET)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _obtenerAlumnos,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
              );
            },
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _alumnos.isEmpty
              ? const Center(child: Text('No hay alumnos registrados'))
              : ListView.builder(
                  itemCount: _alumnos.length,
                  itemBuilder: (context, index) {
                    final alumno = _alumnos[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text('${alumno['id'] ?? ''}'),
                      ),
                      title: Text(alumno['nombre'] ?? 'Sin nombre'),
                      subtitle: Text('Carrera: ${alumno['carrera']} - Edad: ${alumno['edad']}'),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AlumnoForm()),
          );
          _obtenerAlumnos(); // Recargar la lista al volver del formulario
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}