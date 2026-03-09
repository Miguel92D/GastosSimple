import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @app_name.
  ///
  /// In es, this message translates to:
  /// **'\$imple'**
  String get app_name;

  /// No description provided for @home.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get home;

  /// No description provided for @income.
  ///
  /// In es, this message translates to:
  /// **'Ingresos'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In es, this message translates to:
  /// **'Gastos'**
  String get expense;

  /// No description provided for @balance.
  ///
  /// In es, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settings;

  /// No description provided for @quick_entry_question.
  ///
  /// In es, this message translates to:
  /// **'¿Qué quieres registrar hoy?'**
  String get quick_entry_question;

  /// No description provided for @history.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get history;

  /// No description provided for @history_analytics.
  ///
  /// In es, this message translates to:
  /// **'📊 Historial / Análisis'**
  String get history_analytics;

  /// No description provided for @get_pro.
  ///
  /// In es, this message translates to:
  /// **'🚀 Obtener PRO'**
  String get get_pro;

  /// No description provided for @pro_active.
  ///
  /// In es, this message translates to:
  /// **'PRO activo'**
  String get pro_active;

  /// No description provided for @simple_pro.
  ///
  /// In es, this message translates to:
  /// **'\$imple PRO'**
  String get simple_pro;

  /// No description provided for @unlock_advanced_tools.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea herramientas financieras avanzadas.'**
  String get unlock_advanced_tools;

  /// No description provided for @benefit_strategies.
  ///
  /// In es, this message translates to:
  /// **'Estrategias inteligentes para salir de deudas'**
  String get benefit_strategies;

  /// No description provided for @benefit_predictions.
  ///
  /// In es, this message translates to:
  /// **'Predicción de gastos del mes'**
  String get benefit_predictions;

  /// No description provided for @benefit_analytics.
  ///
  /// In es, this message translates to:
  /// **'Analíticas financieras avanzadas'**
  String get benefit_analytics;

  /// No description provided for @benefit_future.
  ///
  /// In es, this message translates to:
  /// **'Mejoras futuras'**
  String get benefit_future;

  /// No description provided for @smart_insights.
  ///
  /// In es, this message translates to:
  /// **'Insights financieros inteligentes'**
  String get smart_insights;

  /// No description provided for @activate_pro.
  ///
  /// In es, this message translates to:
  /// **'Activar PRO'**
  String get activate_pro;

  /// No description provided for @restore_purchase.
  ///
  /// In es, this message translates to:
  /// **'Restaurar compra'**
  String get restore_purchase;

  /// No description provided for @monthly_plan.
  ///
  /// In es, this message translates to:
  /// **'Plan Mensual'**
  String get monthly_plan;

  /// No description provided for @lifetime_plan.
  ///
  /// In es, this message translates to:
  /// **'Plan Vitalicio'**
  String get lifetime_plan;

  /// No description provided for @monthly_price.
  ///
  /// In es, this message translates to:
  /// **'\$2.99 / mes'**
  String get monthly_price;

  /// No description provided for @lifetime_price.
  ///
  /// In es, this message translates to:
  /// **'\$19.99 pago único'**
  String get lifetime_price;

  /// No description provided for @pro_tools.
  ///
  /// In es, this message translates to:
  /// **'⭐ Herramientas PRO'**
  String get pro_tools;

  /// No description provided for @spending_predictions.
  ///
  /// In es, this message translates to:
  /// **'Predicción de gastos'**
  String get spending_predictions;

  /// No description provided for @advanced_analytics.
  ///
  /// In es, this message translates to:
  /// **'Analíticas avanzadas'**
  String get advanced_analytics;

  /// No description provided for @movements.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get movements;

  /// No description provided for @budgets.
  ///
  /// In es, this message translates to:
  /// **'Presupuestos'**
  String get budgets;

  /// No description provided for @goals.
  ///
  /// In es, this message translates to:
  /// **'Metas'**
  String get goals;

  /// No description provided for @debts.
  ///
  /// In es, this message translates to:
  /// **'Deudas'**
  String get debts;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @currency.
  ///
  /// In es, this message translates to:
  /// **'Moneda'**
  String get currency;

  /// No description provided for @current_balance.
  ///
  /// In es, this message translates to:
  /// **'Saldo actual'**
  String get current_balance;

  /// No description provided for @monthly_total.
  ///
  /// In es, this message translates to:
  /// **'Total del mes'**
  String get monthly_total;

  /// No description provided for @monthly_balance.
  ///
  /// In es, this message translates to:
  /// **'Balance mensual'**
  String get monthly_balance;

  /// No description provided for @category_expenses.
  ///
  /// In es, this message translates to:
  /// **'Gastos por categoría'**
  String get category_expenses;

  /// No description provided for @no_expenses_recorded.
  ///
  /// In es, this message translates to:
  /// **'No hay gastos registrados este mes.'**
  String get no_expenses_recorded;

  /// No description provided for @add_movement.
  ///
  /// In es, this message translates to:
  /// **'Añadir movimiento'**
  String get add_movement;

  /// No description provided for @edit_movement.
  ///
  /// In es, this message translates to:
  /// **'Editar movimiento'**
  String get edit_movement;

  /// No description provided for @amount.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get amount;

  /// No description provided for @category.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get category;

  /// No description provided for @date.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get date;

  /// No description provided for @description.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get description;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @confirm_delete.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar este movimiento?'**
  String get confirm_delete;

  /// No description provided for @all_categories.
  ///
  /// In es, this message translates to:
  /// **'Todas las categorías'**
  String get all_categories;

  /// No description provided for @transport.
  ///
  /// In es, this message translates to:
  /// **'Transporte'**
  String get transport;

  /// No description provided for @food.
  ///
  /// In es, this message translates to:
  /// **'Comida'**
  String get food;

  /// No description provided for @services.
  ///
  /// In es, this message translates to:
  /// **'Servicios'**
  String get services;

  /// No description provided for @entertainment.
  ///
  /// In es, this message translates to:
  /// **'Entretenimiento'**
  String get entertainment;

  /// No description provided for @health.
  ///
  /// In es, this message translates to:
  /// **'Salud'**
  String get health;

  /// No description provided for @education.
  ///
  /// In es, this message translates to:
  /// **'Educación'**
  String get education;

  /// No description provided for @other.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get other;

  /// No description provided for @financial_control_drawer.
  ///
  /// In es, this message translates to:
  /// **'Control Financiero'**
  String get financial_control_drawer;

  /// No description provided for @dashboard.
  ///
  /// In es, this message translates to:
  /// **'Panel'**
  String get dashboard;

  /// No description provided for @premium.
  ///
  /// In es, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @light_mode.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get light_mode;

  /// No description provided for @dark_mode.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get dark_mode;

  /// No description provided for @financial_health.
  ///
  /// In es, this message translates to:
  /// **'Salud financiera'**
  String get financial_health;

  /// No description provided for @based_on_month.
  ///
  /// In es, this message translates to:
  /// **'Basado en tus datos del mes'**
  String get based_on_month;

  /// No description provided for @insights.
  ///
  /// In es, this message translates to:
  /// **'Sugerencias'**
  String get insights;

  /// No description provided for @racha.
  ///
  /// In es, this message translates to:
  /// **'Racha'**
  String get racha;

  /// No description provided for @prediction.
  ///
  /// In es, this message translates to:
  /// **'Predicción'**
  String get prediction;

  /// No description provided for @days_count.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 día} other{{count} días}}'**
  String days_count(num count);

  /// No description provided for @prediction_warning.
  ///
  /// In es, this message translates to:
  /// **'Peligro: Gastos elevados este mes'**
  String get prediction_warning;

  /// No description provided for @no_today_movements.
  ///
  /// In es, this message translates to:
  /// **'No hay movimientos hoy.'**
  String get no_today_movements;

  /// No description provided for @unlock_unlimited.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea movimientos ilimitados y más.'**
  String get unlock_unlimited;

  /// No description provided for @view_plans.
  ///
  /// In es, this message translates to:
  /// **'Ver planes'**
  String get view_plans;

  /// No description provided for @debt_exit_plan.
  ///
  /// In es, this message translates to:
  /// **'Plan para salir de deudas'**
  String get debt_exit_plan;

  /// No description provided for @extra_monthly_amount.
  ///
  /// In es, this message translates to:
  /// **'Monto mensual extra para deudas'**
  String get extra_monthly_amount;

  /// No description provided for @join_premium.
  ///
  /// In es, this message translates to:
  /// **'Hazte Premium'**
  String get join_premium;

  /// No description provided for @premium_description.
  ///
  /// In es, this message translates to:
  /// **'Mejora tu experiencia financiera con estas funciones:'**
  String get premium_description;

  /// No description provided for @feature_stats.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas avanzadas'**
  String get feature_stats;

  /// No description provided for @feature_budgets.
  ///
  /// In es, this message translates to:
  /// **'Presupuestos flexibles'**
  String get feature_budgets;

  /// No description provided for @feature_export.
  ///
  /// In es, this message translates to:
  /// **'Exportación de datos'**
  String get feature_export;

  /// No description provided for @feature_vault.
  ///
  /// In es, this message translates to:
  /// **'Bóveda personal'**
  String get feature_vault;

  /// No description provided for @feature_recurring.
  ///
  /// In es, this message translates to:
  /// **'Movimientos recurrentes'**
  String get feature_recurring;

  /// No description provided for @feature_history.
  ///
  /// In es, this message translates to:
  /// **'Historial detallado'**
  String get feature_history;

  /// No description provided for @subscribe_now.
  ///
  /// In es, this message translates to:
  /// **'Suscríbete ahora'**
  String get subscribe_now;

  /// No description provided for @already_premium.
  ///
  /// In es, this message translates to:
  /// **'Eres Premium'**
  String get already_premium;

  /// No description provided for @premium_test_unlocked.
  ///
  /// In es, this message translates to:
  /// **'¡Premium desbloqueado para pruebas!'**
  String get premium_test_unlocked;

  /// No description provided for @credit_card_closing_day.
  ///
  /// In es, this message translates to:
  /// **'Cierre de tarjeta (día del mes)'**
  String get credit_card_closing_day;

  /// No description provided for @closing_day.
  ///
  /// In es, this message translates to:
  /// **'Cierra el día: {day}'**
  String closing_day(Object day);

  /// No description provided for @closing_day_validation.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un valor entre 1 y 31'**
  String get closing_day_validation;

  /// No description provided for @interest_rate_title.
  ///
  /// In es, this message translates to:
  /// **'Tasa de interés'**
  String get interest_rate_title;

  /// No description provided for @interest_rate_desc.
  ///
  /// In es, this message translates to:
  /// **'Es el porcentaje que el banco cobra por financiar el saldo de tu tarjeta. Cuanto más alto sea, más rápido crecerá la deuda si pagas solo el mínimo.'**
  String get interest_rate_desc;

  /// No description provided for @card_closing_title.
  ///
  /// In es, this message translates to:
  /// **'Cierre de tarjeta'**
  String get card_closing_title;

  /// No description provided for @card_closing_desc.
  ///
  /// In es, this message translates to:
  /// **'Es el día en que el banco calcula todos los gastos de tu tarjeta para generar el resumen del mes.'**
  String get card_closing_desc;

  /// No description provided for @due_date_title.
  ///
  /// In es, this message translates to:
  /// **'Fecha de vencimiento'**
  String get due_date_title;

  /// No description provided for @due_date_desc.
  ///
  /// In es, this message translates to:
  /// **'Es el último día para pagar tu tarjeta sin generar intereses o recargos.'**
  String get due_date_desc;

  /// No description provided for @cat_food.
  ///
  /// In es, this message translates to:
  /// **'Comida'**
  String get cat_food;

  /// No description provided for @cat_transport.
  ///
  /// In es, this message translates to:
  /// **'Transporte'**
  String get cat_transport;

  /// No description provided for @cat_leisure.
  ///
  /// In es, this message translates to:
  /// **'Ocio'**
  String get cat_leisure;

  /// No description provided for @cat_health.
  ///
  /// In es, this message translates to:
  /// **'Salud'**
  String get cat_health;

  /// No description provided for @cat_education.
  ///
  /// In es, this message translates to:
  /// **'Educación'**
  String get cat_education;

  /// No description provided for @cat_others.
  ///
  /// In es, this message translates to:
  /// **'Otros'**
  String get cat_others;

  /// No description provided for @cat_salary.
  ///
  /// In es, this message translates to:
  /// **'Salario'**
  String get cat_salary;

  /// No description provided for @cat_sale.
  ///
  /// In es, this message translates to:
  /// **'Venta'**
  String get cat_sale;

  /// No description provided for @cat_gift.
  ///
  /// In es, this message translates to:
  /// **'Regalo'**
  String get cat_gift;

  /// No description provided for @cat_investment.
  ///
  /// In es, this message translates to:
  /// **'Inversión'**
  String get cat_investment;

  /// No description provided for @amount_error.
  ///
  /// In es, this message translates to:
  /// **'Monto inválido'**
  String get amount_error;

  /// No description provided for @new_goal.
  ///
  /// In es, this message translates to:
  /// **'Nueva meta'**
  String get new_goal;

  /// No description provided for @edit_goal.
  ///
  /// In es, this message translates to:
  /// **'Editar meta'**
  String get edit_goal;

  /// No description provided for @goal_name_label.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la meta'**
  String get goal_name_label;

  /// No description provided for @target_label.
  ///
  /// In es, this message translates to:
  /// **'Monto objetivo'**
  String get target_label;

  /// No description provided for @savings_goals.
  ///
  /// In es, this message translates to:
  /// **'Metas de ahorro'**
  String get savings_goals;

  /// No description provided for @no_goals_yet.
  ///
  /// In es, this message translates to:
  /// **'No hay metas registradas.'**
  String get no_goals_yet;

  /// No description provided for @spending_warning.
  ///
  /// In es, this message translates to:
  /// **'¡Cuidado con tus gastos!'**
  String get spending_warning;

  /// No description provided for @good_income_insight.
  ///
  /// In es, this message translates to:
  /// **'¡Buen nivel de ingresos este mes!'**
  String get good_income_insight;

  /// No description provided for @no_data_export.
  ///
  /// In es, this message translates to:
  /// **'No hay datos para exportar.'**
  String get no_data_export;

  /// No description provided for @export_subject.
  ///
  /// In es, this message translates to:
  /// **'Mis Finanzas - Gastos Simple'**
  String get export_subject;

  /// No description provided for @search.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get search;

  /// No description provided for @search_tooltip.
  ///
  /// In es, this message translates to:
  /// **'Buscar movimientos'**
  String get search_tooltip;

  /// No description provided for @export_data.
  ///
  /// In es, this message translates to:
  /// **'Exportar datos'**
  String get export_data;

  /// No description provided for @no_debts_recorded.
  ///
  /// In es, this message translates to:
  /// **'No hay deudas registradas.'**
  String get no_debts_recorded;

  /// No description provided for @amount_to_pay.
  ///
  /// In es, this message translates to:
  /// **'Monto a pagar'**
  String get amount_to_pay;

  /// No description provided for @pay.
  ///
  /// In es, this message translates to:
  /// **'Pagar'**
  String get pay;

  /// No description provided for @priority_tip.
  ///
  /// In es, this message translates to:
  /// **'Prioridad: Paga {name} ({rate}%) para ahorrar en intereses.'**
  String priority_tip(Object name, Object rate);

  /// No description provided for @extra_payment_tip.
  ///
  /// In es, this message translates to:
  /// **'Con {amount} extra, liquidarás {name} en {months} meses.'**
  String extra_payment_tip(Object amount, Object months, Object name);

  /// No description provided for @snowball_method.
  ///
  /// In es, this message translates to:
  /// **'Método bola de nieve: Enfócate en {name}.'**
  String snowball_method(Object name);

  /// No description provided for @new_debt.
  ///
  /// In es, this message translates to:
  /// **'Nueva deuda'**
  String get new_debt;

  /// No description provided for @edit_debt.
  ///
  /// In es, this message translates to:
  /// **'Editar deuda'**
  String get edit_debt;

  /// No description provided for @debt_name_label.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la deuda'**
  String get debt_name_label;

  /// No description provided for @total_amount.
  ///
  /// In es, this message translates to:
  /// **'Monto total'**
  String get total_amount;

  /// No description provided for @min_payment.
  ///
  /// In es, this message translates to:
  /// **'Pago mínimo'**
  String get min_payment;

  /// No description provided for @interest_rate_optional.
  ///
  /// In es, this message translates to:
  /// **'Tasa de interés % (opcional)'**
  String get interest_rate_optional;

  /// No description provided for @card_closing_label.
  ///
  /// In es, this message translates to:
  /// **'Cierre de tarjeta (día del mes)'**
  String get card_closing_label;

  /// No description provided for @due_day_label.
  ///
  /// In es, this message translates to:
  /// **'Día de vencimiento (ej: 15)'**
  String get due_day_label;

  /// No description provided for @interest_annual.
  ///
  /// In es, this message translates to:
  /// **'Interés: {rate}% anual'**
  String interest_annual(Object rate);

  /// No description provided for @vence_dia.
  ///
  /// In es, this message translates to:
  /// **'Vence día: '**
  String get vence_dia;

  /// No description provided for @cierre_dia.
  ///
  /// In es, this message translates to:
  /// **'Cierra día: '**
  String get cierre_dia;

  /// No description provided for @remaining_amount.
  ///
  /// In es, this message translates to:
  /// **'Resta: {amount}'**
  String remaining_amount(Object amount);

  /// No description provided for @min_pay_amount.
  ///
  /// In es, this message translates to:
  /// **'Mín: {amount}'**
  String min_pay_amount(Object amount);

  /// No description provided for @archived.
  ///
  /// In es, this message translates to:
  /// **'Archivado'**
  String get archived;

  /// No description provided for @assign_to_goal.
  ///
  /// In es, this message translates to:
  /// **'Asignar a meta'**
  String get assign_to_goal;

  /// No description provided for @biometric_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Usa tu huella o rostro'**
  String get biometric_subtitle;

  /// No description provided for @biometric_unlock.
  ///
  /// In es, this message translates to:
  /// **'Desbloqueo biométrico'**
  String get biometric_unlock;

  /// No description provided for @budget_example.
  ///
  /// In es, this message translates to:
  /// **'Ejemplo: Comida (Max 500)'**
  String get budget_example;

  /// No description provided for @change_pin.
  ///
  /// In es, this message translates to:
  /// **'Cambiar PIN'**
  String get change_pin;

  /// No description provided for @closing_day_error.
  ///
  /// In es, this message translates to:
  /// **'El día de cierre debe estar entre 1 y 31'**
  String get closing_day_error;

  /// No description provided for @daily.
  ///
  /// In es, this message translates to:
  /// **'Diario'**
  String get daily;

  /// No description provided for @enable_pin.
  ///
  /// In es, this message translates to:
  /// **'Habilitar PIN'**
  String get enable_pin;

  /// No description provided for @expense_history.
  ///
  /// In es, this message translates to:
  /// **'Historial de gastos'**
  String get expense_history;

  /// No description provided for @income_history.
  ///
  /// In es, this message translates to:
  /// **'Historial de ingresos'**
  String get income_history;

  /// No description provided for @legal.
  ///
  /// In es, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @no_archived_movements.
  ///
  /// In es, this message translates to:
  /// **'No hay movimientos archivados.'**
  String get no_archived_movements;

  /// No description provided for @no_movements_recorded.
  ///
  /// In es, this message translates to:
  /// **'No hay movimientos registrados.'**
  String get no_movements_recorded;

  /// No description provided for @not_set.
  ///
  /// In es, this message translates to:
  /// **'No establecido'**
  String get not_set;

  /// No description provided for @note.
  ///
  /// In es, this message translates to:
  /// **'Nota'**
  String get note;

  /// No description provided for @pin_subtitle.
  ///
  /// In es, this message translates to:
  /// **'Protege tus datos con un código'**
  String get pin_subtitle;

  /// No description provided for @privacy_policy.
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad'**
  String get privacy_policy;

  /// No description provided for @select_goal.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar meta'**
  String get select_goal;

  /// No description provided for @set_pin.
  ///
  /// In es, this message translates to:
  /// **'Configurar PIN'**
  String get set_pin;

  /// No description provided for @security.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get security;

  /// No description provided for @new_pin_label.
  ///
  /// In es, this message translates to:
  /// **'Nuevo PIN'**
  String get new_pin_label;

  /// No description provided for @new_movement.
  ///
  /// In es, this message translates to:
  /// **'Nuevo movimiento'**
  String get new_movement;

  /// No description provided for @weekly.
  ///
  /// In es, this message translates to:
  /// **'Semanalmente'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In es, this message translates to:
  /// **'Mensualmente'**
  String get monthly;

  /// No description provided for @recurring.
  ///
  /// In es, this message translates to:
  /// **'Recurrente'**
  String get recurring;

  /// No description provided for @frequency.
  ///
  /// In es, this message translates to:
  /// **'Frecuencia'**
  String get frequency;

  /// No description provided for @amount_to_assign.
  ///
  /// In es, this message translates to:
  /// **'Monto a asignar'**
  String get amount_to_assign;

  /// No description provided for @budget_title.
  ///
  /// In es, this message translates to:
  /// **'Presupuesto: {category}'**
  String budget_title(Object category);

  /// No description provided for @top_category_insight.
  ///
  /// In es, this message translates to:
  /// **'Tu mayor gasto fue en {category}'**
  String top_category_insight(Object category);

  /// No description provided for @private_movements.
  ///
  /// In es, this message translates to:
  /// **'Bóveda privada'**
  String get private_movements;

  /// No description provided for @no_private_movements.
  ///
  /// In es, this message translates to:
  /// **'No tienes movimientos privados guardados.'**
  String get no_private_movements;

  /// No description provided for @secret_expenses.
  ///
  /// In es, this message translates to:
  /// **'Bóveda privada'**
  String get secret_expenses;

  /// No description provided for @hide_movement.
  ///
  /// In es, this message translates to:
  /// **'Ocultar (Privado)'**
  String get hide_movement;

  /// No description provided for @restore_movement.
  ///
  /// In es, this message translates to:
  /// **'Restaurar movimiento'**
  String get restore_movement;

  /// No description provided for @add_transaction_fab.
  ///
  /// In es, this message translates to:
  /// **'Agregar movimiento'**
  String get add_transaction_fab;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
