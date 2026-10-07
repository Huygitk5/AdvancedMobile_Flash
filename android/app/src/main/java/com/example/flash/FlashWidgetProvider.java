package com.example.flash;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Build;
import android.util.Log;
import android.widget.RemoteViews;

/**
 * Widget vuông bo góc: header + danh sách từ cuộn được.
 * Dữ liệu (JSON "cards" và các nhãn) do Dart ghi vào "HomeWidgetPreferences";
 * danh sách do {@link FlashWidgetService} / {@link FlashWidgetFactory} dựng.
 */
public class FlashWidgetProvider extends AppWidgetProvider {
    private static final String TAG = "FlashWidget";
    // Tên SharedPreferences mà gói home_widget dùng để lưu dữ liệu từ Dart.
    static final String PREFS = "HomeWidgetPreferences";
    // Action gói home_widget dùng để nhận biết "app được mở từ widget".
    private static final String LAUNCH_ACTION = "es.antonborri.home_widget.action.LAUNCH";

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
            // Báo danh sách đọc lại JSON "cards" mới (gọi FlashWidgetFactory.onDataSetChanged).
            manager.notifyAppWidgetViewDataChanged(ids, R.id.widget_list);
        } catch (Exception e) {
            Log.e(TAG, "notifyAppWidgetViewDataChanged", e);
        }
    }

    private static RemoteViews buildViews(Context context, int widgetId) {
        SharedPreferences p = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
        boolean enabled = !"0".equals(p.getString("w_enabled", "1"));
        RemoteViews v = new RemoteViews(context.getPackageName(), R.layout.flash_widget);

        // Danh sách: mỗi widgetId một data URI riêng để hệ thống không dùng chung factory.
        Intent svc = new Intent(context, FlashWidgetService.class)
                .putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId);
        svc.setData(Uri.parse(svc.toUri(Intent.URI_INTENT_SCHEME)));
        v.setRemoteAdapter(R.id.widget_list, svc);
        v.setEmptyView(R.id.widget_list, R.id.widget_empty);

        v.setTextViewText(R.id.widget_count, enabled ? p.getString("w_count_label", "") : "");
        v.setTextViewText(R.id.widget_empty, p.getString("w_empty", ""));

        // Template cho từng dòng: KHÔNG set data, để fill-in intent của dòng đặt data
        // flashwidget://study?topic=...&title=... (Intent.fillIn chỉ chép data khi template chưa có).
        // Phải MUTABLE vì hệ thống cần chèn fill-in vào template (Android 12+).
        Intent template = new Intent(context, MainActivity.class).setAction(LAUNCH_ACTION);
        int mutable = Build.VERSION.SDK_INT >= Build.VERSION_CODES.S ? PendingIntent.FLAG_MUTABLE : 0;
        v.setPendingIntentTemplate(R.id.widget_list, PendingIntent.getActivity(context, 1, template,
                PendingIntent.FLAG_UPDATE_CURRENT | mutable));

        // Header / thông báo trống: mở app; widget đang tắt thì mở thẳng màn cấu hình.
        PendingIntent open = openApp(context, enabled ? "flashwidget://study" : "flashwidget://settings/widget");
        v.setOnClickPendingIntent(R.id.widget_header, open);
        v.setOnClickPendingIntent(R.id.widget_empty, open);
        return v;
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
