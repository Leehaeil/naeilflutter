import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static PermissionService? _instance;

  PermissionService._();

  static PermissionService get instance {
    _instance ??= PermissionService._();
    return _instance!;
  }

  Future<bool> requestStoragePermission() async {
    if (await Permission.storage.isGranted) {
      return true;
    }

    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<bool> requestCameraPermission() async {
    if (await Permission.camera.isGranted) {
      return true;
    }

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> requestPhotosPermission() async {
    if (await Permission.photos.isGranted) {
      return true;
    }

    final status = await Permission.photos.request();
    return status.isGranted;
  }

  Future<bool> requestMicrophonePermission() async {
    if (await Permission.microphone.isGranted) {
      return true;
    }

    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> checkInternetPermission() async {
    return true;
  }

  Future<Map<Permission, bool>> requestAllPermissions() async {
    final permissions = [
      Permission.storage,
      Permission.camera,
      Permission.photos,
      Permission.microphone,
    ];

    final statuses = await permissions.request();
    return statuses.map((key, value) => MapEntry(key, value.isGranted));
  }

  Future<bool> isStorageGranted() async {
    return await Permission.storage.isGranted;
  }

  Future<bool> isCameraGranted() async {
    return await Permission.camera.isGranted;
  }

  Future<bool> isPhotosGranted() async {
    return await Permission.photos.isGranted;
  }

  Future<bool> isMicrophoneGranted() async {
    return await Permission.microphone.isGranted;
  }
}

