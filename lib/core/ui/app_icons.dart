import 'package:flutter/material.dart';

/// Catálogo de íconos de la app (R-3, D-032): **un concepto, un ícono**.
///
/// Ninguna pantalla escribe `Icons.…`: usa un nombre de este catálogo (o
/// `CategoryIcons.of` para las categorías). Todos son la versión `…_rounded`.
/// Un ícono de categoría no se usa para una acción.
class AppIcons {
  AppIcons._();

  // ── Secciones de la app ──
  static const IconData home = Icons.dashboard_rounded;
  static const IconData movements = Icons.swap_vert_rounded;
  static const IconData debts = Icons.account_balance_rounded;
  static const IconData recurring = Icons.autorenew_rounded;
  static const IconData installments = Icons.credit_card_rounded;
  static const IconData settings = Icons.settings_rounded;
  static const IconData stats = Icons.analytics_rounded;
  static const IconData goals = Icons.savings_rounded;
  static const IconData vault = Icons.lock_rounded;
  static const IconData vaultLeave = Icons.lock_open_rounded;
  static const IconData pro = Icons.workspace_premium_rounded;
  static const IconData proActive = Icons.verified_rounded;
  static const IconData quickEntry = Icons.flash_on_rounded;
  static const IconData categories = Icons.grid_view_rounded;
  static const IconData wallet = Icons.account_balance_wallet_rounded;
  static const IconData menu = Icons.menu_rounded;

  // ── Seguridad y privacidad ──
  static const IconData pin = Icons.pin_rounded;
  static const IconData fingerprint = Icons.fingerprint_rounded;
  static const IconData privacy = Icons.shield_rounded;
  static const IconData show = Icons.visibility_rounded;
  static const IconData hide = Icons.visibility_off_rounded;

  // ── Deudas ──
  static const IconData exitTips = Icons.lightbulb_outline_rounded;
  static const IconData avalanche = Icons.landslide_rounded;
  static const IconData snowball = Icons.ac_unit_rounded;
  static const IconData name = Icons.badge_rounded;
  static const IconData percent = Icons.percent_rounded;
  static const IconData installmentCount = Icons.reorder_rounded;

  // ── Acciones ──
  static const IconData add = Icons.add_rounded;
  static const IconData remove = Icons.remove_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData delete = Icons.delete_outline_rounded;
  static const IconData deleteAll = Icons.delete_sweep_rounded;
  static const IconData pay = Icons.paid_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData done = Icons.check_circle_rounded;
  static const IconData notDone = Icons.circle_outlined;
  static const IconData search = Icons.search_rounded;
  static const IconData filter = Icons.tune_rounded;
  static const IconData share = Icons.ios_share_rounded;
  static const IconData backspace = Icons.backspace_rounded;
  static const IconData stopRepeat = Icons.event_busy_rounded;
  static const IconData restore = Icons.restore_rounded;
  static const IconData openOutside = Icons.open_in_new_rounded;
  static const IconData next = Icons.chevron_right_rounded;
  static const IconData previous = Icons.chevron_left_rounded;

  // ── Fechas ──
  static const IconData day = Icons.calendar_today_rounded;
  static const IconData month = Icons.calendar_month_rounded;
  static const IconData pickDate = Icons.edit_calendar_rounded;
  static const IconData time = Icons.schedule_rounded;

  // ── Ajustes ──
  static const IconData language = Icons.language_rounded;
  static const IconData currency = Icons.monetization_on_rounded;
  static const IconData reminder = Icons.notifications_active_rounded;
  static const IconData backup = Icons.backup_rounded;
  static const IconData exportFile = Icons.upload_rounded;
  static const IconData importFile = Icons.download_rounded;
  static const IconData crashReports = Icons.bug_report_rounded;
  static const IconData devTools = Icons.science_rounded;
  static const IconData note = Icons.note_rounded;

  // ── Avisos ──
  static const IconData info = Icons.info_outline_rounded;
  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData error = Icons.error_outline_rounded;
  static const IconData tip = Icons.lightbulb_outline_rounded;

  // ── Solo en pantallas ocultas (D-013): Análisis mensual ──
  // Si se vuelve a mostrar, las tendencias se cambian (D-031).
  static const IconData trendUp = Icons.trending_up_rounded;
  static const IconData trendDown = Icons.trending_down_rounded;
  static const IconData speed = Icons.speed_rounded;
}

/// Escala de tamaños de ícono (R-5, D-032).
class AppIconSize {
  AppIconSize._();

  static const double small = 16;
  static const double normal = 20;
  static const double large = 24;
  static const double button = 28;
  static const double empty = 64;
}
