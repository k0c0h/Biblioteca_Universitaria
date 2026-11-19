import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/biblioteca.dart';
import '../models/biblioteca_model.dart';

class BibliotecaApi {
  BibliotecaApi({required this.url});

  final String url;

  Future<BibliotecaModel> obtener() =>
      _leer(http.get(Uri.parse('$url/biblioteca')));

  Future<BibliotecaModel> registrar(String nombre) =>
      _enviar('/estudiantes', {'nombre': nombre});

  Future<BibliotecaModel> prestar(Prestamo prestamo) =>
      _enviar('/prestamos', BibliotecaModel.prestamoAJson(prestamo));

  Future<BibliotecaModel> devolver(int id) =>
      _enviar('/prestamos/$id/devolucion', {});

  Future<BibliotecaModel> _enviar(String ruta, Map<String, dynamic> datos) {
    return _leer(
      http.post(
        Uri.parse('$url$ruta'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(datos),
      ),
    );
  }

  Future<BibliotecaModel> _leer(Future<http.Response> solicitud) async {
    final respuesta = await solicitud.timeout(const Duration(seconds: 8));
    final datos =
        json.decode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;
    if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
      return BibliotecaModel.fromJson(datos);
    }
    throw ErrorBiblioteca(
      datos['error'] as String? ?? 'No se pudo completar la operación.',
    );
  }
}
