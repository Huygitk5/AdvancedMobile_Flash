package com.example.flash;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.view.View;
import android.widget.RemoteViews;

import org.json.JSONArray;
import org.json.JSONObject;

public class FlashWidgetProvider extends AppWidgetProvider {
    private static final String ACTION_NEXT = "com.example.flash.widget.NEXT";
    private static final String ACTION_FLIP = "com.example.flash.widget.FLIP";
    // Tên SharedPreferences mà gói home_widget dùng để lưu dữ liệu từ Dart.
    private static final String PREFS = "HomeWidgetPreferences";
    // Action gói home_widget dùng để nhận biết "app được mở từ widget".
    private static final String LAUNCH_ACTION = "es.antonborri.home_widget.action.LAUNCH";

    /** Hệ thống hoặc Dart (updateWidget) yêu cầu vẽ lại. */
    @Override
    public void onUpdate(Context context, AppWidgetManager manager, int[] ids) {
        for (int id : ids) {
            manager.updateAppWidget(id, buildViews(context));
        }
    }

    /** Nhận cả broadcast của hệ thống lẫn hai nút của ta. */
    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        String action = intent.getAction();
        if (!ACTION_NEXT.equals(action) && !ACTION_FLIP.equals(action)) return;

        SharedPreferences p = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
        int count = cards(p).length();
        if (ACTION_NEXT.equals(action) && count > 0) {
            int next = (p.getInt("w_index", 0) + 1) % count;
            p.edit().putInt("w_index", next).putBoolean("w_flipped", false).apply();
        } else if (ACTION_FLIP.equals(action)) {
            p.edit().putBoolean("w_flipped", !p.getBoolean("w_flipped", false)).apply();
        }

        AppWidgetManager m = AppWidgetManager.getInstance(context);
        onUpdate(context, m, m.getAppWidgetIds(new ComponentName(context, FlashWidgetProvider.class)));
    }

    private static RemoteViews buildViews(Context context) {
        SharedPreferences p = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
        RemoteViews v = new RemoteViews(context.getPackageName(), R.layout.flash_widget);
        JSONArray list = cards(p);

        if (list.length() == 0) {
            v.setTextViewText(R.id.widget_count, "");
            v.setTextViewText(R.id.widget_word, p.getString("w_empty_title", "Không có thẻ cần ôn"));
            v.setTextViewText(R.id.widget_hint, p.getString("w_empty_hint", ""));
            v.setViewVisibility(R.id.widget_meaning, View.GONE);
            v.setViewVisibility(R.id.widget_next, View.GONE);
            PendingIntent open = openApp(context, "flashwidget://study");
            v.setOnClickPendingIntent(R.id.widget_header, open);
            v.setOnClickPendingIntent(R.id.widget_card, open);
            return v;
        }

        // Dart có thể gửi danh sách ngắn hơn trước → lấy phần dư để chỉ số luôn hợp lệ.
        int index = p.getInt("w_index", 0) % list.length();
        boolean flipped = p.getBoolean("w_flipped", false);
        JSONObject c = list.optJSONObject(index);

        v.setTextViewText(R.id.widget_count, p.getString("w_count_label", ""));
        v.setTextViewText(R.id.widget_word, c.optString("word"));
        v.setTextViewText(R.id.widget_hint,
                flipped ? c.optString("pronunciation") : p.getString("w_tap_hint", ""));
        v.setTextViewText(R.id.widget_meaning, c.optString("meaning"));
        v.setViewVisibility(R.id.widget_meaning, flipped ? View.VISIBLE : View.GONE);
        v.setViewVisibility(R.id.widget_next, View.VISIBLE);

        v.setOnClickPendingIntent(R.id.widget_card, selfAction(context, ACTION_FLIP, 1));
        v.setOnClickPendingIntent(R.id.widget_next, selfAction(context, ACTION_NEXT, 2));
        v.setOnClickPendingIntent(R.id.widget_header, openApp(context,
                "flashwidget://study?topic=" + Uri.encode(c.optString("topicId"))
                        + "&title=" + Uri.encode(c.optString("topicTitle"))));
        return v;
    }

    private static JSONArray cards(SharedPreferences p) {
        try {
            return new JSONArray(p.getString("cards", "[]"));
        } catch (Exception e) {
            return new JSONArray();
        }
    }

    /** Broadcast gửi ngược về chính lớp này (nút → và chạm để lật). */
    private static PendingIntent selfAction(Context context, String action, int requestCode) {
        Intent i = new Intent(context, FlashWidgetProvider.class).setAction(action);
        return PendingIntent.getBroadcast(context, requestCode, i,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
    }

    /** Mở MainActivity kèm đường dẫn; home_widget chuyển đường dẫn này sang Dart. */
    private static PendingIntent openApp(Context context, String uri) {
        Intent i = new Intent(context, MainActivity.class)
                .setAction(LAUNCH_ACTION)
                .setData(Uri.parse(uri));
        return PendingIntent.getActivity(context, 0, i,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
    }
}
