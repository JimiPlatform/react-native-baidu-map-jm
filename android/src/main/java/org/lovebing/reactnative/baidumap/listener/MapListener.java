/**
 * Copyright (c) 2016-present, lovebing.org.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package org.lovebing.reactnative.baidumap.listener;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.support.annotation.Nullable;
import android.support.v4.content.LocalBroadcastManager;
import android.view.View;
import android.widget.ImageView;
import android.widget.Toast;
import android.widget.ZoomControls;

import com.baidu.mapapi.map.BaiduMap;
import com.baidu.mapapi.map.MapPoi;
import com.baidu.mapapi.map.MapStatus;
import com.baidu.mapapi.map.TextureMapView;
import com.baidu.mapapi.map.Marker;
import com.baidu.mapapi.model.LatLng;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import org.lovebing.reactnative.baidumap.view.OverlayInfoWindow;

public class MapListener implements BaiduMap.OnMapStatusChangeListener,
        BaiduMap.OnMapLoadedCallback,
        BaiduMap.OnMapClickListener,
        BaiduMap.OnMapDoubleClickListener,
        BaiduMap.OnMarkerClickListener {

    private ReactContext reactContext;
    private TextureMapView TextureMapView;

    public MapListener(TextureMapView TextureMapView, ReactContext reactContext) {
        this.TextureMapView = TextureMapView;
        this.reactContext = reactContext;
    }

    public void onDestroy() {
        TextureMapView = null;
        reactContext = null;
    }

    @Override
    public void onMapClick(LatLng latLng) {
        WritableMap writableMap = Arguments.createMap();
        writableMap.putDouble("latitude", latLng.latitude);
        writableMap.putDouble("longitude", latLng.longitude);
        sendEvent(TextureMapView, "onMapClick", writableMap);
    }

    @Override
    public void onMapPoiClick(MapPoi mapPoi) {
        WritableMap writableMap = Arguments.createMap();
        writableMap.putString("name", mapPoi.getName());
        writableMap.putString("uid", mapPoi.getUid());
        writableMap.putDouble("latitude", mapPoi.getPosition().latitude);
        writableMap.putDouble("longitude", mapPoi.getPosition().longitude);
        sendEvent(TextureMapView, "onMapPoiClick", writableMap);
    }

    @Override
    public void onMapDoubleClick(LatLng latLng) {
        WritableMap writableMap = Arguments.createMap();
        writableMap.putDouble("latitude", latLng.latitude);
        writableMap.putDouble("longitude", latLng.longitude);
        sendEvent(TextureMapView, "onMapDoubleClick", writableMap);
    }

    @Override
    public void onMapLoaded() {
        sendEvent(TextureMapView, "onMapLoaded", null);
    }

    @Override
    public void onMapStatusChangeStart(MapStatus mapStatus) {
        sendEvent(TextureMapView, "onMapStatusChangeStart", getEventParams(mapStatus));
    }

     @Override
     public void onMapStatusChangeStart(MapStatus mapStatus, int reason) {
//         if (reason == REASON_DEVELOPER_ANIMATION) {
//             TextureMapView.onResume();
//         }
         sendEvent(TextureMapView, "onMapStatusChangeStart", getEventParams(mapStatus));
     }

    @Override
    public void onMapStatusChange(MapStatus mapStatus) {
        sendEvent(TextureMapView, "onMapStatusChange", getEventParams(mapStatus));
    }

    @Override
    public void onMapStatusChangeFinish(MapStatus mapStatus) {
        sendEvent(TextureMapView, "onMapStatusChangeFinish", getEventParams(mapStatus));
    }

    @Override
    public boolean onMarkerClick(Marker marker) {
        WritableMap writableMap = Arguments.createMap();
        WritableMap position = Arguments.createMap();
        position.putDouble("latitude", marker.getPosition().latitude);
        position.putDouble("longitude", marker.getPosition().longitude);
        writableMap.putMap("position", position);
        writableMap.putString("title", marker.getTitle());
        if (marker.getExtraInfo()!=null){
            int tag = marker.getExtraInfo().getInt("tag");
            writableMap.putInt("tag", tag);
        }
        sendEvent(TextureMapView, "onMarkerClick", writableMap);
        return true;
    }

    private WritableMap getEventParams(MapStatus mapStatus) {
        WritableMap writableMap = Arguments.createMap();
        WritableMap target = Arguments.createMap();
        target.putDouble("latitude", mapStatus.target.latitude);
        target.putDouble("longitude", mapStatus.target.longitude);
        writableMap.putMap("target", target);
        writableMap.putDouble("zoom", mapStatus.zoom);
        writableMap.putDouble("overlook", mapStatus.overlook);
        return writableMap;
    }

    /**
     *
     * @param eventName
     * @param params
     */
    private void sendEvent(TextureMapView TextureMapView, String eventName, @Nullable WritableMap params) {
        WritableMap event = Arguments.createMap();
        event.putMap("params", params);
        event.putString("type", eventName);
        reactContext
                .getJSModule(RCTEventEmitter.class)
                .receiveEvent(TextureMapView.getId(),
                        "topChange",
                        event);
    }
}
