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
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'dart:ui';
import 'core/state/app_state.dart';
import 'core/ui/error_guard.dart';
import 'features/transactions/screens/quick_entry_screen.dart';
import 'core/ui/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'features/settings/screens/pin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('es', null);
  await initializeDateFormatting('en', null);
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
        ChangeNotifierProvider.value(value: AppLocaleController.instance),
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
    } else if (state == AppLifecycleState.resumed) {
      _checkSecurityOnResume();
    }
  }

  void _checkSecurityOnResume() async {
    final securityEnabled = SecurityService.instance.isPinActive || 
                           SecurityService.instance.isBiometricActive;
    
    if (securityEnabled && !SecurityService.instance.isUnlocked) {
      // Si está habilitado y no está desbloqueado, enviamos al PIN
      // Usamos pushReplacementNamed para no acumular pantallas si ya estamos en una
      NavigationService.navigate("/pin");
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
      themeMode: ThemeMode.dark,
      theme: AppTheme.neonTheme,
      darkTheme: AppTheme.neonTheme,
      home: const InitialGuard(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}

class InitialGuard extends StatelessWidget {
  const InitialGuard({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios en el servicio de seguridad
    final security = context.watch<SecurityService>();

    // Mientras se cargan los ajustes (PIN, biométricos) del almacenamiento seguro
    if (!security.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
        ),
      );
    }

    final bool securityEnabled = security.isPinActive || security.isBiometricActive;

    // Si la seguridad está activa y el app está bloqueada, mostramos la pantalla de PIN
    // como contenido principal (esto evita saltos de navegación y race conditions)
    if (securityEnabled && !security.isUnlocked) {
      return const PinScreen();
    }

    // Si no hay seguridad o ya está desbloqueado, entramos a la app
    return const QuickEntryScreen();
  }
}
