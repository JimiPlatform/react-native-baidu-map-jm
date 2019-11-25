package org.lovebing.reactnative.baidumap.uimanager;

import android.view.LayoutInflater;
import android.view.View;

import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.facebook.react.views.view.ReactViewGroup;

import org.lovebing.reactnative.baidumap.util.LatLngUtil;
import org.lovebing.reactnative.baidumap.view.OverlayInfoWindow;

import javax.annotation.Nullable;

/**
 * @author lovebing Created on Dec 09, 2018
 */
public class OverlayInfoWindowManager extends ViewGroupManager<OverlayInfoWindow> {

    @Override
    public String getName() {
        return "BaiduMapOverlayInfoWindow";
    }

    @Override
    protected OverlayInfoWindow createViewInstance(ThemedReactContext reactContext) {
        OverlayInfoWindow overlayInfoWindow = new OverlayInfoWindow(reactContext);
        return overlayInfoWindow;
    }

    @Override
    public void receiveCommand(OverlayInfoWindow root, int commandId, @Nullable ReadableArray args) {
        super.receiveCommand(root, commandId, args);
        if (commandId == 1024 && root != null) {
            root.update();
        }
    }

    @ReactProp(name = "title")
    public void setTitle(OverlayInfoWindow overlayInfoWindow, String title) {
        if (overlayInfoWindow == null || title == null) {
            return;
        }
        overlayInfoWindow.setTitle(title);
    }

    @ReactProp(name = "location")
    public void setLocation(OverlayInfoWindow overlayInfoWindow, ReadableMap location) {
        if (overlayInfoWindow == null || location == null) {
            return;
        }
        overlayInfoWindow.setLocation(LatLngUtil.fromReadableMap(location));
    }

    @ReactProp(name = "visible")
    public void setVisible(OverlayInfoWindow overlayInfoWindow, boolean visible) {
        if (overlayInfoWindow == null) {
            return;
        }
        overlayInfoWindow.setVisible(visible);
    }

    @ReactProp(name = "tag")
    public void setTag(OverlayInfoWindow overlayInfoWindow, int tag) {
        if (overlayInfoWindow == null) {
            return;
        }
        overlayInfoWindow.setmTag(tag);
    }
}
