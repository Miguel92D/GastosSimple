package com.example.gastos_simple

import com.example.gastos_simple.R

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class QuickEntryWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: android.content.SharedPreferences) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            // Intent for Ingreso
            val intentIngreso = Intent(context, MainActivity::class.java).apply {
                data = Uri.parse("gastossimple://quick_entry?type=ingreso")
                action = "QUICK_ENTRY_INGRESO"
            }
            val pendingIntentIngreso = PendingIntent.getActivity(context, 0, intentIngreso, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            views.setOnClickPendingIntent(R.id.btn_ingreso, pendingIntentIngreso)

            // Intent for Gasto
            val intentGasto = Intent(context, MainActivity::class.java).apply {
                data = Uri.parse("gastossimple://quick_entry?type=gasto")
                action = "QUICK_ENTRY_GASTO"
            }
            val pendingIntentGasto = PendingIntent.getActivity(context, 1, intentGasto, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            views.setOnClickPendingIntent(R.id.btn_gasto, pendingIntentGasto)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
