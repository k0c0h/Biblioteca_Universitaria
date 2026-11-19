import '../entities/biblioteca.dart';
import '../repositories/biblioteca_repository.dart';

class ObtenerBiblioteca {
  const ObtenerBiblioteca({required this.repository});

  final BibliotecaRepository repository;

  Future<Biblioteca> ejecutar() => repository.obtener();
}
