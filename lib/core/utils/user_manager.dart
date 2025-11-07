import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class UserManager {
  static late Box _box;

  static Future<void> init() async {
    _box = await Hive.openBox('userBox');
  }

  static String getUserId() {
    if (_box.containsKey('userId')) {
      return _box.get('userId');
    } else {
      var uuid = Uuid();
      String userId = uuid.v4();
      _box.put('userId', userId);
      return userId;
    }
  }

  static String? getFcmToken() {
    return _box.get('fcmToken');
  }
}
