import 'package:shared_preferences/shared_preferences.dart';

class PopupService {
  static const _prefix = 'dismissed_popup_';

  Future<bool> isDismissed(String popupKey) async {
    if (popupKey.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$popupKey') ?? false;
  }

  Future<void> dismiss(String popupKey) async {
    if (popupKey.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$popupKey', true);
  }
}
