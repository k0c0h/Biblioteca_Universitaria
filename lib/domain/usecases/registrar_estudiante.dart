import '../entities/biblioteca.dart';
import '../repositories/biblioteca_repository.dart';

class RegistrarEstudiante {
  const RegistrarEstudiante({required this.repository});

  final BibliotecaRepository repository;

  Future<Biblioteca> ejecutar(String nombre) => repository.registrar(nombre);
}
