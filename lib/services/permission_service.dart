import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestMicrophoneForTeamMode() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) return false;

    final result = await Permission.microphone.request();
    return result.isGranted;
  }
}
