import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission() async {
  final photosStatus = await Permission.photos.request();
  if (photosStatus.isGranted) return true;

  final storageStatus = await Permission.storage.request();
  if (storageStatus.isGranted) return true;

  if (photosStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied) {
    await openAppSettings();
  }

  return false;
}
