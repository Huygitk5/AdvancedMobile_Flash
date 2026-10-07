package com.example.flash;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;
import android.view.View;
import android.widget.RemoteViews;
import android.widget.RemoteViewsService;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/**
 * Dựng từng thẻ của StackView từ JSON "cards" mà Dart ghi vào "HomeWidgetPreferences".
 * Thẻ có id bằng "w_flipped_id" hiện mặt sau, các thẻ khác hiện mặt trước.
 */
class FlashWidgetFactory implements RemoteViewsService.RemoteViewsFactory {
    private static final String TAG = "FlashWidget";
    private final Context context;
    private final List<JSONObject> cards = new ArrayList<>();
    private String flippedId = "";
    private String tapHint = "";

    FlashWidgetFactory(Context context) {
        this.context = context;
    }

    @Override
    public void onCreate() {
    }

    /** Gọi sau notifyAppWidgetViewDataChanged: đọc lại thẻ, trạng thái lật và nhãn mới nhất. */
    @Override
    public void onDataSetChanged() {
        cards.clear();
        try {
            SharedPreferences p = context.getSharedPreferences(FlashWidgetProvider.PREFS, Context.MODE_PRIVATE);
            cards.addAll(FlashWidgetProvider.readCards(p));
            flippedId = p.getString(FlashWidgetProvider.KEY_FLIPPED, "");
            tapHint = p.getString("w_tap_hint", "");
        } catch (Exception e) {
            Log.e(TAG, "onDataSetChanged", e);
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
        if (position < 0 || position >= cards.size()) {
            return new RemoteViews(context.getPackageName(), R.layout.flash_widget_card_front);
        }
        JSONObject c = cards.get(position);
        String id = c.optString("id");
        boolean flipped = !id.isEmpty() && id.equals(flippedId);
        RemoteViews v = new RemoteViews(context.getPackageName(),
                flipped ? R.layout.flash_widget_card_back : R.layout.flash_widget_card_front);
        try {
            v.setTextViewText(R.id.card_word, c.optString("word"));
            if (flipped) {
                String pos = c.optString("partOfSpeech");
                v.setTextViewText(R.id.card_pos, pos);
                v.setViewVisibility(R.id.card_pos, pos.isEmpty() ? View.GONE : View.VISIBLE);
                v.setTextViewText(R.id.card_pronunciation, c.optString("pronunciation"));
                v.setTextViewText(R.id.card_meaning, c.optString("meaning"));
            } else {
                v.setTextViewText(R.id.card_hint, tapHint);
            }

            // Chạm thẻ → broadcast FLIP về FlashWidgetProvider (template), không mở app.
            Intent fill = new Intent()
                    .putExtra(FlashWidgetProvider.EXTRA_CARD_ID, id)
                    .putExtra(FlashWidgetProvider.EXTRA_POSITION, position);
            v.setOnClickFillInIntent(R.id.widget_card, fill);
        } catch (Exception e) {
            Log.e(TAG, "getViewAt", e);
        }
        return v;
    }

    @Override
    public RemoteViews getLoadingView() {
        return null; // dùng giao diện "đang tải" mặc định
    }

    /** Mặt trước và mặt sau. */
    @Override
    public int getViewTypeCount() {
        return 2;
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
