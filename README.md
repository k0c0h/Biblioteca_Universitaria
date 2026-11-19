# Biblioteca universitaria

Inicia el servicio REST local desde la carpeta del proyecto.

```powershell
dart server.dart
```

En otra terminal, ejecuta Flutter.

```powershell
flutter run -d chrome
```

La API escucha en todas las interfaces de red para que pueda ser alcanzada desde
un emulador Android. La app usa automáticamente `10.0.2.2` en el emulador
Android y `127.0.0.1` en web, Windows, iOS y macOS. Si usas un dispositivo
físico, reemplaza la URL por la IP local de tu computador:

```powershell
flutter run --dart-define=BIBLIOTECA_API_URL=http://192.168.1.10:8080
```

Para generar una APK para el celular, usa la IP Wi-Fi del computador al
momento de compilar:

```powershell
flutter build apk --release --dart-define=BIBLIOTECA_API_URL=http://192.168.1.55:8080
```

Instala el archivo `build\app\outputs\flutter-apk\app-release.apk`. La IP
`192.168.1.55` es válida solo mientras el computador conserve esa dirección;
si cambia, debes volver a compilar la APK con la nueva IP.

En web, si el navegador bloquea la solicitud, verifica que `dart server.dart`
siga ejecutándose en el puerto 8080 y vuelve a cargar la aplicación.

El servicio incluye tres libros de muestra y guarda los estudiantes, préstamos y cambios de stock en `.biblioteca.json`.


