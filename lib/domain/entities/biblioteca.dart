class Estudiante {
  const Estudiante({required this.id, required this.nombre});

  final int id;
  final String nombre;
}

class Libro {
  const Libro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.stock,
  });

  final int id;
  final String titulo;
  final String autor;
  final int stock;
}

DateTime dia(DateTime fecha) =>
    DateTime.utc(fecha.year, fecha.month, fecha.day);

class Prestamo {
  const Prestamo({
    required this.id,
    required this.estudianteId,
    required this.libroId,
    required this.fechaPrestamo,
    required this.fechaDevolucion,
    required this.devuelto,
  });

  final int id;
  final int estudianteId;
  final int libroId;
  final DateTime fechaPrestamo;
  final DateTime fechaDevolucion;
  final bool devuelto;

  bool vencidoEn(DateTime fecha) =>
      !devuelto && dia(fecha).isAfter(fechaDevolucion);

  String get estado {
    if (devuelto) return 'Devuelto';
    if (vencidoEn(DateTime.now())) return 'Vencido';
    return 'Activo';
  }
}

class Biblioteca {
  const Biblioteca({
    this.estudiantes = const [],
    this.libros = const [],
    this.prestamos = const [],
  });

  final List<Estudiante> estudiantes;
  final List<Libro> libros;
  final List<Prestamo> prestamos;

  Iterable<Libro> get disponibles => libros.where((libro) => libro.stock > 0);

  Biblioteca registrar(String nombre) {
    final limpio = nombre.trim();
    if (limpio.isEmpty) {
      throw const ErrorBiblioteca('Escribe el nombre del estudiante.');
    }
    return Biblioteca(
      estudiantes: [
        ...estudiantes,
        Estudiante(id: estudiantes.length + 1, nombre: limpio),
      ],
      libros: libros,
      prestamos: prestamos,
    );
  }

  Biblioteca prestar(Prestamo solicitud, DateTime hoy) {
    if (!estudiantes.any(
      (estudiante) => estudiante.id == solicitud.estudianteId,
    )) {
      throw const ErrorBiblioteca('Selecciona un estudiante registrado.');
    }

    final indice = libros.indexWhere((libro) => libro.id == solicitud.libroId);
    if (indice == -1 || libros[indice].stock <= 0) {
      throw const ErrorBiblioteca('El libro no tiene stock disponible.');
    }

    final inicio = dia(solicitud.fechaPrestamo);
    final fin = dia(solicitud.fechaDevolucion);
    if (!fin.isAfter(inicio)) {
      throw const ErrorBiblioteca(
        'La devolución debe ser posterior al préstamo.',
      );
    }
    if (fin.difference(inicio).inDays > 7) {
      throw const ErrorBiblioteca('La duración máxima es de 7 días.');
    }

    final activos = prestamos.where(
      (prestamo) =>
          prestamo.estudianteId == solicitud.estudianteId && !prestamo.devuelto,
    );
    if (activos.any((prestamo) => prestamo.vencidoEn(hoy))) {
      throw const ErrorBiblioteca('El estudiante tiene un préstamo vencido.');
    }
    if (activos.length >= 3) {
      throw const ErrorBiblioteca(
        'El estudiante ya tiene 3 préstamos activos.',
      );
    }

    final nuevo = Prestamo(
      id: prestamos.length + 1,
      estudianteId: solicitud.estudianteId,
      libroId: solicitud.libroId,
      fechaPrestamo: inicio,
      fechaDevolucion: fin,
      devuelto: false,
    );
    return Biblioteca(
      estudiantes: estudiantes,
      libros: _ajustarStock(solicitud.libroId, -1),
      prestamos: [...prestamos, nuevo],
    );
  }

  Biblioteca devolver(int id) {
    final indice = prestamos.indexWhere((prestamo) => prestamo.id == id);
    if (indice == -1) {
      throw const ErrorBiblioteca('No se encontró el préstamo.');
    }

    final prestamo = prestamos[indice];
    if (prestamo.devuelto) {
      throw const ErrorBiblioteca('El préstamo ya fue devuelto.');
    }

    final actualizados = [...prestamos];
    actualizados[indice] = Prestamo(
      id: prestamo.id,
      estudianteId: prestamo.estudianteId,
      libroId: prestamo.libroId,
      fechaPrestamo: prestamo.fechaPrestamo,
      fechaDevolucion: prestamo.fechaDevolucion,
      devuelto: true,
    );
    return Biblioteca(
      estudiantes: estudiantes,
      libros: _ajustarStock(prestamo.libroId, 1),
      prestamos: actualizados,
    );
  }

  List<Libro> _ajustarStock(int id, int cambio) {
    return libros.map((libro) {
      if (libro.id != id) return libro;
      return Libro(
        id: libro.id,
        titulo: libro.titulo,
        autor: libro.autor,
        stock: libro.stock + cambio,
      );
    }).toList();
  }
}

class ErrorBiblioteca implements Exception {
  const ErrorBiblioteca(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}
