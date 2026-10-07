package com.example.flash;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.util.Log;
import android.view.View;
import android.widget.RemoteViews;

import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Widget vuông bo góc: một thẻ flashcard mỗi lần, chạm thẻ để lật, nút ‹ › để đổi từ.
 * Dữ liệu (JSON "cards" và các nhãn) do Dart ghi vào "HomeWidgetPreferences". Native chỉ quản lý
 * trạng thái hiển thị của chính widget (w_index, w_flipped), không ghi gì vào DB của app.
 */
public class FlashWidgetProvider extends AppWidgetProvider {
    private static final String TAG = "FlashWidget";
    // Tên SharedPreferences mà gói home_widget dùng để lưu dữ liệu từ Dart.
    private static final String PREFS = "HomeWidgetPreferences";
    // Action gói home_widget dùng để nhận biết "app được mở từ widget".
    private static final String LAUNCH_ACTION = "es.antonborri.home_widget.action.LAUNCH";
    private static final String ACTION_PREV = "com.example.flash.widget.PREV";
    private static final String ACTION_NEXT = "com.example.flash.widget.NEXT";
    private static final String ACTION_FLIP = "com.example.flash.widget.FLIP";
    private static final String KEY_INDEX = "w_index";
    private static final String KEY_FLIPPED = "w_flipped";
    // Mã băm của chuỗi "cards" lần vẽ trước, để nhận ra Dart vừa gửi danh sách mới.
    private static final String KEY_CARDS_HASH = "w_cards_hash";

    /** Hệ thống hoặc Dart (updateWidget) yêu cầu vẽ lại. */
    @Override
    public void onUpdate(Context context, AppWidgetManager manager, int[] ids) {
        RemoteViews views;
        try {
            views = buildViews(context);
        } catch (Exception e) {
            Log.e(TAG, "buildViews", e);
            return;
        }
        for (int id : ids) {
            try {
                manager.updateAppWidget(id, views);
            } catch (Exception e) {
                Log.e(TAG, "updateAppWidget", e);
            }
        }
    }

    /** Nhận broadcast của hệ thống và ba nút của widget (‹, ›, chạm thẻ). */
    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        String action = intent.getAction();
        if (!ACTION_PREV.equals(action) && !ACTION_NEXT.equals(action) && !ACTION_FLIP.equals(action)) return;
        try {
            SharedPreferences p = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
            int n = cards(p).length();
            if (ACTION_FLIP.equals(action)) {
                p.edit().putBoolean(KEY_FLIPPED, !p.getBoolean(KEY_FLIPPED, false)).apply();
            } else if (n > 0) {
                int step = ACTION_NEXT.equals(action) ? 1 : -1;
                int next = ((p.getInt(KEY_INDEX, 0) + step) % n + n) % n; // quay vòng hai đầu
                p.edit().putInt(KEY_INDEX, next).putBoolean(KEY_FLIPPED, false).apply();
            }

            AppWidgetManager m = AppWidgetManager.getInstance(context);
            onUpdate(context, m, m.getAppWidgetIds(new ComponentName(context, FlashWidgetProvider.class)));
        } catch (Exception e) {
            Log.e(TAG, "onReceive " + action, e);
        }
    }

    private static RemoteViews buildViews(Context context) {
        SharedPreferences p = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
        boolean enabled = !"0".equals(p.getString("w_enabled", "1"));
        RemoteViews v = new RemoteViews(context.getPackageName(), R.layout.flash_widget);
        JSONArray list = cards(p);
        int n = list.length();

        // Dart vừa gửi danh sách mới → kẹp vị trí vào phạm vi hợp lệ và úp thẻ.
        int hash = p.getString("cards", "[]").hashCode();
        if (hash != p.getInt(KEY_CARDS_HASH, 0)) {
            int clamped = Math.max(0, Math.min(p.getInt(KEY_INDEX, 0), n - 1));
            p.edit().putInt(KEY_CARDS_HASH, hash).putInt(KEY_INDEX, clamped).putBoolean(KEY_FLIPPED, false).apply();
        }

        v.setTextViewText(R.id.widget_count, enabled ? p.getString("w_count_label", "") : "");

        if (!enabled || n == 0) {
            // Tắt / không có từ: chỉ hiện thông báo, ẩn thẻ và thanh dưới.
            v.setViewVisibility(R.id.card_front, View.GONE);
            v.setViewVisibility(R.id.card_back, View.GONE);
            v.setViewVisibility(R.id.widget_bar, View.GONE);
            v.setViewVisibility(R.id.widget_empty, View.VISIBLE);
            v.setTextViewText(R.id.widget_empty, p.getString("w_empty", ""));
            // Widget đang tắt → mở thẳng màn cấu hình; không có từ → chỉ mở app.
            PendingIntent open = openApp(context, enabled ? "flashwidget://study" : "flashwidget://settings/widget");
            v.setOnClickPendingIntent(R.id.widget_header, open);
            v.setOnClickPendingIntent(R.id.widget_empty, open);
            return v;
        }

        int index = p.getInt(KEY_INDEX, 0) % n;
        boolean flipped = p.getBoolean(KEY_FLIPPED, false);
        JSONObject c = list.optJSONObject(index);
        if (c == null) c = new JSONObject();

        v.setViewVisibility(R.id.widget_empty, View.GONE);
        v.setViewVisibility(R.id.widget_bar, View.VISIBLE);
        v.setViewVisibility(R.id.card_front, flipped ? View.GONE : View.VISIBLE);
        v.setViewVisibility(R.id.card_back, flipped ? View.VISIBLE : View.GONE);

        v.setTextViewText(R.id.front_word, c.optString("word"));
        v.setTextViewText(R.id.front_hint, p.getString("w_tap_hint", ""));
        v.setTextViewText(R.id.back_word, c.optString("word"));
        String pos = c.optString("partOfSpeech");
        v.setTextViewText(R.id.back_pos, pos);
        v.setViewVisibility(R.id.back_pos, pos.isEmpty() ? View.GONE : View.VISIBLE);
        v.setTextViewText(R.id.back_pronunciation, c.optString("pronunciation"));
        v.setTextViewText(R.id.back_meaning, c.optString("meaning"));
        v.setTextViewText(R.id.widget_pos, (index + 1) + "/" + n);

        PendingIntent flip = selfAction(context, ACTION_FLIP, 1);
        v.setOnClickPendingIntent(R.id.card_front, flip);
        v.setOnClickPendingIntent(R.id.card_back, flip);
        v.setOnClickPendingIntent(R.id.widget_prev, selfAction(context, ACTION_PREV, 2));
        v.setOnClickPendingIntent(R.id.widget_next, selfAction(context, ACTION_NEXT, 3));
        v.setOnClickPendingIntent(R.id.widget_header, openApp(context,
                "flashwidget://study?topic=" + Uri.encode(c.optString("topicId"))
                        + "&title=" + Uri.encode(c.optString("topicTitle"))));
        return v;
    }

    /** Đọc JSON "cards"; lỗi thì trả danh sách rỗng. */
    private static JSONArray cards(SharedPreferences p) {
        try {
            return new JSONArray(p.getString("cards", "[]"));
        } catch (Exception e) {
            Log.e(TAG, "parse cards", e);
            return new JSONArray();
        }
    }

    /** Broadcast gửi ngược về chính lớp này; mỗi action một requestCode để không ghi đè nhau. */
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
