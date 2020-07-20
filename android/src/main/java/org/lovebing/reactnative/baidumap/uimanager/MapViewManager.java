/**
 * Copyright (c) 2016-present, lovebing.org.
 *
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
import com.baidu.mapapi.map.MapView;
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
import org.lovebing.reactnative.baidumap.view.OverlayView;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Nullable;

public class MapViewManager extends ViewGroupManager<MapView> {
    private static Object mStationChildren = new Object();
    public static Map<MapView, ArrayList<Object>> mapViewMap = new HashMap<>();
    public static Map<MapView, MapListener> mapListenerMap = new HashMap<>();

    @Override
    public String getName() {
        return "BaiduMapView";
    }

    @Override
    protected MapView createViewInstance(ThemedReactContext themedReactContext) {
        MapView mapView =  new MapView(themedReactContext);
        BaiduMap map = mapView.getMap();
        mapView.showScaleControl(false);    // 不显示地图上比例尺

        MapListener mMapListener = new MapListener(mapView, themedReactContext);
        map.setOnMapStatusChangeListener(mMapListener);
        map.setOnMapLoadedCallback(mMapListener);
        map.setOnMapClickListener(mMapListener);
        map.setOnMapDoubleClickListener(mMapListener);
        map.setOnMarkerClickListener(mMapListener);
        mapListenerMap.put(mapView, mMapListener);

        ArrayList<Object> childrenList = mapViewMap.get(mapView);
        if (childrenList == null) {
            childrenList = new ArrayList<>();
        }
        mapViewMap.put(mapView, childrenList);

        return mapView;
    }

    @Override
    public void receiveCommand(MapView root, int commandId, @Nullable ReadableArray args) {
        super.receiveCommand(root, commandId, args);

        if (commandId == 1024 && root != null) {
            Log.d("RN", "Buidu->receiveCommand");
            root.onResume();
        }
    }

    @Override
    public void addView(MapView parent, View child, int index) {

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
    public void removeAllViews(MapView parent) {
        super.removeAllViews(parent);

        Log.d("RNBaidudu", "MapViewManager removeAllViews");
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
    public void removeViewAt(MapView parent, int index) {
        super.removeViewAt(parent, index);

        ArrayList<Object> childrenList = mapViewMap.get(parent);
        if (childrenList != null && index < childrenList.size()) {
            Object child = childrenList.get(index);
            childrenList.remove(index);
            if (child instanceof OverlayView) {
                ((OverlayView) child).removeFromMap(parent.getMap());
            }
        }
    }

    private void removeOldChildViews(BaiduMap baiduMap, ArrayList<Object> childrenList) {
        for (Object child : childrenList) {
            if (child instanceof OverlayView) {
                ((OverlayView) child).removeFromMap(baiduMap);
            }
        }
        childrenList.clear();
    }

    @ReactProp(name = "zoomControlsVisible")
    public void setZoomControlsVisible(MapView mapView, boolean zoomControlsVisible) {
        mapView.showZoomControls(zoomControlsVisible);
    }

    @ReactProp(name="trafficEnabled")
    public void setTrafficEnabled(MapView mapView, boolean trafficEnabled) {
        mapView.getMap().setTrafficEnabled(trafficEnabled);
    }

    @ReactProp(name="baiduHeatMapEnabled")
    public void setBaiduHeatMapEnabled(MapView mapView, boolean baiduHeatMapEnabled) {
        mapView.getMap().setBaiduHeatMapEnabled(baiduHeatMapEnabled);
    }

    @ReactProp(name = "mapType")
    public void setMapType(MapView mapView, int mapType) {
        mapView.getMap().setMapType(mapType);
    }

    @ReactProp(name="zoom")
    public void setZoom(MapView mapView, float zoom) {
        MapStatus mapStatus = new MapStatus.Builder().zoom(zoom).build();
        MapStatusUpdate mapStatusUpdate = MapStatusUpdateFactory.newMapStatus(mapStatus);
        mapView.getMap().setMapStatus(mapStatusUpdate);
    }

    @ReactProp(name="center")
    public void setCenter(MapView mapView, ReadableMap position) {
        if(position != null) {
            LatLng point = LatLngUtil.fromReadableMap(position);
            MapStatus mapStatus = new MapStatus.Builder()
                    .target(point)
                    .build();
            MapStatusUpdate mapStatusUpdate = MapStatusUpdateFactory.newMapStatus(mapStatus);
            mapView.getMap().setMapStatus(mapStatusUpdate);
        }
    }

    @ReactProp(name = "overlookEnabled")
    public void setOverlookEnabled(MapView mapView, boolean overlookEnabled){
        UiSettings settings=mapView.getMap().getUiSettings();
        settings.setOverlookingGesturesEnabled(false);
    }

    /****************************************   轨迹  *********************************************/


    @ReactProp(name = "visualRange")
    public void setVisualRange(MapView mapView, ReadableArray data) {
        if (data == null) return;

        List<LatLng> mPoints = LatLngUtil.fromReadableArray(data);
        //mPoints = TrackUtils.gpsConversionBaidu(tracks);
        TrackUtils.setAllinVisibleRange(mapView,mPoints);
        Log.i("MapView","更新了轨迹点：" + mPoints.size());
    }


    @ReactProp(name = "trackPlayInfo")
    public void setTrackPlayInfo(MapView mapView, ReadableMap position){
        if(position != null){
            LatLng latLng = LatLngUtil.fromReadableMap(position);
            Projection projection = mapView.getMap().getProjection();
            if(projection != null){
                //将经纬度转换为屏幕的点坐标
                Point vPoint = projection.toScreenLocation(latLng);
                //如果在地图外面就更新当前点为地图中心
                if (isOutScreen(mapView, vPoint)){
                    mapView.getMap().animateMapStatus(MapStatusUpdateFactory.newLatLng(latLng));
                }
            }
        }
    }

    @ReactProp(name = "correctPerspective")
    public void correctPerspective(MapView mapView,ReadableMap position){
        Log.i("MapView","correctPerspective：");
        if(position != null){
            LatLng latLng = LatLngUtil.fromReadableMap(position);
            Log.i("MapView","correctPerspective---latLng.latitude:" + latLng.latitude + " ,latLng.longitude:" + latLng.longitude);
            Projection projection = mapView.getMap().getProjection();
            if(projection != null){
                //将经纬度转换为屏幕的点坐标
                Point vPoint = projection.toScreenLocation(latLng);
                //如果在地图外面就更新当前点为地图中心
                if (isOutScreen(mapView, vPoint)){
                    mapView.getMap().animateMapStatus(MapStatusUpdateFactory.newLatLng(latLng));
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
    private boolean isOutScreen(MapView mapView, Point pPoint) {
        if (pPoint.x < 0 || pPoint.y < 0 || pPoint.x > mapView.getWidth() || pPoint.y > mapView
                .getHeight()) {
            return true;
        }
        return false;
    }
}



