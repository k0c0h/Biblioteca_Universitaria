import 'package:flutter/foundation.dart';

import '../../domain/entities/biblioteca.dart';
import '../../domain/usecases/devolver_prestamo.dart';
import '../../domain/usecases/obtener_biblioteca.dart';
import '../../domain/usecases/registrar_estudiante.dart';
import '../../domain/usecases/registrar_prestamo.dart';

class BibliotecaViewModel extends ChangeNotifier {
  BibliotecaViewModel(
    this.obtener,
    this.registrar,
    this.prestar,
    this.devolver,
  );

  final ObtenerBiblioteca obtener;
  final RegistrarEstudiante registrar;
  final RegistrarPrestamo prestar;
  final DevolverPrestamo devolver;

  Biblioteca biblioteca = const Biblioteca();
  bool cargando = false;
  String error = '';

  Future<void> cargar() async {
    if (cargando) return;
    cargando = true;
    error = '';
    notifyListeners();

    try {
      biblioteca = await obtener.ejecutar();
    } catch (_) {
      error = 'No se pudo conectar con la API de la biblioteca.';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> agregarEstudiante(String nombre) =>
      _guardar(registrar.ejecutar(nombre));

  Future<void> agregarPrestamo(Prestamo prestamo) =>
      _guardar(prestar.ejecutar(prestamo));

  Future<void> devolverPrestamo(int id) => _guardar(devolver.ejecutar(id));

  Future<void> _guardar(Future<Biblioteca> operacion) async {
    try {
      biblioteca = await operacion;
      notifyListeners();
    } on ErrorBiblioteca {
      rethrow;
    } catch (_) {
      throw const ErrorBiblioteca(
        'No se pudo conectar con la API de la biblioteca.',
      );
    }
  }
}
