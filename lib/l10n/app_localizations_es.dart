// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get app_name => '\$imple';

  @override
  String get home => 'Inicio';

  @override
  String get income => 'Ingresos';

  @override
  String get expense => 'Gastos';

  @override
  String get balance => 'Balance';

  @override
  String get settings => 'Ajustes';

  @override
  String get quick_entry_question => '¿Qué quieres registrar hoy?';

  @override
  String get history => 'Historial';

  @override
  String get history_analytics => '📊 Historial / Análisis';

  @override
  String get get_pro => '🚀 Obtener PRO';

  @override
  String get pro_active => 'PRO activo';

  @override
  String get simple_pro => '\$imple PRO';

  @override
  String get unlock_advanced_tools =>
      'Desbloquea herramientas financieras avanzadas.';

  @override
  String get benefit_strategies =>
      'Estrategias inteligentes para salir de deudas';

  @override
  String get benefit_predictions => 'Predicción de gastos del mes';

  @override
  String get benefit_analytics => 'Analíticas financieras avanzadas';

  @override
  String get benefit_future => 'Mejoras futuras';

  @override
  String get smart_insights => 'Insights financieros inteligentes';

  @override
  String get activate_pro => 'Activar PRO';

  @override
  String get restore_purchase => 'Restaurar compra';

  @override
  String get monthly_plan => 'Plan Mensual';

  @override
  String get lifetime_plan => 'Plan Vitalicio';

  @override
  String get monthly_price => '\$2.99 / mes';

  @override
  String get lifetime_price => '\$19.99 pago único';

  @override
  String get pro_tools => '⭐ Herramientas PRO';

  @override
  String get spending_predictions => 'Predicción de gastos';

  @override
  String get advanced_analytics => 'Analíticas avanzadas';

  @override
  String get movements => 'Movimientos';

  @override
  String get budgets => 'Presupuestos';

  @override
  String get goals => 'Metas';

  @override
  String get debts => 'Deudas';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get currency => 'Moneda';

  @override
  String get current_balance => 'Saldo actual';

  @override
  String get monthly_total => 'Total del mes';

  @override
  String get monthly_balance => 'Balance mensual';

  @override
  String get category_expenses => 'Gastos por categoría';

  @override
  String get no_expenses_recorded => 'No hay gastos registrados este mes.';

  @override
  String get add_movement => 'Añadir movimiento';

  @override
  String get edit_movement => 'Editar movimiento';

  @override
  String get amount => 'Monto';

  @override
  String get category => 'Categoría';

  @override
  String get date => 'Fecha';

  @override
  String get description => 'Descripción';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get confirm_delete =>
      '¿Estás seguro de que quieres eliminar este movimiento?';

  @override
  String get all_categories => 'Todas las categorías';

  @override
  String get transport => 'Transporte';

  @override
  String get food => 'Comida';

  @override
  String get services => 'Servicios';

  @override
  String get entertainment => 'Entretenimiento';

  @override
  String get health => 'Salud';

  @override
  String get education => 'Educación';

  @override
  String get other => 'Otro';

  @override
  String get financial_control_drawer => 'Control Financiero';

  @override
  String get dashboard => 'Panel';

  @override
  String get premium => 'Premium';

  @override
  String get light_mode => 'Claro';

  @override
  String get dark_mode => 'Oscuro';

  @override
  String get financial_health => 'Salud financiera';

  @override
  String get based_on_month => 'Basado en tus datos del mes';

  @override
  String get insights => 'Sugerencias';

  @override
  String get racha => 'Racha';

  @override
  String get prediction => 'Predicción';

  @override
  String days_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get prediction_warning => 'Peligro: Gastos elevados este mes';

  @override
  String get no_today_movements => 'No hay movimientos hoy.';

  @override
  String get unlock_unlimited => 'Desbloquea movimientos ilimitados y más.';

  @override
  String get view_plans => 'Ver planes';

  @override
  String get debt_exit_plan => 'Plan para salir de deudas';

  @override
  String get extra_monthly_amount => 'Monto mensual extra para deudas';

  @override
  String get join_premium => 'Hazte Premium';

  @override
  String get premium_description =>
      'Mejora tu experiencia financiera con estas funciones:';

  @override
  String get feature_stats => 'Estadísticas avanzadas';

  @override
  String get feature_budgets => 'Presupuestos flexibles';

  @override
  String get feature_export => 'Exportación de datos';

  @override
  String get feature_vault => 'Bóveda personal';

  @override
  String get feature_recurring => 'Movimientos recurrentes';

  @override
  String get feature_history => 'Historial detallado';

  @override
  String get subscribe_now => 'Suscríbete ahora';

  @override
  String get already_premium => 'Eres Premium';

  @override
  String get premium_test_unlocked => '¡Premium desbloqueado para pruebas!';

  @override
  String get credit_card_closing_day => 'Cierre de tarjeta (día del mes)';

  @override
  String closing_day(Object day) {
    return 'Cierra el día: $day';
  }

  @override
  String get closing_day_validation => 'Ingresa un valor entre 1 y 31';

  @override
  String get interest_rate_title => 'Tasa de interés';

  @override
  String get interest_rate_desc =>
      'Es el porcentaje que el banco cobra por financiar el saldo de tu tarjeta. Cuanto más alto sea, más rápido crecerá la deuda si pagas solo el mínimo.';

  @override
  String get card_closing_title => 'Cierre de tarjeta';

  @override
  String get card_closing_desc =>
      'Es el día en que el banco calcula todos los gastos de tu tarjeta para generar el resumen del mes.';

  @override
  String get due_date_title => 'Fecha de vencimiento';

  @override
  String get due_date_desc =>
      'Es el último día para pagar tu tarjeta sin generar intereses o recargos.';

  @override
  String get cat_food => 'Comida';

  @override
  String get cat_transport => 'Transporte';

  @override
  String get cat_leisure => 'Ocio';

  @override
  String get cat_health => 'Salud';

  @override
  String get cat_education => 'Educación';

  @override
  String get cat_others => 'Otros';

  @override
  String get cat_salary => 'Salario';

  @override
  String get cat_sale => 'Venta';

  @override
  String get cat_gift => 'Regalo';

  @override
  String get cat_investment => 'Inversión';

  @override
  String get amount_error => 'Monto inválido';

  @override
  String get new_goal => 'Nueva meta';

  @override
  String get edit_goal => 'Editar meta';

  @override
  String get goal_name_label => 'Nombre de la meta';

  @override
  String get target_label => 'Monto objetivo';

  @override
  String get savings_goals => 'Metas de ahorro';

  @override
  String get no_goals_yet => 'No hay metas registradas.';

  @override
  String get spending_warning => '¡Cuidado con tus gastos!';

  @override
  String get good_income_insight => '¡Buen nivel de ingresos este mes!';

  @override
  String get no_data_export => 'No hay datos para exportar.';

  @override
  String get export_subject => 'Mis Finanzas - \$imple';

  @override
  String get search => 'Buscar';

  @override
  String get search_tooltip => 'Buscar movimientos';

  @override
  String get export_data => 'Exportar datos';

  @override
  String get no_debts_recorded => 'No hay deudas registradas.';

  @override
  String get amount_to_pay => 'Monto a pagar';

  @override
  String get pay => 'Pagar';

  @override
  String priority_tip(Object name, Object rate) {
    return 'Prioridad: Paga $name ($rate%) para ahorrar en intereses.';
  }

  @override
  String extra_payment_tip(Object amount, Object name, Object months) {
    return 'Con $amount extra, liquidarás $name en $months meses.';
  }

  @override
  String snowball_method(Object name) {
    return 'Método bola de nieve: Enfócate en $name.';
  }

  @override
  String get new_debt => 'Nueva deuda';

  @override
  String get edit_debt => 'Editar deuda';

  @override
  String get debt_name_label => 'Nombre de la deuda';

  @override
  String get total_amount => 'Monto total';

  @override
  String get min_payment => 'Pago mínimo';

  @override
  String get interest_rate_optional => 'Tasa de interés % (opcional)';

  @override
  String get card_closing_label => 'Cierre de tarjeta (día del mes)';

  @override
  String get due_day_label => 'Día de vencimiento (ej: 15)';

  @override
  String interest_annual(Object rate) {
    return 'Interés: $rate% anual';
  }

  @override
  String get vence_dia => 'Vence día: ';

  @override
  String get cierre_dia => 'Cierra día: ';

  @override
  String remaining_amount(Object amount) {
    return 'Resta: $amount';
  }

  @override
  String min_pay_amount(Object amount) {
    return 'Mín: $amount';
  }

  @override
  String get archived => 'Archivado';

  @override
  String get assign_to_goal => 'Asignar a meta';

  @override
  String get biometric_subtitle => 'Usa tu huella o rostro';

  @override
  String get biometric_unlock => 'Desbloqueo biométrico';

  @override
  String get budget_example => 'Ejemplo: Comida (Max 500)';

  @override
  String get change_pin => 'Cambiar PIN';

  @override
  String get closing_day_error => 'El día de cierre debe estar entre 1 y 31';

  @override
  String get daily => 'Diario';

  @override
  String get enable_pin => 'Habilitar PIN';

  @override
  String get expense_history => 'Historial de gastos';

  @override
  String get income_history => 'Historial de ingresos';

  @override
  String get legal => 'Legal';

  @override
  String get no_archived_movements => 'No hay movimientos archivados.';

  @override
  String get no_movements_recorded => 'No hay movimientos registrados.';

  @override
  String get not_set => 'No establecido';

  @override
  String get note => 'Nota';

  @override
  String get pin_subtitle => 'Protege tus datos con un código';

  @override
  String get privacy_policy => 'Política de Privacidad';

  @override
  String get select_goal => 'Seleccionar meta';

  @override
  String get set_pin => 'Configurar PIN';

  @override
  String get enter_pin => 'Ingresa tu PIN';

  @override
  String get security => 'Seguridad';

  @override
  String get new_pin_label => 'Nuevo PIN';

  @override
  String get vault_only_pin => 'Solo para Bóveda Privada';

  @override
  String get vault_only_pin_desc =>
      'La app abrirá normalmente, pero la bóveda pedirá PIN';

  @override
  String get new_movement => 'Nuevo movimiento';

  @override
  String get weekly => 'Semanalmente';

  @override
  String get monthly => 'Mensualmente';

  @override
  String get recurring => 'Recurrente';

  @override
  String get frequency => 'Frecuencia';

  @override
  String get amount_to_assign => 'Monto a asignar';

  @override
  String budget_title(Object category) {
    return 'Presupuesto: $category';
  }

  @override
  String top_category_insight(Object category) {
    return 'Tu mayor gasto fue en $category';
  }

  @override
  String get private_movements => 'Bóveda privada';

  @override
  String get no_private_movements =>
      'No tienes movimientos privados guardados.';

  @override
  String get secret_expenses => 'Bóveda privada';

  @override
  String get hide_movement => 'Ocultar (Privado)';

  @override
  String get restore_movement => 'Restaurar movimiento';

  @override
  String get add_transaction_fab => 'Agregar movimiento';

  @override
  String get categories => 'Categorías';

  @override
  String get cloud_backup_title => 'Respaldo en la Nube (PRO)';

  @override
  String get backup_now_label => 'Respaldar Ahora';

  @override
  String get restore_backup_label => 'Restaurar Respaldo';

  @override
  String get auto_backup_label => 'Respaldo Automático';

  @override
  String get auto_backup_desc => 'Respaldar tras cada nuevo registro';

  @override
  String get starting_backup_msg => 'Iniciando respaldo...';

  @override
  String get backup_success_msg => '¡Respaldo exitoso!';

  @override
  String get restoring_backup_msg => 'Restaurando respaldo...';

  @override
  String get restore_success_msg => '¡Restauración exitosa!';

  @override
  String get wrong_pin => 'PIN incorrecto';

  @override
  String get vault_locked => 'Bóveda Bloqueada';

  @override
  String get app_locked => 'App Bloqueada';

  @override
  String get splash_slogan => 'Tu dinero, simplificado';

  @override
  String get account_premium => 'Cuenta Premium';

  @override
  String get account_free => 'Cuenta Gratuita';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get ai_intelligence => 'Inteligencia Artificial';

  @override
  String get vault_label => 'Bóveda';

  @override
  String get estimated_spending => 'Gasto estimado';

  @override
  String get estimated_balance => 'Balance estimado';

  @override
  String get prediction_negative_warning =>
      '¡Peligro: Se predice un balance negativo!';

  @override
  String get recent_movements => 'Movimientos recientes';

  @override
  String get save_debt => 'Guardar deuda';

  @override
  String get complete_name_and_amount => 'Por favor, completa nombre y monto';

  @override
  String get no_debts_empty => 'Sin deudas';

  @override
  String get no_debts_subtitle => 'Agrega tu primera deuda para comenzar';

  @override
  String get add_first_debt => 'Agregar primera deuda';

  @override
  String payment_amount_for(Object name) {
    return 'Monto de pago para $name';
  }

  @override
  String get payment_amount_hint => 'Monto a pagar';

  @override
  String get confirm_payment => 'Confirmar pago';

  @override
  String get paid_label => 'Pagado';

  @override
  String get delete_debt_title => '¿Eliminar deuda?';

  @override
  String get choose_strategy => 'Elige estrategia';

  @override
  String get avalanche_strategy => 'Avalancha (Mayor interés primero)';

  @override
  String get snowball_strategy => 'Bola de nieve (Menor balance primero)';

  @override
  String get installments_label => 'Número de cuotas';

  @override
  String get installments_hint => 'Ej: 12';

  @override
  String get category_section_label => 'Categoría';

  @override
  String get note_hint => 'Añadir nota...';
}
