const fs = require('fs');

function fixArb(filepath) {
    let data = JSON.parse(fs.readFileSync(filepath, 'utf8'));

    const isEn = filepath.includes('en.arb');

    const newKeys = {
        "estimated_spending": isEn ? "Estimated spending" : "Gasto estimado",
        "estimated_balance": isEn ? "Estimated balance" : "Balance estimado",
        "prediction_negative_warning": isEn ? "Warning: Negative balance predicted!" : "¡Peligro: Se predice un balance negativo!",
        "recent_movements": isEn ? "Recent movements" : "Movimientos recientes",
        "save_debt": isEn ? "Save debt" : "Guardar deuda",
        "complete_name_and_amount": isEn ? "Please enter name and amount" : "Por favor, completa nombre y monto",
        "no_debts_empty": isEn ? "No debts yet" : "Sin deudas",
        "no_debts_subtitle": isEn ? "Add your first debt to start tracking" : "Agrega tu primera deuda para comenzar",
        "add_first_debt": isEn ? "Add first debt" : "Agregar primera deuda",
        "payment_amount_for": isEn ? "Payment amount for {name}" : "Monto de pago para {name}",
        "payment_amount_hint": isEn ? "Amount to pay" : "Monto a pagar",
        "confirm_payment": isEn ? "Confirm payment" : "Confirmar pago",
        "paid_label": isEn ? "Paid" : "Pagado",
        "delete_debt_title": isEn ? "Delete debt?" : "¿Eliminar deuda?",
        "choose_strategy": isEn ? "Choose strategy" : "Elige estrategia",
        "avalanche_strategy": isEn ? "Avalanche (Highest interest first)" : "Avalancha (Mayor interés primero)",
        "snowball_strategy": isEn ? "Snowball (Lowest balance first)" : "Bola de nieve (Menor balance primero)",
        "category_section_label": isEn ? "Category" : "Categoría",
        "note_hint": isEn ? "Add a note..." : "Añadir nota..."
    };

    for (const k in newKeys) {
        if (!(k in data)) {
            data[k] = newKeys[k];
        }
    }

    const metadata = {
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
    };

    for (const k in metadata) {
        data[k] = metadata[k];
    }

    fs.writeFileSync(filepath, JSON.stringify(data, null, 2), 'utf8');
}

fixArb('lib/l10n/app_en.arb');
fixArb('lib/l10n/app_es.arb');
