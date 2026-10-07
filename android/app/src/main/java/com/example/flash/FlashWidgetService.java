package com.example.flash;

import android.content.Intent;
import android.widget.RemoteViewsService;

/** Cung cấp {@link FlashWidgetFactory} cho ListView của widget (dùng được từ API 23, khác RemoteCollectionItems cần API 31). */
public class FlashWidgetService extends RemoteViewsService {
    @Override
    public RemoteViewsFactory onGetViewFactory(Intent intent) {
        return new FlashWidgetFactory(getApplicationContext());
    }
}
