import '../entities/biblioteca.dart';
import '../repositories/biblioteca_repository.dart';

class RegistrarPrestamo {
  const RegistrarPrestamo({required this.repository});

  final BibliotecaRepository repository;

  Future<Biblioteca> ejecutar(Prestamo prestamo) =>
      repository.prestar(prestamo);
}
