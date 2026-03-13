import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/theme_service.dart';
import 'services/security_service.dart';
import 'services/purchase_service.dart';
import 'services/error_service.dart';
import 'services/notification_service.dart';
import 'services/currency_service.dart';
import 'services/pro_service.dart';

import 'core/router/app_router.dart';
import 'core/state/app_mode_controller.dart';
import 'core/router/navigation_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:home_widget/home_widget.dart';

import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'core/state/app_state.dart';
import 'core/ui/error_guard.dart';
import 'features/transactions/screens/quick_entry_screen.dart';
import 'core/ui/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }
  await CurrencyService.instance.loadCurrency();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    ErrorService.instance.logError(details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    ErrorService.instance.logError(error, stack);
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Builder(
      builder: (context) =>
          ErrorService.instance.getErrorWidget(context, details),
    );
  };

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppLocaleController()),
        ChangeNotifierProvider.value(value: AppState.instance),
        ChangeNotifierProvider.value(value: ThemeService.instance),
        ChangeNotifierProvider.value(value: SecurityService.instance),
        ChangeNotifierProvider.value(value: CurrencyService.instance),
        ChangeNotifierProvider.value(value: ProService.instance),
        ChangeNotifierProvider.value(value: AppModeController.instance),
      ],
      child: const ErrorGuard(child: GastosSimpleApp()),
    ),
  );
}

class GastosSimpleApp extends StatefulWidget {
  const GastosSimpleApp({super.key});

  @override
  State<GastosSimpleApp> createState() => _GastosSimpleAppState();
}

class _GastosSimpleAppState extends State<GastosSimpleApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
    _setupHomeWidget();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      SecurityService.instance.lock();
    }
  }

  Future<void> _initializeServices() async {
    try {
      await Future.wait([
        NotificationService.instance.init(),
        NotificationService.instance.scheduleDailyReminder(),
        CurrencyService.instance.loadCurrency(),
        PurchaseService.instance.init(),
      ]);
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  Future<void> _setupHomeWidget() async {
    HomeWidget.setAppGroupId('group.gastossimple.gastos_simple');
    HomeWidget.widgetClicked.listen(_handleUri);
  }

  void _handleUri(Uri? uri) {
    if (uri == null) return;

    if (uri.scheme == 'gastossimple' && uri.host == 'quick_entry') {
      final type = uri.queryParameters['type'];
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('pending_action', 'quick_entry');
        prefs.setString('pending_type', type ?? 'gasto');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeString = context.watch<AppLocaleController>().locale;
    final themeMode = context.watch<ThemeService>().themeMode;

    return MaterialApp(
      title: r'$imple',
      navigatorKey: NavigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      locale: Locale(localeString),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: themeMode,
      theme: AppTheme.neonTheme,
      darkTheme: AppTheme.neonTheme,
      home: const InitialGuard(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

class InitialGuard extends StatefulWidget {
  const InitialGuard({super.key});

  @override
  State<InitialGuard> createState() => _InitialGuardState();
}

class _InitialGuardState extends State<InitialGuard> {
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSecurity());
  }

  void _checkSecurity() async {
    if (_isChecking) return;
    _isChecking = true;

    final securityEnabled = await SecurityService.checkSecurity(context);

    if (!mounted) {
      _isChecking = false;
      return;
    }

    if (securityEnabled && !SecurityService.instance.isUnlocked) {
      await NavigationService.navigate("/pin");
    }

    _isChecking = false;
  }

  @override
  Widget build(BuildContext context) {
    return const QuickEntryScreen();
  }
}
