/**
 * Copyright (c) 2016-present, lovebing.org.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package org.lovebing.reactnative.baidumap.view;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.os.Bundle;
import android.util.Log;

import com.baidu.mapapi.common.SysOSUtil;
import com.baidu.mapapi.map.BaiduMap;
import com.baidu.mapapi.map.BitmapDescriptor;
import com.baidu.mapapi.map.BitmapDescriptorFactory;
import com.baidu.mapapi.map.InfoWindow;
import com.baidu.mapapi.model.LatLng;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.views.view.ReactViewGroup;



/**
 * @author lovebing Created on Dec 09, 2018
 */
public class OverlayInfoWindow extends ReactViewGroup implements OverlayView {

    private Context mContext;
    private String title;
    public LatLng location = new LatLng(0, 0);;
    public BaiduMap mBaiduMap;
    private boolean visible = true;
    private boolean visibleMarker = true;
    private int mTag = -1;
    private InfoWindow infoWindow;
    private Thread updateThread = null;
    private int markerIconHeight = -47;

    private BroadcastReceiver mBroadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String name = intent.getAction();
            if (name == "com.jimi.rn.kJMBaiduInfoWindowUpdateLocation") {
                Bundle bundle = intent.getExtras();
                int tag = -1;
                double latitude = 0.0, longitude = 0.0;
                tag = intent.getIntExtra("tag", tag);
                latitude = intent.getDoubleExtra("latitude", latitude);
                longitude = intent.getDoubleExtra("longitude", longitude);
                visibleMarker = intent.getBooleanExtra("visible", visibleMarker);
                if (intent.hasExtra("iconHeight")) {
                    markerIconHeight = - intent.getIntExtra("iconHeight", markerIconHeight);
                }
                if (tag != -1 && tag == mTag) {
                    setLocation(new LatLng(latitude, longitude));
                }
                if (!visibleMarker) {
                    hide();
                }
            }
        }
    };

    public OverlayInfoWindow(ThemedReactContext context) {
        super(context);
        mContext = context;

        try {
            IntentFilter intentFilter = new IntentFilter();
            intentFilter.addAction("com.jimi.rn.kJMBaiduInfoWindowUpdateLocation");
            mContext.registerReceiver(mBroadcastReceiver, intentFilter);
        } catch (Exception e) {}
    }

    @Override
    public void addTopMap(BaiduMap baiduMap) {
        this.mBaiduMap = baiduMap;
    }

    @Override
    public void removeFromMap(BaiduMap baiduMap) {
        if (mBaiduMap == baiduMap) {
            if (updateThread != null) {
                updateThread.interrupt();
                updateThread = null;
            }

            if (mContext != null && mBroadcastReceiver != null) {
                try {
                    mContext.unregisterReceiver(mBroadcastReceiver);
                    mBroadcastReceiver = null;
                } catch (Exception e) {}
            }

            hide();
            mBaiduMap = null;
        }
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setLocation(LatLng location) {
        if (this.location != location || infoWindow == null) {
            this.location = location;
            this.update();
        }
    }

    public void setVisible(boolean visible) {
        this.visible = visible;
        if (visible) {
            show();
        } else if (!visible) {
            hide();
        }
    }

    public void setmTag(int tag) {
        if (this.mTag != tag) {
            this.mTag = tag;
            this.update();
        }
    }

    public int getmTag() {
        return this.mTag;
    }

    public void show() {
        if (mBaiduMap != null) {
            updateInfoWindow();
            mBaiduMap.showInfoWindow(infoWindow);
        }
    }

    public void hide() {
        if (mBaiduMap != null) {
            mBaiduMap.hideInfoWindow();
        }
    }

    public void update() {
        show();
    }

    private void updateInfoWindow() {
        if (!visible || !visibleMarker) {
            return;
        }

        buildDrawingCache(true);
        Bitmap bitmap = getDrawingCache(true);
        if (bitmap != null) {
            double density = SysOSUtil.getDensity();
            double scale = (3.0 - density)/2.0 + 1.0;
            if (scale < 1.0) {
                scale = 1.0;
            }
            Log.d("RN", "Density:" + SysOSUtil.getDensity() +  " scale:" + scale);

            bitmap = zoomImg(bitmap, (int)(bitmap.getWidth()*scale), (int)(bitmap.getHeight()*scale));
            BitmapDescriptor bitmapDescriptor = BitmapDescriptorFactory.fromBitmap(bitmap);
            destroyDrawingCache();

            if (bitmapDescriptor != null) {
                infoWindow = new InfoWindow(bitmapDescriptor, location, markerIconHeight,null);
            } else {
                delayUpdate();
            }
        } else {
            delayUpdate();
        }
    }

    private void delayUpdate() {
        if (updateThread != null) {
            updateThread.interrupt();
            updateThread = null;
        }
        updateThread = new Thread(() -> {
            try {
                Thread.sleep(200);
                update();
            } catch (InterruptedException e) {
            }
        });
        updateThread.start();
    }

    public static Bitmap zoomImg(Bitmap bm, int newWidth ,int newHeight){
        int width = bm.getWidth();
        int height = bm.getHeight();
        float scaleWidth = ((float) newWidth) / width;
        float scaleHeight = ((float) newHeight) / height;
        Matrix matrix = new Matrix();
        matrix.postScale(scaleWidth, scaleHeight);
        Bitmap newbm = Bitmap.createBitmap(bm, 0, 0, width, height, matrix, true);
        return newbm;
    }
}
