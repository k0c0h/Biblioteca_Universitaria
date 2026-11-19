import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';

class InicioView extends StatelessWidget {
  const InicioView({super.key});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colores.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.local_library_outlined,
                        size: 34,
                        color: colores.onPrimaryContainer,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Biblioteca universitaria',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: colores.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                for (final (titulo, icono, ruta) in const [
                  ('Estudiantes', Icons.people_outline, AppRoutes.estudiantes),
                  (
                    'Libros disponibles',
                    Icons.menu_book_outlined,
                    AppRoutes.libros,
                  ),
                  ('Préstamos', Icons.assignment_outlined, AppRoutes.prestamos),
                ])
                  Card(
                    child: ListTile(
                      leading: Icon(icono),
                      title: Text(titulo),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, ruta),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
