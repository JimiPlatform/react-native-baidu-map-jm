/**
 * Copyright (c) 2016-present, lovebing.org.
 * <p>
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

package org.lovebing.reactnative.baidumap.module;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;

import com.baidu.mapapi.utils.route.BaiduMapRoutePlan;
import com.baidu.mapapi.utils.route.RouteParaOption;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;

import org.lovebing.reactnative.baidumap.util.LatLngUtil;

/**
 * @author lovebing Created on Dec 09, 2018
 */
public class MapAppModule extends BaseModule {

    private Context context;

    public MapAppModule(ReactApplicationContext reactContext) {
        super(reactContext);
        context = reactContext;
    }

    @Override
    public String getName() {
        return "BaiduMapAppModule";
    }

    @ReactMethod
    public void getMapList(Promise promise){
        WritableArray array = Arguments.createArray();
        //是否安装有百度地图
        if(isAppInstalled(context,"com.baidu.BaiduMap")){
            array.pushString("百度地图");
        }
        if(isAppInstalled(context,"com.autonavi.minimap")){
            array.pushString("高德地图");
        }
        promise.resolve(array);
    }

    //调起百度地图app，规划路线
    @ReactMethod
    public void openBaiduMapTransitRoute(ReadableMap start, ReadableMap end) {
        RouteParaOption option = new RouteParaOption()
                .startPoint(LatLngUtil.fromReadableMap(start))
                .endPoint(LatLngUtil.fromReadableMap(end))
                .busStrategyType(RouteParaOption.EBusStrategyType.bus_recommend_way);
        try {
            BaiduMapRoutePlan.openBaiduMapTransitRoute(option, context);
        } catch (Exception e) {
            e.printStackTrace();
        }
        BaiduMapRoutePlan.finish(context);
    }

    //打开第三方导航app
    @ReactMethod
    public void openMapToDaoHan(ReadableMap data){
        double lat, lng;
        lat = data.getDouble("latitude");
        lng = data.getDouble("longitude");
        String mapType = data.getString("mapType");
        Intent intent;
        switch (mapType){
            case "百度地图":
                intent= new Intent("android.intent.action.VIEW",
                        android.net.Uri.parse("baidumap://map/geocoder?location=" + lat + "," + lng));
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK );
                context.startActivity(intent);
                break;
            case "高德地图":
                intent = new Intent("android.intent.action.VIEW",
                        android.net.Uri.parse("androidamap://route?sourceApplication=appName&slat=&slon=&sname=我的位置&dlat="+ lat +"&dlon="+ lng+"&dname=目的地&dev=0&t=2"));
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK );
                context.startActivity(intent);
                break;
        }

    }

    /**
     * 查看是否安装了这个导航软件
     * 高德地图 com.autonavi.minimap
     * 百度地图 com.baidu.BaiduMap
     * 腾讯地图 com.tencent.map
     *
     * @param context
     * @param packagename
     * @return
     */
    public boolean isAppInstalled(Context context, String packagename) {
        PackageInfo packageInfo;
        try {
            packageInfo = context.getPackageManager().getPackageInfo(packagename, 0);
        } catch (Exception e) {
            packageInfo = null;
            e.printStackTrace();
        }

        if (packageInfo == null) {
            return false;
        } else {
            return true;
        }
    }

}
