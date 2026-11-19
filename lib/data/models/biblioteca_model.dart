import '../../domain/entities/biblioteca.dart';

class BibliotecaModel extends Biblioteca {
  const BibliotecaModel({
    required super.estudiantes,
    required super.libros,
    required super.prestamos,
  });

  factory BibliotecaModel.fromJson(Map<String, dynamic> json) {
    return BibliotecaModel(
      estudiantes: (json['estudiantes'] as List)
          .cast<Map<String, dynamic>>()
          .map(
            (datos) => Estudiante(
              id: datos['id'] as int,
              nombre: datos['nombre'] as String,
            ),
          )
          .toList(),
      libros: (json['libros'] as List)
          .cast<Map<String, dynamic>>()
          .map(
            (datos) => Libro(
              id: datos['id'] as int,
              titulo: datos['titulo'] as String,
              autor: datos['autor'] as String,
              stock: datos['stock'] as int,
            ),
          )
          .toList(),
      prestamos: (json['prestamos'] as List)
          .cast<Map<String, dynamic>>()
          .map(prestamoDesdeJson)
          .toList(),
    );
  }

  static Prestamo prestamoDesdeJson(Map<String, dynamic> json) {
    return Prestamo(
      id: json['id'] as int? ?? 0,
      estudianteId: json['estudianteId'] as int,
      libroId: json['libroId'] as int,
      fechaPrestamo: dia(DateTime.parse(json['fechaPrestamo'] as String)),
      fechaDevolucion: dia(DateTime.parse(json['fechaDevolucion'] as String)),
      devuelto: json['devuelto'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> prestamoAJson(Prestamo prestamo) => {
    'id': prestamo.id,
    'estudianteId': prestamo.estudianteId,
    'libroId': prestamo.libroId,
    'fechaPrestamo': prestamo.fechaPrestamo.toIso8601String(),
    'fechaDevolucion': prestamo.fechaDevolucion.toIso8601String(),
    'devuelto': prestamo.devuelto,
  };

  static Map<String, dynamic> aJson(Biblioteca biblioteca) => {
    'estudiantes': biblioteca.estudiantes
        .map((estudiante) => {'id': estudiante.id, 'nombre': estudiante.nombre})
        .toList(),
    'libros': biblioteca.libros
        .map(
          (libro) => {
            'id': libro.id,
            'titulo': libro.titulo,
            'autor': libro.autor,
            'stock': libro.stock,
          },
        )
        .toList(),
    'prestamos': biblioteca.prestamos.map(prestamoAJson).toList(),
  };
}
