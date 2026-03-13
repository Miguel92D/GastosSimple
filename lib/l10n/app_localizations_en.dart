// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => '\$imple';

  @override
  String get home => 'Home';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get balance => 'Balance';

  @override
  String get settings => 'Settings';

  @override
  String get quick_entry_question => 'What would you like to record today?';

  @override
  String get history => 'History';

  @override
  String get history_analytics => '📊 History / Analytics';

  @override
  String get get_pro => '🚀 Get PRO';

  @override
  String get pro_active => 'PRO active';

  @override
  String get simple_pro => '\$imple PRO';

  @override
  String get unlock_advanced_tools => 'Unlock advanced financial tools.';

  @override
  String get benefit_strategies => 'Smart debt exit strategies';

  @override
  String get benefit_predictions => 'Monthly spending predictions';

  @override
  String get benefit_analytics => 'Advanced financial analytics';

  @override
  String get benefit_future => 'Future improvements';

  @override
  String get smart_insights => 'Smart financial insights';

  @override
  String get activate_pro => 'Activate PRO';

  @override
  String get restore_purchase => 'Restore purchase';

  @override
  String get monthly_plan => 'Monthly Plan';

  @override
  String get lifetime_plan => 'Lifetime Plan';

  @override
  String get monthly_price => '\$2.99 / month';

  @override
  String get lifetime_price => '\$19.99 one-time';

  @override
  String get pro_tools => '⭐ PRO Tools';

  @override
  String get spending_predictions => 'Spending predictions';

  @override
  String get advanced_analytics => 'Advanced analytics';

  @override
  String get movements => 'Movements';

  @override
  String get budgets => 'Budgets';

  @override
  String get goals => 'Goals';

  @override
  String get debts => 'Debts';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get currency => 'Currency';

  @override
  String get current_balance => 'Current balance';

  @override
  String get monthly_total => 'Monthly total';

  @override
  String get monthly_balance => 'Monthly balance';

  @override
  String get category_expenses => 'Category expenses';

  @override
  String get no_expenses_recorded => 'No expenses recorded this month.';

  @override
  String get add_movement => 'Add movement';

  @override
  String get edit_movement => 'Edit movement';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get date => 'Date';

  @override
  String get description => 'Description';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm_delete => 'Are you sure you want to delete this movement?';

  @override
  String get all_categories => 'All categories';

  @override
  String get transport => 'Transport';

  @override
  String get food => 'Food';

  @override
  String get services => 'Services';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get health => 'Health';

  @override
  String get education => 'Education';

  @override
  String get other => 'Other';

  @override
  String get financial_control_drawer => 'Financial Control';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get premium => 'Premium';

  @override
  String get light_mode => 'Light';

  @override
  String get dark_mode => 'Dark';

  @override
  String get financial_health => 'Financial health';

  @override
  String get based_on_month => 'Based on this month\'s stats';

  @override
  String get insights => 'Insights';

  @override
  String get racha => 'Streak';

  @override
  String get prediction => 'Prediction';

  @override
  String days_count(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get prediction_warning => 'Warning: High spending this month';

  @override
  String get no_today_movements => 'No movements recorded today.';

  @override
  String get unlock_unlimited => 'Unlock unlimited movements and more.';

  @override
  String get view_plans => 'View Plans';

  @override
  String get debt_exit_plan => 'Debt exit plan';

  @override
  String get extra_monthly_amount => 'Extra monthly amount for debt';

  @override
  String get join_premium => 'Join Premium';

  @override
  String get premium_description =>
      'Enhance your financial experience with these features:';

  @override
  String get feature_stats => 'Advanced statistics';

  @override
  String get feature_budgets => 'Flexible budgets';

  @override
  String get feature_export => 'Data export';

  @override
  String get feature_vault => 'Personal vault';

  @override
  String get feature_recurring => 'Recurring movements';

  @override
  String get feature_history => 'Detailed history';

  @override
  String get subscribe_now => 'Subscribe now';

  @override
  String get already_premium => 'You are Premium';

  @override
  String get premium_test_unlocked => 'Premium unlocked for testing!';

  @override
  String get credit_card_closing_day => 'Credit card closing (day of month)';

  @override
  String closing_day(Object day) {
    return 'Closing day: $day';
  }

  @override
  String get closing_day_validation => 'Please enter a value between 1 and 31';

  @override
  String get interest_rate_title => 'Interest Rate';

  @override
  String get interest_rate_desc =>
      'It is the percentage that the bank charges for financing your card balance. The higher it is, the faster the debt will grow if you pay only the minimum.';

  @override
  String get card_closing_title => 'Card Closing';

  @override
  String get card_closing_desc =>
      'It is the day on which the bank calculates all the expenses of your card to generate the summary of the month.';

  @override
  String get due_date_title => 'Due Date';

  @override
  String get due_date_desc =>
      'It\'s the last day to pay your card without generating interest or surcharges.';

  @override
  String get cat_food => 'Food';

  @override
  String get cat_transport => 'Transport';

  @override
  String get cat_leisure => 'Leisure';

  @override
  String get cat_health => 'Health';

  @override
  String get cat_education => 'Education';

  @override
  String get cat_others => 'Others';

  @override
  String get cat_salary => 'Salary';

  @override
  String get cat_sale => 'Sale';

  @override
  String get cat_gift => 'Gift';

  @override
  String get cat_investment => 'Investment';

  @override
  String get amount_error => 'Invalid amount';

  @override
  String get new_goal => 'New goal';

  @override
  String get edit_goal => 'Edit goal';

  @override
  String get goal_name_label => 'Goal name';

  @override
  String get target_label => 'Target amount';

  @override
  String get savings_goals => 'Savings goals';

  @override
  String get no_goals_yet => 'No goals recorded yet.';

  @override
  String get spending_warning => 'Watch your spending!';

  @override
  String get good_income_insight => 'Good level of income this month!';

  @override
  String get no_data_export => 'No data to export.';

  @override
  String get export_subject => 'My Finances - Gastos Simple';

  @override
  String get search => 'Search';

  @override
  String get search_tooltip => 'Search movements';

  @override
  String get export_data => 'Export data';

  @override
  String get no_debts_recorded => 'No debts recorded.';

  @override
  String get amount_to_pay => 'Amount to pay';

  @override
  String get pay => 'Pay';

  @override
  String priority_tip(Object name, Object rate) {
    return 'Priority: Pay $name ($rate%) to save on interest.';
  }

  @override
  String extra_payment_tip(Object amount, Object name, Object months) {
    return 'With $amount extra, you will pay off $name in $months months.';
  }

  @override
  String snowball_method(Object name) {
    return 'Snowball method: Focus on $name.';
  }

  @override
  String get new_debt => 'New debt';

  @override
  String get edit_debt => 'Edit debt';

  @override
  String get debt_name_label => 'Debt name';

  @override
  String get total_amount => 'Total amount';

  @override
  String get min_payment => 'Minimum payment';

  @override
  String get interest_rate_optional => 'Interest Rate % (optional)';

  @override
  String get card_closing_label => 'Card closing (day of month)';

  @override
  String get due_day_label => 'Due day (e.g. 15)';

  @override
  String interest_annual(Object rate) {
    return 'Interest: $rate% annual';
  }

  @override
  String get vence_dia => 'Due day: ';

  @override
  String get cierre_dia => 'Closes: ';

  @override
  String remaining_amount(Object amount) {
    return 'Left: $amount';
  }

  @override
  String min_pay_amount(Object amount) {
    return 'Min: $amount';
  }

  @override
  String get archived => 'Archived';

  @override
  String get assign_to_goal => 'Assign to goal';

  @override
  String get biometric_subtitle => 'Use your fingerprint or face';

  @override
  String get biometric_unlock => 'Biometric unlock';

  @override
  String get budget_example => 'Example: Food (Max 500)';

  @override
  String get change_pin => 'Change PIN';

  @override
  String get closing_day_error => 'Closing day must be between 1 and 31';

  @override
  String get daily => 'Daily';

  @override
  String get enable_pin => 'Enable PIN';

  @override
  String get expense_history => 'Expense history';

  @override
  String get income_history => 'Income history';

  @override
  String get legal => 'Legal';

  @override
  String get no_archived_movements => 'No archived movements.';

  @override
  String get no_movements_recorded => 'No movements recorded.';

  @override
  String get not_set => 'Not set';

  @override
  String get note => 'Note';

  @override
  String get pin_subtitle => 'Protect your data with a code';

  @override
  String get privacy_policy => 'Privacy Policy';

  @override
  String get select_goal => 'Select goal';

  @override
  String get set_pin => 'Set PIN';

  @override
  String get enter_pin => 'Enter your PIN';

  @override
  String get security => 'Security';

  @override
  String get new_pin_label => 'New PIN';

  @override
  String get vault_only_pin => 'Vault Only PIN';

  @override
  String get vault_only_pin_desc =>
      'App opens normally, but the vault will require PIN';

  @override
  String get new_movement => 'New movement';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get recurring => 'Recurring';

  @override
  String get frequency => 'Frequency';

  @override
  String get amount_to_assign => 'Amount to assign';

  @override
  String budget_title(Object category) {
    return 'Budget: $category';
  }

  @override
  String top_category_insight(Object category) {
    return 'Highest expense in $category';
  }

  @override
  String get private_movements => 'Private Vault';

  @override
  String get no_private_movements => 'No private movements saved.';

  @override
  String get secret_expenses => 'Private Vault';

  @override
  String get hide_movement => 'Hide (Private)';

  @override
  String get restore_movement => 'Restore movement';

  @override
  String get add_transaction_fab => 'Add movement';

  @override
  String get categories => 'Categories';

  @override
  String get cloud_backup_title => 'Cloud Backup (PRO)';

  @override
  String get backup_now_label => 'Backup Now';

  @override
  String get restore_backup_label => 'Restore Backup';

  @override
  String get auto_backup_label => 'Automatic Backup';

  @override
  String get auto_backup_desc => 'Backup after every new record';

  @override
  String get starting_backup_msg => 'Starting backup...';

  @override
  String get backup_success_msg => 'Backup successful!';

  @override
  String get restoring_backup_msg => 'Restoring backup...';

  @override
  String get restore_success_msg => 'Restoration successful!';

  @override
  String get wrong_pin => 'Wrong PIN';

  @override
  String get vault_locked => 'Vault Locked';

  @override
  String get app_locked => 'App Locked';

  @override
  String get splash_slogan => 'Your money, simplified';

  @override
  String get account_premium => 'Premium Account';

  @override
  String get account_free => 'Free Account';

  @override
  String get statistics => 'Statistics';

  @override
  String get ai_intelligence => 'AI Intelligence';

  @override
  String get vault_label => 'Vault';

  @override
  String get estimated_spending => 'Estimated spending';

  @override
  String get estimated_balance => 'Estimated balance';

  @override
  String get prediction_negative_warning =>
      'Warning: Negative balance predicted!';

  @override
  String get recent_movements => 'Recent movements';

  @override
  String get save_debt => 'Save debt';

  @override
  String get complete_name_and_amount => 'Please enter name and amount';

  @override
  String get no_debts_empty => 'No debts yet';

  @override
  String get no_debts_subtitle => 'Add your first debt to start tracking';

  @override
  String get add_first_debt => 'Add first debt';

  @override
  String payment_amount_for(Object name) {
    return 'Payment amount for $name';
  }

  @override
  String get payment_amount_hint => 'Amount to pay';

  @override
  String get confirm_payment => 'Confirm payment';

  @override
  String get paid_label => 'Paid';

  @override
  String get delete_debt_title => 'Delete debt?';

  @override
  String get choose_strategy => 'Choose strategy';

  @override
  String get avalanche_strategy => 'Avalanche (Highest interest first)';

  @override
  String get snowball_strategy => 'Snowball (Lowest balance first)';

  @override
  String get installments_label => 'Installments';

  @override
  String get installments_hint => 'e.g. 12';

  @override
  String get category_section_label => 'Category';

  @override
  String get note_hint => 'Add a note...';
}
