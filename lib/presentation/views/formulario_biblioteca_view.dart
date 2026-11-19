import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/biblioteca.dart';
import '../../routes/app_routes.dart';
import '../viewmodels/biblioteca_viewmodel.dart';

class FormularioBibliotecaView extends StatefulWidget {
  const FormularioBibliotecaView({super.key});

  @override
  State<FormularioBibliotecaView> createState() =>
      _FormularioBibliotecaViewState();
}

class _FormularioBibliotecaViewState extends State<FormularioBibliotecaView> {
  final _formulario = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  int? _estudiante;
  int? _libro;
  DateTime _inicio = DateUtils.dateOnly(DateTime.now());
  DateTime _fin = DateUtils.addDaysToDate(DateTime.now(), 7);
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha({required bool inicio}) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: inicio ? _inicio : _fin,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (!mounted || fecha == null) return;

    setState(() {
      if (inicio) {
        _inicio = fecha;
      } else {
        _fin = fecha;
      }
    });
  }

  Future<void> _guardar(bool estudiante) async {
    if (_guardando || !_formulario.currentState!.validate()) return;
    final vm = context.read<BibliotecaViewModel>();
    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      if (estudiante) {
        await vm.agregarEstudiante(_nombre.text);
      } else {
        await vm.agregarPrestamo(
          Prestamo(
            id: 0,
            estudianteId: _estudiante!,
            libroId: _libro!,
            fechaPrestamo: dia(_inicio),
            fechaDevolucion: dia(_fin),
            devuelto: false,
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    } on ErrorBiblioteca catch (error) {
      if (mounted) setState(() => _error = error.mensaje);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final estudiante =
        ModalRoute.of(context)!.settings.arguments == Seccion.estudiantes;
    final biblioteca = context.watch<BibliotecaViewModel>().biblioteca;
    final disponibles = biblioteca.disponibles.toList();
    final puedeGuardar =
        estudiante ||
        (biblioteca.estudiantes.isNotEmpty && disponibles.isNotEmpty);
    final fechas = MaterialLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(estudiante ? 'Registrar estudiante' : 'Nuevo préstamo'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Form(
            key: _formulario,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (estudiante)
                  TextFormField(
                    controller: _nombre,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (valor) => valor == null || valor.trim().isEmpty
                        ? 'Escribe el nombre del estudiante.'
                        : null,
                  )
                else if (!puedeGuardar)
                  Text(
                    biblioteca.estudiantes.isEmpty
                        ? 'Registra un estudiante para crear un préstamo.'
                        : 'No hay libros disponibles para préstamo.',
                  )
                else ...[
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Estudiante'),
                    items: [
                      for (final alumno in biblioteca.estudiantes)
                        DropdownMenuItem(
                          value: alumno.id,
                          child: Text(
                            alumno.nombre,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: _guardando ? null : (id) => _estudiante = id,
                    validator: (id) =>
                        id == null ? 'Selecciona un estudiante.' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Libro'),
                    items: [
                      for (final libro in disponibles)
                        DropdownMenuItem(
                          value: libro.id,
                          child: Text(
                            libro.titulo,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: _guardando ? null : (id) => _libro = id,
                    validator: (id) =>
                        id == null ? 'Selecciona un libro.' : null,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: const Text('Fecha de préstamo'),
                      subtitle: Text(fechas.formatShortDate(_inicio)),
                      onTap: _guardando
                          ? null
                          : () => _seleccionarFecha(inicio: true),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.event_available_outlined),
                      title: const Text('Fecha límite de devolución'),
                      subtitle: Text(fechas.formatShortDate(_fin)),
                      onTap: _guardando
                          ? null
                          : () => _seleccionarFecha(inicio: false),
                    ),
                  ),
                ],
                if (_error case final error?) ...[
                  const SizedBox(height: 12),
                  Text(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                if (puedeGuardar) ...[
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _guardando ? null : () => _guardar(estudiante),
                    child: Text(_guardando ? 'Guardando…' : 'Guardar'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
