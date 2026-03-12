import json
import os

def fix_arb(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # 1. Add missing strings
    new_keys = {
        "estimated_spending": "Estimated spending" if "en" in filepath else "Gasto estimado",
        "estimated_balance": "Estimated balance" if "en" in filepath else "Balance estimado",
        "prediction_negative_warning": "Warning: Negative balance predicted!" if "en" in filepath else "¡Peligro: Se predice un balance negativo!",
        "recent_movements": "Recent movements" if "en" in filepath else "Movimientos recientes",
        "save_debt": "Save debt" if "en" in filepath else "Guardar deuda",
        "complete_name_and_amount": "Please enter name and amount" if "en" in filepath else "Por favor, completa nombre y monto",
        "no_debts_empty": "No debts yet" if "en" in filepath else "Sin deudas",
        "no_debts_subtitle": "Add your first debt to start tracking" if "en" in filepath else "Agrega tu primera deuda para comenzar",
        "add_first_debt": "Add first debt" if "en" in filepath else "Agregar primera deuda",
        "payment_amount_for": "Payment amount for {name}" if "en" in filepath else "Monto de pago para {name}",
        "payment_amount_hint": "Amount to pay" if "en" in filepath else "Monto a pagar",
        "confirm_payment": "Confirm payment" if "en" in filepath else "Confirmar pago",
        "paid_label": "Paid" if "en" in filepath else "Pagado",
        "delete_debt_title": "Delete debt?" if "en" in filepath else "¿Eliminar deuda?",
        "choose_strategy": "Choose strategy" if "en" in filepath else "Elige estrategia",
        "avalanche_strategy": "Avalanche (Highest interest first)" if "en" in filepath else "Avalancha (Mayor interés primero)",
        "snowball_strategy": "Snowball (Lowest balance first)" if "en" in filepath else "Bola de nieve (Menor balance primero)",
        "category_section_label": "Category" if "en" in filepath else "Categoría",
        "note_hint": "Add a note..." if "en" in filepath else "Añadir nota..."
    }

    for k, v in new_keys.items():
        if k not in data:
            data[k] = v

    # 2. Add metadata for all templates
    metadata = {
        "@days_count": {"placeholders": {"count": {}}},
        "@closing_day": {"placeholders": {"day": {}}},
        "@priority_tip": {"placeholders": {"name": {}, "rate": {}}},
        "@extra_payment_tip": {"placeholders": {"amount": {}, "name": {}, "months": {}}},
        "@snowball_method": {"placeholders": {"name": {}}},
        "@interest_annual": {"placeholders": {"rate": {}}},
        "@remaining_amount": {"placeholders": {"amount": {}}},
        "@min_pay_amount": {"placeholders": {"amount": {}}},
        "@budget_title": {"placeholders": {"category": {}}},
        "@top_category_insight": {"placeholders": {"category": {}}},
        "@payment_amount_for": {"placeholders": {"name": {}}}
    }

    for k, v in metadata.items():
        data[k] = v

    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

fix_arb('lib/l10n/app_en.arb')
fix_arb('lib/l10n/app_es.arb')
