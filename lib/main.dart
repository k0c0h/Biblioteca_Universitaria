import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/datasources/biblioteca_api.dart';
import 'data/repositories/biblioteca_repository_impl.dart';
import 'domain/usecases/devolver_prestamo.dart';
import 'domain/usecases/obtener_biblioteca.dart';
import 'domain/usecases/registrar_estudiante.dart';
import 'domain/usecases/registrar_prestamo.dart';
import 'presentation/viewmodels/biblioteca_viewmodel.dart';
import 'presentation/views/biblioteca_view.dart';
import 'presentation/views/detalle_prestamo_view.dart';
import 'presentation/views/formulario_biblioteca_view.dart';
import 'presentation/views/inicio_view.dart';
import 'routes/app_routes.dart';

void main() {
  const configurada = String.fromEnvironment('BIBLIOTECA_API_URL');
  final android = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  final url = configurada.isNotEmpty
      ? configurada
      : 'http://${android ? '10.0.2.2' : '127.0.0.1'}:8080';
  final repository = BibliotecaRepositoryImpl(api: BibliotecaApi(url: url));

  runApp(
    ChangeNotifierProvider(
      create: (_) => BibliotecaViewModel(
        ObtenerBiblioteca(repository: repository),
        RegistrarEstudiante(repository: repository),
        RegistrarPrestamo(repository: repository),
        DevolverPrestamo(repository: repository),
      ),
      child: const MiApp(),
    ),
  );
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblioteca universitaria',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF28594E)),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        cardTheme: const CardThemeData(margin: EdgeInsets.only(bottom: 12)),
      ),
      initialRoute: AppRoutes.inicio,
      routes: {
        AppRoutes.inicio: (_) => const InicioView(),
        AppRoutes.estudiantes: (_) =>
            const BibliotecaView(seccion: Seccion.estudiantes),
        AppRoutes.libros: (_) => const BibliotecaView(seccion: Seccion.libros),
        AppRoutes.prestamos: (_) =>
            const BibliotecaView(seccion: Seccion.prestamos),
        AppRoutes.formulario: (_) => const FormularioBibliotecaView(),
        AppRoutes.detalle: (_) => const DetallePrestamoView(),
      },
    );
  }
}
