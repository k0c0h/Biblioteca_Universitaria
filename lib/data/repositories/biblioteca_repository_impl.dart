import '../../domain/entities/biblioteca.dart';
import '../../domain/repositories/biblioteca_repository.dart';
import '../datasources/biblioteca_api.dart';

class BibliotecaRepositoryImpl implements BibliotecaRepository {
  BibliotecaRepositoryImpl({required this.api});

  final BibliotecaApi api;

  @override
  Future<Biblioteca> obtener() => api.obtener();

  @override
  Future<Biblioteca> registrar(String nombre) => api.registrar(nombre);

  @override
  Future<Biblioteca> prestar(Prestamo prestamo) => api.prestar(prestamo);

  @override
  Future<Biblioteca> devolver(int id) => api.devolver(id);
}
