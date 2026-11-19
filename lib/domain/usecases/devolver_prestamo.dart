import '../entities/biblioteca.dart';
import '../repositories/biblioteca_repository.dart';

class DevolverPrestamo {
  const DevolverPrestamo({required this.repository});

  final BibliotecaRepository repository;

  Future<Biblioteca> ejecutar(int id) => repository.devolver(id);
}
