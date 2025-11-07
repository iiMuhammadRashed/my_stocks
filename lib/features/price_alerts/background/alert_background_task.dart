import 'package:workmanager/workmanager.dart';
import 'package:path_provider/path_provider.dart';

import '../../../services/data/alert_checker_service.dart';
import '../../../services/data/hive_alerts_service.dart';

const String checkAlertsTask = "check_stock_alerts";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final storagePath = dir.path;

      await HiveAlertsService.init(storagePath: storagePath);

      final userId = inputData?['userId'] as String? ?? 'guest_user';

      await AlertCheckerService.runOnce(userId);

      return Future.value(true);
    } catch (e, st) {
      print('Background task error: $e\n$st');
      return Future.value(false);
    }
  });
}
