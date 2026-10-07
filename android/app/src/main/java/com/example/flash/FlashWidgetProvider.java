package com.example.flash;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Build;
import android.util.Log;
import android.view.View;
import android.widget.RemoteViews;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/**
 * Widget vuông bo góc: header + một thẻ flashcard mỗi lần (StackView, vuốt lên/xuống để đổi từ).
 * Dữ liệu (JSON "cards" và các nhãn) do Dart ghi vào "HomeWidgetPreferences"; các thẻ do
 * {@link FlashWidgetService} / {@link FlashWidgetFactory} dựng. Chạm thẻ để lật (broadcast FLIP),
 * widget chỉ đổi trạng thái hiển thị của chính nó, không ghi gì vào DB của app.
 */
public class FlashWidgetProvider extends AppWidgetProvider {
    private static final String TAG = "FlashWidget";
    // Tên SharedPreferences mà gói home_widget dùng để lưu dữ liệu từ Dart.
    static final String PREFS = "HomeWidgetPreferences";
    // Action gói home_widget dùng để nhận biết "app được mở từ widget".
    private static final String LAUNCH_ACTION = "es.antonborri.home_widget.action.LAUNCH";
    private static final String ACTION_FLIP = "com.example.flash.widget.FLIP";
    static final String EXTRA_CARD_ID = "cardId";
    static final String EXTRA_POSITION = "position";
    // Trạng thái hiển thị do native quản lý: thẻ đang lật (String, Dart xóa khi gửi danh sách mới)
    // và vị trí thẻ vừa lật (int).
    static final String KEY_FLIPPED = "w_flipped_id";
    private static final String KEY_INDEX = "w_index";

    /** Hệ thống hoặc Dart (updateWidget) yêu cầu vẽ lại. */
    @Override
    public void onUpdate(Context context, AppWidgetManager manager, int[] ids) {
        for (int id : ids) {
            try {
                manager.updateAppWidget(id, buildViews(context, id));
            } catch (Exception e) {
                Log.e(TAG, "updateAppWidget", e);
            }
        }
        try {
            // Báo StackView đọc lại dữ liệu (FlashWidgetFactory.onDataSetChanged). AdapterViewAnimator
            // giữ nguyên thẻ đang hiện khi dữ liệu đổi, còn setDisplayedChild ở trên lo trường hợp
            // launcher dựng lại widget từ đầu.
            manager.notifyAppWidgetViewDataChanged(ids, R.id.widget_stack);
        } catch (Exception e) {
            Log.e(TAG, "notifyAppWidgetViewDataChanged", e);
        }
    }

    /** Nhận broadcast của hệ thống và broadcast FLIP khi chạm vào thẻ. */
    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        if (!ACTION_FLIP.equals(intent.getAction())) return;
        try {
            String cardId = intent.getStringExtra(EXTRA_CARD_ID);
            int position = intent.getIntExtra(EXTRA_POSITION, 0);
            if (cardId == null || cardId.isEmpty()) return;

            SharedPreferences p = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
            SharedPreferences.Editor e = p.edit().putInt(KEY_INDEX, position);
            if (cardId.equals(p.getString(KEY_FLIPPED, ""))) {
                e.remove(KEY_FLIPPED); // thẻ đang lật → úp lại
            } else {
                e.putString(KEY_FLIPPED, cardId);
            }
            e.commit(); // ghi xong mới vẽ lại, để factory đọc đúng trạng thái

            AppWidgetManager m = AppWidgetManager.getInstance(context);
            onUpdate(context, m, m.getAppWidgetIds(new ComponentName(context, FlashWidgetProvider.class)));
        } catch (Exception ex) {
            Log.e(TAG, "flip", ex);
        }
    }

    private static RemoteViews buildViews(Context context, int widgetId) {
        SharedPreferences p = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
        boolean enabled = !"0".equals(p.getString("w_enabled", "1"));
        List<JSONObject> cards = readCards(p);
        RemoteViews v = new RemoteViews(context.getPackageName(), R.layout.flash_widget);

        // Thẻ: mỗi widgetId một data URI riêng để hệ thống không dùng chung factory.
        Intent svc = new Intent(context, FlashWidgetService.class)
                .putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId);
        svc.setData(Uri.parse(svc.toUri(Intent.URI_INTENT_SCHEME)));
        v.setRemoteAdapter(R.id.widget_stack, svc);
        v.setEmptyView(R.id.widget_stack, R.id.widget_empty);

        // Dart gửi danh sách ngắn hơn trước → vị trí cũ không còn hợp lệ thì về thẻ đầu.
        int index = p.getInt(KEY_INDEX, 0);
        if (index < 0 || index >= cards.size()) {
            index = 0;
            p.edit().putInt(KEY_INDEX, 0).apply();
        }
        if (!cards.isEmpty()) v.setDisplayedChild(R.id.widget_stack, index);

        v.setTextViewText(R.id.widget_count, enabled ? p.getString("w_count_label", "") : "");
        v.setTextViewText(R.id.widget_empty, p.getString("w_empty", ""));
        // Gợi ý vuốt chỉ có ý nghĩa khi có từ 2 thẻ trở lên.
        v.setTextViewText(R.id.widget_footer, p.getString("w_swipe_hint", ""));
        v.setViewVisibility(R.id.widget_footer, enabled && cards.size() > 1 ? View.VISIBLE : View.GONE);

        // Template cho mọi thẻ: broadcast FLIP về chính lớp này; fill-in của từng thẻ chèn cardId + position.
        // Phải MUTABLE (Android 12+) để hệ thống chèn được extras của fill-in vào template.
        Intent flip = new Intent(context, FlashWidgetProvider.class).setAction(ACTION_FLIP);
        int mutable = Build.VERSION.SDK_INT >= Build.VERSION_CODES.S ? PendingIntent.FLAG_MUTABLE : 0;
        v.setPendingIntentTemplate(R.id.widget_stack, PendingIntent.getBroadcast(context, 1, flip,
                PendingIntent.FLAG_UPDATE_CURRENT | mutable));

        // Header: mở app vào chủ đề của thẻ ở w_index (thẻ vừa lật). Không có thẻ → chỉ mở app;
        // widget đang tắt → mở thẳng màn cấu hình (header và thông báo trống).
        String uri;
        if (!enabled) {
            uri = "flashwidget://settings/widget";
        } else if (cards.isEmpty()) {
            uri = "flashwidget://study";
        } else {
            JSONObject c = cards.get(index);
            uri = "flashwidget://study?topic=" + Uri.encode(c.optString("topicId"))
                    + "&title=" + Uri.encode(c.optString("topicTitle"));
        }
        PendingIntent open = openApp(context, uri);
        v.setOnClickPendingIntent(R.id.widget_header, open);
        v.setOnClickPendingIntent(R.id.widget_empty, open);
        return v;
    }

    /** Đọc JSON "cards"; lỗi thì trả danh sách rỗng. */
    static List<JSONObject> readCards(SharedPreferences p) {
        List<JSONObject> out = new ArrayList<>();
        try {
            JSONArray list = new JSONArray(p.getString("cards", "[]"));
            for (int i = 0; i < list.length(); i++) {
                JSONObject c = list.optJSONObject(i);
                if (c != null) out.add(c);
            }
        } catch (Exception e) {
            Log.e(TAG, "parse cards", e);
            out.clear();
        }
        return out;
    }

    /** Mở MainActivity kèm đường dẫn; home_widget chuyển đường dẫn này sang Dart. */
    private static PendingIntent openApp(Context context, String uri) {
        Intent i = new Intent(context, MainActivity.class)
                .setAction(LAUNCH_ACTION)
                .setData(Uri.parse(uri));
        return PendingIntent.getActivity(context, 2, i,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
    }
}
