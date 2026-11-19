import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/biblioteca.dart';
import '../viewmodels/biblioteca_viewmodel.dart';

class DetallePrestamoView extends StatefulWidget {
  const DetallePrestamoView({super.key});

  @override
  State<DetallePrestamoView> createState() => _DetallePrestamoViewState();
}

class _DetallePrestamoViewState extends State<DetallePrestamoView> {
  bool _guardando = false;

  Future<void> _devolver(int id) async {
    setState(() => _guardando = true);
    try {
      await context.read<BibliotecaViewModel>().devolverPrestamo(id);
    } on ErrorBiblioteca catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.mensaje)));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context)!.settings.arguments as int;
    final biblioteca = context.watch<BibliotecaViewModel>().biblioteca;
    final prestamo = biblioteca.prestamos.firstWhere(
      (prestamo) => prestamo.id == id,
    );
    final estudiante = biblioteca.estudiantes.firstWhere(
      (estudiante) => estudiante.id == prestamo.estudianteId,
    );
    final libro = biblioteca.libros.firstWhere(
      (libro) => libro.id == prestamo.libroId,
    );
    final fechas = MaterialLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del préstamo')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(libro.titulo),
                      subtitle: Text(estudiante.nombre),
                      trailing: Chip(label: Text(prestamo.estado)),
                    ),
                    ListTile(
                      title: const Text('Fecha de préstamo'),
                      subtitle: Text(
                        fechas.formatShortDate(prestamo.fechaPrestamo),
                      ),
                    ),
                    ListTile(
                      title: const Text('Fecha límite de devolución'),
                      subtitle: Text(
                        fechas.formatShortDate(prestamo.fechaDevolucion),
                      ),
                    ),
                  ],
                ),
              ),
              if (!prestamo.devuelto)
                FilledButton(
                  onPressed: _guardando ? null : () => _devolver(id),
                  child: Text(
                    _guardando ? 'Guardando…' : 'Registrar devolución',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
