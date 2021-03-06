/**
 * Copyright (c) 2016-present, lovebing.org.
 * <p>
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package org.lovebing.reactnative.baidumap.uimanager;

import android.graphics.Point;
import android.util.Log;
import android.view.View;

import com.baidu.mapapi.map.BaiduMap;
import com.baidu.mapapi.map.MapStatus;
import com.baidu.mapapi.map.MapStatusUpdate;
import com.baidu.mapapi.map.MapStatusUpdateFactory;
import com.baidu.mapapi.map.TextureMapView;
import com.baidu.mapapi.map.Projection;
import com.baidu.mapapi.map.UiSettings;
import com.baidu.mapapi.model.LatLng;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;

import org.lovebing.reactnative.baidumap.listener.MapListener;
import org.lovebing.reactnative.baidumap.util.LatLngUtil;
import org.lovebing.reactnative.baidumap.util.TrackUtils;
import org.lovebing.reactnative.baidumap.view.OverlayMarker;
import org.lovebing.reactnative.baidumap.view.OverlayView;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Nullable;

/**
 *
 */
public class MapViewManager extends ViewGroupManager<TextureMapView> {
    private static Object mStationChildren = new Object();
    public static Map<TextureMapView, ArrayList<Object>> mapViewMap = new HashMap<>();
    public static Map<TextureMapView, MapListener> mapListenerMap = new HashMap<>();

    @Override
    public String getName() {
        return "BaiduMapView";
    }

    @Override
    protected TextureMapView createViewInstance(ThemedReactContext themedReactContext) {
        Log.d("RNBaidudu", "MapViewManager createViewInstance");
        TextureMapView TextureMapView = new TextureMapView(themedReactContext);
        BaiduMap map = TextureMapView.getMap();
        TextureMapView.showScaleControl(false);    // 不显示地图上比例尺

        MapListener mMapListener = new MapListener(TextureMapView, themedReactContext);
        map.setOnMapStatusChangeListener(mMapListener);
        map.setOnMapLoadedCallback(mMapListener);
        map.setOnMapClickListener(mMapListener);
        map.setOnMapDoubleClickListener(mMapListener);
        map.setOnMarkerClickListener(mMapListener);
        mapListenerMap.put(TextureMapView, mMapListener);

        ArrayList<Object> childrenList = mapViewMap.get(TextureMapView);
        if (childrenList == null) {
            childrenList = new ArrayList<>();
        }
        mapViewMap.put(TextureMapView, childrenList);

        return TextureMapView;
    }

    @Override
    public void receiveCommand(TextureMapView root, int commandId, @Nullable ReadableArray args) {
        Log.d("RNBaidudu", "MapViewManager receiveCommand");
        super.receiveCommand(root, commandId, args);

        if (commandId == 1024 && root != null) {
            Log.d("RN", "Buidu->receiveCommand");
            root.onResume();
        }
    }

    @Override
    public void addView(TextureMapView parent, View child, int index) {
        Log.d("RNBaidudu", "MapViewManager addView");
        ArrayList<Object> childrenList = mapViewMap.get(parent);
        if (childrenList != null) {
            if (index == 0 && !childrenList.isEmpty()) {
                removeOldChildViews(parent.getMap(), childrenList);
            }

            if (child instanceof OverlayView) {
                ((OverlayView) child).addTopMap(parent.getMap());
                childrenList.add(child);
            } else {
                childrenList.add(mStationChildren);
            }
        }
    }

    @Override
    public void removeAllViews(TextureMapView parent) {
        Log.d("RNBaidudu", "MapViewManager removeAllViews");
        super.removeAllViews(parent);

        MapListener mMapListener = mapListenerMap.get(parent);
        if (mMapListener != null) {
            BaiduMap map = parent.getMap();
            map.setOnMapStatusChangeListener(null);
            map.setOnMapLoadedCallback(null);
            map.setOnMapClickListener(null);
            map.setOnMapDoubleClickListener(null);
            map.setOnMarkerClickListener(null);

            mMapListener.onDestroy();
            mapListenerMap.remove(parent);
            mMapListener = null;
        }

        ArrayList<Object> childrenList = mapViewMap.get(parent);
        if (childrenList != null) {
            removeOldChildViews(parent.getMap(), childrenList);
            mapViewMap.remove(parent);
            Log.d("RNBaidudu", "Remove all view");
        }
    }

   @Override
    public void removeView(TextureMapView parent, View view) {
        Log.d("RNBaidudu", "removeView");
        super.removeView(parent, view);
    }

    @Override
    public void removeViewAt(TextureMapView parent, int index) {
        Log.d("RNBaidudu", "removeViewAt");
        super.removeViewAt(parent, index);

        ArrayList<Object> childrenList = mapViewMap.get(parent);
        if (childrenList != null && index < childrenList.size()) {
            Log.d("RNBaidudu", "removeViewAt:" + index);
            Object child = childrenList.get(index);
             childrenList.remove(index);
            if (child instanceof OverlayView) {
                ((OverlayView) child).removeFromMap(parent.getMap());
            }
        }
    }

    private void removeOldChildViews(BaiduMap baiduMap, ArrayList<Object> childrenList) {
        Log.d("RNBaidudu", "removeOldChildViews");
        for (Object child : childrenList) {
            if (child instanceof OverlayView) {
                ((OverlayView) child).removeFromMap(baiduMap);
            }
        }
        childrenList.clear();
    }

    @ReactProp(name = "zoomControlsVisible")
    public void setZoomControlsVisible(TextureMapView TextureMapView, boolean zoomControlsVisible) {
        TextureMapView.showZoomControls(zoomControlsVisible);
    }

    @ReactProp(name = "trafficEnabled")
    public void setTrafficEnabled(TextureMapView TextureMapView, boolean trafficEnabled) {
        TextureMapView.getMap().setTrafficEnabled(trafficEnabled);
    }

    @ReactProp(name = "baiduHeatMapEnabled")
    public void setBaiduHeatMapEnabled(TextureMapView TextureMapView, boolean baiduHeatMapEnabled) {
        TextureMapView.getMap().setBaiduHeatMapEnabled(baiduHeatMapEnabled);
    }

    @ReactProp(name = "mapType")
    public void setMapType(TextureMapView TextureMapView, int mapType) {
        TextureMapView.getMap().setMapType(mapType);
    }

    @ReactProp(name = "zoom")
    public void setZoom(TextureMapView TextureMapView, float zoom) {
        MapStatus mapStatus = new MapStatus.Builder().zoom(zoom).build();
        MapStatusUpdate mapStatusUpdate = MapStatusUpdateFactory.newMapStatus(mapStatus);
        TextureMapView.getMap().setMapStatus(mapStatusUpdate);
    }

    @ReactProp(name = "center")
    public void setCenter(TextureMapView TextureMapView, ReadableMap position) {
        if (position != null) {
            LatLng point = LatLngUtil.fromReadableMap(position);
            MapStatus mapStatus = new MapStatus.Builder()
                    .target(point)
                    .build();
            MapStatusUpdate mapStatusUpdate = MapStatusUpdateFactory.newMapStatus(mapStatus);
            TextureMapView.getMap().setMapStatus(mapStatusUpdate);
        }
    }

    @ReactProp(name = "overlookEnabled")
    public void setOverlookEnabled(TextureMapView TextureMapView, boolean overlookEnabled) {
        UiSettings settings = TextureMapView.getMap().getUiSettings();
        settings.setOverlookingGesturesEnabled(false);
    }



    @ReactProp(name = "visualRange")
    public void setVisualRange(TextureMapView TextureMapView, ReadableArray data) {
        Log.d("RNBaidudu", "MapViewManager setVisualRange");
        if (data == null) return;
        List<LatLng> mPoints = LatLngUtil.fromReadableArray(data);
        //mPoints = TrackUtils.gpsConversionBaidu(tracks);
        TrackUtils.setAllinVisibleRange(TextureMapView, mPoints);
        Log.i("TextureMapView", "更新了轨迹点：" + mPoints.size());
    }


    @ReactProp(name = "trackPlayInfo")
    public void setTrackPlayInfo(TextureMapView TextureMapView, ReadableMap position) {
        if (position != null) {
            LatLng latLng = LatLngUtil.fromReadableMap(position);
            Projection projection = TextureMapView.getMap().getProjection();
            if (projection != null) {
                //将经纬度转换为屏幕的点坐标
                Point vPoint = projection.toScreenLocation(latLng);
                //如果在地图外面就更新当前点为地图中心
                if (isOutScreen(TextureMapView, vPoint)) {
                    TextureMapView.getMap().animateMapStatus(MapStatusUpdateFactory.newLatLng(latLng));
                }
            }
        }
    }

    @ReactProp(name = "correctPerspective")
    public void correctPerspective(TextureMapView TextureMapView, ReadableMap position) {
        Log.i("TextureMapView", "correctPerspective：");
        if (position != null) {
            LatLng latLng = LatLngUtil.fromReadableMap(position);
            Log.i("TextureMapView", "correctPerspective---latLng.latitude:" + latLng.latitude + " ,latLng.longitude:" + latLng.longitude);
            Projection projection = TextureMapView.getMap().getProjection();
            if (projection != null) {
                //将经纬度转换为屏幕的点坐标
                Point vPoint = projection.toScreenLocation(latLng);
                //如果在地图外面就更新当前点为地图中心
                if (isOutScreen(TextureMapView, vPoint)) {
                    TextureMapView.getMap().animateMapStatus(MapStatusUpdateFactory.newLatLng(latLng));
                }
            }
        }
    }



    /**
     * 车辆s是否显示在MapView中
     *
     * @param pPoint
     * @return
     */
    private boolean isOutScreen(TextureMapView TextureMapView, Point pPoint) {
        if (pPoint.x < 0 || pPoint.y < 0 || pPoint.x > TextureMapView.getWidth() || pPoint.y > TextureMapView
                .getHeight()) {
            return true;
        }
        return false;
    }
}



