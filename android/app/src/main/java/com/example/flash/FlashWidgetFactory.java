package com.example.flash;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import android.widget.RemoteViews;
import android.widget.RemoteViewsService;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/** Dựng từng dòng của danh sách từ JSON "cards" mà Dart ghi vào "HomeWidgetPreferences". */
class FlashWidgetFactory implements RemoteViewsService.RemoteViewsFactory {
    private static final String TAG = "FlashWidget";
    private final Context context;
    private final List<JSONObject> cards = new ArrayList<>();

    FlashWidgetFactory(Context context) {
        this.context = context;
    }

    @Override
    public void onCreate() {
    }

    /** Gọi sau notifyAppWidgetViewDataChanged: đọc lại dữ liệu mới nhất. */
    @Override
    public void onDataSetChanged() {
        cards.clear();
        try {
            String json = context.getSharedPreferences(FlashWidgetProvider.PREFS, Context.MODE_PRIVATE)
                    .getString("cards", "[]");
            JSONArray list = new JSONArray(json);
            for (int i = 0; i < list.length(); i++) {
                JSONObject c = list.optJSONObject(i);
                if (c != null) cards.add(c);
            }
        } catch (Exception e) {
            Log.e(TAG, "parse cards", e);
            cards.clear();
        }
    }

    @Override
    public void onDestroy() {
        cards.clear();
    }

    @Override
    public int getCount() {
        return cards.size();
    }

    @Override
    public RemoteViews getViewAt(int position) {
        RemoteViews v = new RemoteViews(context.getPackageName(), R.layout.flash_widget_item);
        if (position < 0 || position >= cards.size()) return v;
        try {
            JSONObject c = cards.get(position);
            String topicId = c.optString("topicId");
            String topicTitle = c.optString("topicTitle");
            v.setTextViewText(R.id.item_word, c.optString("word"));
            v.setTextViewText(R.id.item_pronunciation, c.optString("pronunciation"));
            v.setTextViewText(R.id.item_meaning, c.optString("meaning"));

            // Template không có data → data của fill-in được giữ, Dart đọc chủ đề từ URI này.
            Intent fill = new Intent()
                    .putExtra("topicId", topicId)
                    .putExtra("topicTitle", topicTitle)
                    .setData(Uri.parse("flashwidget://study?topic=" + Uri.encode(topicId)
                            + "&title=" + Uri.encode(topicTitle)));
            v.setOnClickFillInIntent(R.id.widget_item, fill);
        } catch (Exception e) {
            Log.e(TAG, "getViewAt", e);
        }
        return v;
    }

    @Override
    public RemoteViews getLoadingView() {
        return null; // dùng giao diện "đang tải" mặc định
    }

    @Override
    public int getViewTypeCount() {
        return 1;
    }

    @Override
    public long getItemId(int position) {
        if (position < 0 || position >= cards.size()) return position;
        return cards.get(position).optString("id").hashCode();
    }

    @Override
    public boolean hasStableIds() {
        return true;
    }
}
