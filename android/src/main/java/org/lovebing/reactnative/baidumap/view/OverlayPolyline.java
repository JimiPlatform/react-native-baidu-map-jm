/**
 * Copyright (c) 2016-present, lovebing.org.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package org.lovebing.reactnative.baidumap.view;

import android.annotation.TargetApi;
import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;

import com.baidu.mapapi.map.BaiduMap;
import com.baidu.mapapi.map.Polyline;
import com.baidu.mapapi.map.PolylineOptions;
import com.baidu.mapapi.model.LatLng;

import java.util.ArrayList;
import java.util.List;

/**
 * @author lovebing Created on Dec 9, 2018
 */
public class OverlayPolyline extends View implements OverlayView {

    private List<LatLng> points;
    private Polyline polyline;
    private int color = 0xAAFF0000;
    private int width = 8;
    private boolean visible = true;
    private BaiduMap mBaiduMap;

    public OverlayPolyline(Context context) {
        super(context);
    }

    public OverlayPolyline(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public OverlayPolyline(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @TargetApi(21)
    public OverlayPolyline(Context context, @Nullable AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
    }

    public List<LatLng> getPoints() {
        return points;
    }

    public void setPoints(List<LatLng> points) {
        if (points.size() >= 2) {
            this.points = points;
        } else {
            List<LatLng> defaultPoints = new ArrayList<>();
            defaultPoints.add(new LatLng(0,0));
            defaultPoints.add(new LatLng(0,0));
            this.points = defaultPoints;
        }

        if (polyline != null) {
            polyline.setPoints(this.points);
        }
    }

    public int getColor() {
        return color;
    }

    public void setColor(int color) {
        this.color = color;
        if (polyline != null) {
            polyline.setColor(color);
        }
    }

    public void setVisible(boolean visible){
        this.visible = visible;
        if (polyline != null){
            polyline.setVisible(visible);
        }
    }

    public void setWidth(int width){
        this.width = width;
        if (polyline != null){
            polyline.setWidth(width);
        }
    }

    @Override
    public void addTopMap(BaiduMap baiduMap) {
        PolylineOptions options = new PolylineOptions().width(width)
                .color(this.color).visible(visible);
        if (points != null && points.size() >=2) {
            options.points(points);
            polyline = (Polyline) baiduMap.addOverlay(options);
        } else {
            List<LatLng> defaultPoints = new ArrayList<>();
            defaultPoints.add(new LatLng(0,0));
            defaultPoints.add(new LatLng(0,0));
            options.points(defaultPoints);
            polyline = (Polyline) baiduMap.addOverlay(options);
        }
        mBaiduMap = baiduMap;
    }

    @Override
    public void removeFromMap(BaiduMap baiduMap) {
        if (mBaiduMap == baiduMap && polyline != null) {
            polyline.remove();
            polyline = null;
            mBaiduMap = null;
        }
    }
}
