package com.relink.re_link

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject

class ReLinkWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val PREFS_NAME = "HomeWidgetPreferences"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val views = RemoteViews(context.packageName, R.layout.widget_relink)

        // ── Launch app on click ──────────────────────────────────────────
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            launchIntent ?: Intent(),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

        // ── Anniversary Section ──────────────────────────────────────────
        val anniversaryCount = prefs.getInt("anniversary_count", 0)
        val nextName = prefs.getString("anniversary_next_name", null)
        val nextDays = prefs.getInt("anniversary_next_days", -1)

        if (anniversaryCount > 0 && nextName != null && nextDays >= 0) {
            views.setViewVisibility(R.id.anniversary_section, View.VISIBLE)
            views.setViewVisibility(R.id.anniversary_empty, View.GONE)

            if (nextDays == 0) {
                views.setTextViewText(R.id.anniversary_dday, "D-DAY")
                views.setTextViewText(
                    R.id.anniversary_name,
                    "${nextName}님 생일 축하해요!"
                )
            } else {
                views.setTextViewText(R.id.anniversary_dday, "D-${nextDays}")
                views.setTextViewText(
                    R.id.anniversary_name,
                    "${nextName}님의 생일"
                )
            }

            // Parse anniversary list for additional info
            val listJson = prefs.getString("anniversary_list", null)
            if (listJson != null) {
                try {
                    val arr = JSONArray(listJson)
                    if (arr.length() > 0) {
                        val first = arr.getJSONObject(0)
                        val turningAge = first.optInt("turningAge", 0)
                        val date = first.optString("date", "")
                        if (turningAge > 0) {
                            views.setTextViewText(
                                R.id.anniversary_detail,
                                "${date} (${turningAge}세)"
                            )
                        } else {
                            views.setTextViewText(R.id.anniversary_detail, date)
                        }
                    }
                } catch (e: Exception) {
                    views.setTextViewText(R.id.anniversary_detail, "")
                }
            }

            // Show count badge if more than 1
            if (anniversaryCount > 1) {
                views.setViewVisibility(R.id.anniversary_more, View.VISIBLE)
                views.setTextViewText(
                    R.id.anniversary_more,
                    "+${anniversaryCount - 1}건 더"
                )
            } else {
                views.setViewVisibility(R.id.anniversary_more, View.GONE)
            }
        } else {
            views.setViewVisibility(R.id.anniversary_section, View.GONE)
            views.setViewVisibility(R.id.anniversary_empty, View.VISIBLE)
            views.setTextViewText(R.id.anniversary_empty, "다가오는 기념일이 없어요")
        }

        // ── Today's Memory Section ───────────────────────────────────────
        val memoryExists = prefs.getBoolean("today_memory_exists", false)

        if (memoryExists) {
            views.setViewVisibility(R.id.memory_section, View.VISIBLE)
            views.setViewVisibility(R.id.memory_empty, View.GONE)

            val memoryTitle = prefs.getString("today_memory_title", "오늘의 기억") ?: "오늘의 기억"
            val memoryNode = prefs.getString("today_memory_node", "") ?: ""
            val memoryYears = prefs.getInt("today_memory_years", 0)
            val memoryType = prefs.getString("today_memory_type", "memo") ?: "memo"
            val memoryCount = prefs.getInt("today_memory_count", 1)

            val typeEmoji = when (memoryType) {
                "photo" -> "\uD83D\uDCF7"
                "voice" -> "\uD83C\uDFA4"
                "memo" -> "\uD83D\uDCDD"
                else -> "\uD83D\uDCDD"
            }

            views.setTextViewText(R.id.memory_title, "$typeEmoji $memoryTitle")

            val subtitle = buildString {
                if (memoryNode.isNotEmpty()) {
                    append(memoryNode)
                }
                if (memoryYears > 0) {
                    if (isNotEmpty()) append(" \u00B7 ")
                    append("${memoryYears}년 전 오늘")
                }
            }
            views.setTextViewText(R.id.memory_subtitle, subtitle)

            if (memoryCount > 1) {
                views.setViewVisibility(R.id.memory_count, View.VISIBLE)
                views.setTextViewText(R.id.memory_count, "+${memoryCount - 1}")
            } else {
                views.setViewVisibility(R.id.memory_count, View.GONE)
            }
        } else {
            views.setViewVisibility(R.id.memory_section, View.GONE)
            views.setViewVisibility(R.id.memory_empty, View.VISIBLE)
            views.setTextViewText(R.id.memory_empty, "오늘의 기억이 없어요")
        }

        // ── Family Stats Section ─────────────────────────────────────────
        val nodeCount = prefs.getInt("family_node_count", 0)
        val memCount = prefs.getInt("family_memory_count", 0)

        views.setTextViewText(R.id.stat_node_count, "$nodeCount")
        views.setTextViewText(R.id.stat_memory_count, "$memCount")

        // ── Update widget ────────────────────────────────────────────────
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
