import '../entities/biblioteca.dart';

abstract class BibliotecaRepository {
  Future<Biblioteca> obtener();
  Future<Biblioteca> registrar(String nombre);
  Future<Biblioteca> prestar(Prestamo prestamo);
  Future<Biblioteca> devolver(int id);
}
