import 'dart:convert';
import 'dart:io';

import 'lib/data/models/biblioteca_model.dart';
import 'lib/domain/entities/biblioteca.dart';

Future<void> main(List<String> args) async {
  final archivo = File('.biblioteca.json');
  var biblioteca = archivo.existsSync()
      ? BibliotecaModel.fromJson(
          jsonDecode(archivo.readAsStringSync()) as Map<String, dynamic>,
        )
      : const Biblioteca(
          libros: [
            Libro(
              id: 1,
              titulo: 'Don Quijote de la Mancha',
              autor: 'Miguel de Cervantes',
              stock: 4,
            ),
            Libro(
              id: 2,
              titulo: 'Cien años de soledad',
              autor: 'Gabriel García Márquez',
              stock: 3,
            ),
            Libro(
              id: 3,
              titulo: 'Ficciones',
              autor: 'Jorge Luis Borges',
              stock: 2,
            ),
          ],
        );

  final puerto = args.isNotEmpty
      ? int.parse(args.first)
      : int.tryParse(Platform.environment['PORT'] ?? '') ?? 8080;
  final servidor = await HttpServer.bind(InternetAddress.anyIPv4, puerto);
  stdout.writeln(
    'API de biblioteca disponible en http://0.0.0.0:${servidor.port}',
  );

  servidor.listen((solicitud) async {
    final respuesta = solicitud.response;
    respuesta.headers.contentType = ContentType.json;
    respuesta.headers.set('Access-Control-Allow-Origin', '*');
    respuesta.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    respuesta.headers.set('Access-Control-Allow-Headers', 'Content-Type');

    try {
      if (solicitud.method == 'OPTIONS') {
        respuesta.statusCode = HttpStatus.noContent;
        return;
      }

      final ruta = solicitud.uri.pathSegments;
      if (solicitud.method == 'GET' && solicitud.uri.path == '/biblioteca') {
        respuesta.write(jsonEncode(BibliotecaModel.aJson(biblioteca)));
        return;
      }
      if (solicitud.method != 'POST') {
        respuesta.statusCode = HttpStatus.notFound;
        respuesta.write(jsonEncode({'error': 'Ruta no encontrada.'}));
        return;
      }

      final datos = jsonDecode(
        await utf8.decoder.bind(solicitud).join(),
      ) as Map<String, dynamic>;
      final Biblioteca actualizada;
      if (solicitud.uri.path == '/estudiantes') {
        actualizada = biblioteca.registrar(datos['nombre'] as String);
        respuesta.statusCode = HttpStatus.created;
      } else if (solicitud.uri.path == '/prestamos') {
        actualizada = biblioteca.prestar(
          BibliotecaModel.prestamoDesdeJson(datos),
          DateTime.now(),
        );
        respuesta.statusCode = HttpStatus.created;
      } else if (ruta case ['prestamos', final id, 'devolucion']) {
        actualizada = biblioteca.devolver(int.parse(id));
      } else {
        respuesta.statusCode = HttpStatus.notFound;
        respuesta.write(jsonEncode({'error': 'Ruta no encontrada.'}));
        return;
      }

      final temporal = File('${archivo.path}.tmp');
      temporal.writeAsStringSync(
        jsonEncode(BibliotecaModel.aJson(actualizada)),
        flush: true,
      );
      temporal.renameSync(archivo.path);
      biblioteca = actualizada;
      respuesta.write(jsonEncode(BibliotecaModel.aJson(biblioteca)));
    } on ErrorBiblioteca catch (error) {
      respuesta.statusCode = HttpStatus.conflict;
      respuesta.write(jsonEncode({'error': error.mensaje}));
    } on FormatException {
      respuesta.statusCode = HttpStatus.badRequest;
      respuesta.write(jsonEncode({'error': 'Revisa los datos enviados.'}));
    } on TypeError {
      respuesta.statusCode = HttpStatus.badRequest;
      respuesta.write(jsonEncode({'error': 'Revisa los datos enviados.'}));
    } catch (error) {
      stderr.writeln(error);
      respuesta.statusCode = HttpStatus.internalServerError;
      respuesta.write(
        jsonEncode({'error': 'No se pudo guardar la operación.'}),
      );
    } finally {
      await respuesta.close();
    }
  });
}
