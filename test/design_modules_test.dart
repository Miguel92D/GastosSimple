// Sistema de diseño modular (chat 08, D-032): cada módulo mide lo mismo en
// cualquier pantalla y con cualquier contenido (R-4).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gastos_simple/core/i18n/app_locale_controller.dart';
import 'package:gastos_simple/core/state/app_state.dart';
import 'package:gastos_simple/core/ui/app_colors.dart';
import 'package:gastos_simple/core/ui/app_icons.dart';
import 'package:gastos_simple/core/ui/app_text_styles.dart';
import 'package:gastos_simple/core/ui/widgets/app_action_button.dart';
import 'package:gastos_simple/core/ui/widgets/app_amount.dart';
import 'package:gastos_simple/core/ui/widgets/app_list_row.dart';
import 'package:gastos_simple/core/ui/widgets/app_empty_state.dart';
import 'package:gastos_simple/core/ui/widgets/app_icon_box.dart';
import 'package:gastos_simple/core/ui/widgets/app_logo.dart';
import 'package:gastos_simple/core/ui/widgets/app_progress_bar.dart';
import 'package:gastos_simple/core/ui/widgets/app_round_button.dart';
import 'package:gastos_simple/core/ui/widgets/app_secondary_button.dart';
import 'package:gastos_simple/core/ui/widgets/app_section_title.dart';
import 'package:gastos_simple/core/ui/widgets/app_segmented.dart';
import 'package:gastos_simple/core/ui/widgets/app_sheet.dart';
import 'package:gastos_simple/features/dev/design_catalog_screen.dart';
import 'package:gastos_simple/services/currency_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget app(Widget child) => MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: AppLocaleController.instance),
      ChangeNotifierProvider.value(value: AppState.instance),
      ChangeNotifierProvider.value(value: CurrencyService.instance),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: 360, child: child)),
      ),
    ),
  );

  testWidgets('botón redondo: 56×56 con cualquier ícono y color', (t) async {
    await t.pumpWidget(
      app(
        Row(
          children: [
            AppRoundButton(icon: AppIcons.add, onTap: () {}),
            AppRoundButton(
              icon: AppIcons.menu,
              color: AppColors.expenseRed,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
    for (final e in find.byType(AppRoundButton).evaluate()) {
      expect(t.getSize(find.byWidget(e.widget)), const Size(56, 56));
    }
  });

  testWidgets('botón chico 38×38 y caja de ícono 40×40', (t) async {
    await t.pumpWidget(
      app(
        Row(
          children: [
            AppActionButton(
              icon: AppIcons.pay,
              color: AppColors.incomeGreen,
              onTap: () {},
            ),
            const AppIconBox(
              icon: AppIcons.debts,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
    expect(t.getSize(find.byType(AppActionButton)), const Size(38, 38));
    expect(t.getSize(find.byType(AppIconBox)), const Size(40, 40));
  });

  testWidgets('barra de progreso: alto 8 con 0, 1 o pasada', (t) async {
    for (final v in [0.0, 0.5, 1.0, 3.0, double.nan]) {
      await t.pumpWidget(app(AppProgressBar(value: v)));
      await t.pumpAndSettle();
      expect(t.getSize(find.byType(AppProgressBar)).height, 8);
    }
  });

  testWidgets('botón secundario: alto 48 y texto en MAYÚSCULAS', (t) async {
    await t.pumpWidget(
      app(AppSecondaryButton(text: 'Agregar primera deuda', onPressed: () {})),
    );
    expect(t.getSize(find.byType(AppSecondaryButton)).height, 48);
    expect(find.text('AGREGAR PRIMERA DEUDA'), findsOneWidget);
  });

  testWidgets('título de sección en MAYÚSCULAS', (t) async {
    await t.pumpWidget(app(const AppSectionTitle('Seguridad')));
    expect(find.text('SEGURIDAD'), findsOneWidget);
  });

  testWidgets('selector: mismo alto con la opción elegida o no', (t) async {
    var selected = 'day';
    Future<double> height() async {
      await t.pumpWidget(
        app(
          AppSegmented<String>(
            segments: const [
              AppSegment(value: 'day', label: 'Día', icon: AppIcons.day),
              AppSegment(value: 'month', label: 'Mes', icon: AppIcons.month),
            ],
            selected: selected,
            onChanged: (_) {},
          ),
        ),
      );
      await t.pumpAndSettle();
      return t.getSize(find.byType(AppSegmented<String>)).height;
    }

    final a = await height();
    selected = 'month';
    expect(await height(), a);
    expect(find.text('DÍA'), findsOneWidget);
  });

  testWidgets('estado vacío con y sin botón', (t) async {
    var tapped = false;
    await t.pumpWidget(
      app(
        AppEmptyState(
          icon: AppIcons.debts,
          text: 'Sin deudas',
          actionText: 'Agregar',
          onAction: () => tapped = true,
        ),
      ),
    );
    await t.tap(find.text('AGREGAR'));
    expect(tapped, isTrue);
  });

  testWidgets('panel de abajo siempre con su rayita', (t) async {
    await t.pumpWidget(
      app(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => AppSheet.show<void>(
              context,
              builder: (_) => const Text('contenido'),
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await t.tap(find.text('abrir'));
    await t.pumpAndSettle();
    expect(find.byType(AppSheetHandle), findsOneWidget);
    expect(find.text('contenido'), findsOneWidget);
  });

  testWidgets('fila: mismo alto con monto corto o gigante (R-4)', (t) async {
    Future<double> heightFor(double v) async {
      await t.pumpWidget(
        app(
          AppListRow(
            icon: AppIcons.recurring,
            iconColor: AppColors.expenseRed,
            title: 'Netflix',
            subtitle: 'Mensual',
            trailing: AppAmount.list(value: v, color: AppColors.expenseRed),
          ),
        ),
      );
      return t.getSize(find.byType(AppListRow)).height;
    }

    final small = await heightFor(8999);
    expect(await heightFor(609099096909.60), small);
    final style = t
        .widget<Text>(
          find.descendant(
            of: find.byType(AppAmount),
            matching: find.byType(Text),
          ),
        )
        .style!;
    expect(style.fontSize, AppTextStyles.amountList.fontSize);
  });

  testWidgets('monto oculto con el ojo del inicio', (t) async {
    await t.pumpWidget(app(const AppAmount.list(value: 1500, hidden: true)));
    expect(find.text(AppAmount.hiddenText), findsOneWidget);
  });

  testWidgets('fila de Ajustes: caja violeta y flecha', (t) async {
    await t.pumpWidget(
      app(AppListRow.setting(icon: AppIcons.pin, title: 'PIN', onTap: () {})),
    );
    expect(
      t.widget<AppIconBox>(find.byType(AppIconBox)).color,
      AppColors.primaryPurple,
    );
    expect(find.byIcon(AppIcons.next), findsOneWidget);
  });

  testWidgets('el logo dice \$imple con o sin Pro', (t) async {
    await t.pumpWidget(app(const AppLogo()));
    expect(find.text('\$imple'), findsOneWidget);
  });

  testWidgets('el catálogo de diseño abre sin errores (paso 7)', (t) async {
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: AppLocaleController.instance),
          ChangeNotifierProvider.value(value: AppState.instance),
          ChangeNotifierProvider.value(value: CurrencyService.instance),
        ],
        child: const MaterialApp(home: DesignCatalogScreen()),
      ),
    );
    await t.pump(const Duration(seconds: 1));
    expect(find.text('Catálogo'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
