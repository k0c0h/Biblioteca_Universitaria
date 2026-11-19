import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';
import '../viewmodels/biblioteca_viewmodel.dart';

class BibliotecaView extends StatefulWidget {
  const BibliotecaView({super.key, required this.seccion});

  final Seccion seccion;

  @override
  State<BibliotecaView> createState() => _BibliotecaViewState();
}

class _BibliotecaViewState extends State<BibliotecaView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<BibliotecaViewModel>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BibliotecaViewModel>();
    final biblioteca = vm.biblioteca;
    final seccion = widget.seccion;
    final titulo = switch (seccion) {
      Seccion.estudiantes => 'Estudiantes',
      Seccion.libros => 'Libros disponibles',
      Seccion.prestamos => 'Préstamos',
    };

    final filas = switch (seccion) {
      Seccion.estudiantes => [
        for (final estudiante in biblioteca.estudiantes)
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(estudiante.nombre),
            subtitle: Text('Registro #${estudiante.id}'),
          ),
      ],
      Seccion.libros => [
        for (final libro in biblioteca.disponibles)
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: Text(libro.titulo),
            subtitle: Text(libro.autor),
            trailing: Text('Stock: ${libro.stock}'),
          ),
      ],
      Seccion.prestamos => [
        for (final prestamo in biblioteca.prestamos.reversed)
          ListTile(
            leading: const Icon(Icons.assignment_outlined),
            title: Text(
              biblioteca.libros
                  .firstWhere((libro) => libro.id == prestamo.libroId)
                  .titulo,
            ),
            subtitle: Text(
              biblioteca.estudiantes
                  .firstWhere(
                    (estudiante) => estudiante.id == prestamo.estudianteId,
                  )
                  .nombre,
            ),
            trailing: Text(prestamo.estado),
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.detalle,
              arguments: prestamo.id,
            ),
          ),
      ],
    };

    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      floatingActionButton:
          seccion == Seccion.libros || vm.cargando || vm.error.isNotEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(
                context,
                AppRoutes.formulario,
                arguments: seccion,
              ),
              icon: const Icon(Icons.add),
              label: Text(
                seccion == Seccion.estudiantes
                    ? 'Registrar estudiante'
                    : 'Nuevo préstamo',
              ),
            ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: vm.cargando
              ? const CircularProgressIndicator()
              : vm.error.isNotEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(vm.error, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: vm.cargar,
                      child: const Text('Reintentar'),
                    ),
                  ],
                )
              : RefreshIndicator(
                  onRefresh: vm.cargar,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    children: [
                      if (filas.isEmpty)
                        Center(
                          child: Text(switch (seccion) {
                            Seccion.estudiantes =>
                              'Todavía no hay estudiantes registrados.',
                            Seccion.libros => 'No hay libros disponibles.',
                            Seccion.prestamos =>
                              'Todavía no hay préstamos registrados.',
                          }),
                        ),
                      for (final fila in filas) Card(child: fila),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
