package com.migueld.gastossimple

import com.migueld.gastossimple.R

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews

class QuickEntryWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            // Intent para Ingreso
            val pendingIntentIngreso = createPendingIntent(context, "ingreso")
            views.setOnClickPendingIntent(R.id.btn_ingreso, pendingIntentIngreso)

            // Intent para Gasto
            val pendingIntentGasto = createPendingIntent(context, "gasto")
            views.setOnClickPendingIntent(R.id.btn_gasto, pendingIntentGasto)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun createPendingIntent(context: Context, type: String): PendingIntent {
        val intent = Intent(Intent.ACTION_VIEW).apply {
            data = Uri.parse("gastossimple://quick_entry?type=$type")
            `package` = context.packageName
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        return PendingIntent.getActivity(
            context,
            if (type == "ingreso") 1 else 2,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
}
