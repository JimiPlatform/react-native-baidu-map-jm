/**
 * Copyright (c) 2016-present, lovebing.org.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package org.lovebing.reactnative.baidumap.uimanager;

import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;
import org.lovebing.reactnative.baidumap.util.ColorUtil;
import org.lovebing.reactnative.baidumap.util.LatLngUtil;
import org.lovebing.reactnative.baidumap.util.StrokeUtil;
import org.lovebing.reactnative.baidumap.view.OverlayArc;
import org.lovebing.reactnative.baidumap.view.OverlayCircle;

/**
 * @author lovebing Created on Dec 09, 2018
 */
public class OverlayCircleManager extends SimpleViewManager<OverlayCircle> {

    @Override
    public String getName() {
        return "BaiduMapOverlayCircle";
    }

    @Override
    protected OverlayCircle createViewInstance(ThemedReactContext reactContext) {
        return new OverlayCircle(reactContext);
    }

    @ReactProp(name = "radius")
    public void setRadius(OverlayCircle overlayCircle, int radius) {
        overlayCircle.setRadius(radius);
    }

    @ReactProp(name = "center")
    public void setCenter(OverlayCircle overlayCircle, ReadableMap center) {
        if (center == null) return;

        overlayCircle.setCenter(LatLngUtil.fromReadableMap(center));
    }

    @ReactProp(name = "fillColor")
    public void setFillColor(OverlayCircle overlayCircle, String fillColor) {
        if (fillColor == null) return;

        overlayCircle.setFillColor(ColorUtil.fromString(fillColor));
    }

    @ReactProp(name = "stroke")
    public void setStroke(OverlayCircle overlayCircle, ReadableMap stroke) {
        if (stroke == null) return;

        overlayCircle.setStroke(StrokeUtil.fromReadableMap(stroke));
    }

    @ReactProp(name="visible")
    public void visible(OverlayCircle overlayCircle, boolean visible){
        overlayCircle.setVisible(visible);
    }
}
