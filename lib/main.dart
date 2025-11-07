import 'dart:io';
import 'package:my_stocks/services/data/hive_alerts_service.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/ThemeProvider.dart';
import 'core/utils/user_manager.dart';
import 'features/error/presentation/connection_error_screen.dart';
import 'features/price_alerts/background/alert_background_task.dart';
import 'features/search_stocks/data/models/stock_model.dart';
import 'services/data/hive_favorites_service.dart';
import 'services/data/alert_checker_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(StockModelAdapter());
  }

  await Hive.openBox<StockModel>(HiveFavoritesService.favoritesBox);

  final dir = await getApplicationDocumentsDirectory();
  await HiveAlertsService.init(storagePath: dir.path);

  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  await Workmanager().registerOneOffTask(
    "check_alerts_once",
    checkAlertsTask,
    inputData: {'userId': 'guest_user'},
    initialDelay: const Duration(seconds: 5),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Uuid _uuid = const Uuid();
  late String _userId;

  bool _isLoading = true;
  bool _noInternet = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() {
      _isLoading = true;
      _noInternet = false;
      _error = null;
    });

    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw const SocketException('No Internet');
      }

      if (!Hive.isBoxOpen('userBox')) {
        await Hive.openBox('userBox');
      }

      await _initUserManager();
      await _handleUserSession();

      AlertCheckerService.startAutoCheck(_userId);

      setState(() => _isLoading = false);
    } on SocketException {
      setState(() {
        _isLoading = false;
        _noInternet = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Initialization error: $e';
      });
    }
  }

  Future<void> _initUserManager() async {
    try {
      await UserManager.init();
    } catch (e) {
      debugPrint('Error initializing UserManager: $e');
    }
  }

  Future<void> _handleUserSession() async {
    final userBox = Hive.box('userBox');
    final userId = userBox.get('userId');
    if (userId == null) {
      _userId = _uuid.v4();
      await userBox.put('userId', _userId);
    } else {
      _userId = userId;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_noInternet) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ConnectionErrorScreen(
          key: const ValueKey('no_internet_screen'),
          onRetry: _initializeApp,
        ),
      );
    }

    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'App initialization failed.\n\n$_error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(themeMode: ThemeMode.system),
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) => MaterialApp.router(
            title: 'My Stocks',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            routerConfig: AppRouter.router,
          ),
        ),
      ),
    );
  }
}
