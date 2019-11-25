package org.lovebing.reactnative.baidumap.module;

import com.baidu.location.BDLocation;
import com.baidu.location.BDLocationListener;
import com.baidu.location.LocationClient;
import com.baidu.location.LocationClientOption;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.Nullable;

public class LocationModule extends BaseModule implements BDLocationListener {
    public static String kLocationModuleCheckPermission = "kLocationModuleCheckPermission";
    public static String kLocationModuleFail = "kLocationModuleFail";
    public static String kLocationModuleUpdateLocation = "kLocationModuleUpdateLocation";
    public static String kLocationModuleChangeAuthorization = "kLocationModuleChangeAuthorization";
    public static String kLocationModuleUpdateNetworkState = "kLocationModuleUpdateNetworkState";
    public static String kLocationModuleUpdateHeading = "kLocationModuleUpdateHeading";

    private LocationClient locationClient;
    private int locationTimeout = 10000;    //10s
    private boolean allowsBackground = false;

    public LocationModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    public String getName() {
        return "BaiduLocationModule";
    }

    private void initLocationClient() {
        if (locationClient != null) return;
        locationClient = new LocationClient(context.getApplicationContext());

        LocationClientOption option = new LocationClientOption();
        option.setLocationMode(LocationClientOption.LocationMode.Hight_Accuracy);//可选，默认高精度，设置定位模式，高精度，低功耗，仅设备
        option.setCoorType("bd09ll");//可选，默认gcj02，设置返回的定位结果坐标系
        option.setScanSpan(1000);//可选，默认0，即仅定位一次，设置发起定位请求的间隔需要大于等于1000ms才是有效的
        option.setTimeOut(locationTimeout);
        option.setIsNeedAddress(false);//可选，设置是否需要地址信息，默认不需要
        option.setOpenGps(true);//可选，默认false,设置是否使用gps
        option.setLocationNotify(true);//可选，默认false，设置是否当gps有效时按照1S1次频率输出GPS结果
        option.setIsNeedLocationDescribe(false);//可选，默认false，设置是否需要位置语义化结果，可以在BDLocation.getLocationDescribe里得到，结果类似于“在北京天安门附近”
        option.setIsNeedLocationPoiList(false);//可选，默认false，设置是否需要POI结果，可以在BDLocation.getPoiList里得到
        option.setIgnoreKillProcess(false);//可选，默认true，定位SDK内部是一个SERVICE，并放到了独立进程，设置是否在stop的时候杀死这个进程，默认不杀死
        option.SetIgnoreCacheException(false);//可选，默认false，设置是否收集CRASH信息，默认收集
        option.setEnableSimulateGps(true);//可选，默认false，设置是否需要过滤gps仿真结果，默认需要

        locationClient.setLocOption(option);
        locationClient.registerLocationListener(this);
    }

    @Override
    public void onReceiveLocation(BDLocation bdLocation) {
        WritableMap params = Arguments.createMap();
        int locType = bdLocation.getLocType();
        if (locType == BDLocation.TypeServerError ||
                locType == BDLocation.TypeNetWorkException ||
                locType == BDLocation.TypeCriteriaException) {
            params.putInt("errcode", locType);
            params.putString("errmsg", "定位失败");
            sendEvent("kLocationModuleFail", params);
        } else {
            params.putDouble("latitude", bdLocation.getLatitude());
            params.putDouble("longitude", bdLocation.getLongitude());
            sendEvent(kLocationModuleUpdateLocation, params);
        }
    }

    @Nullable
    @Override
    public Map<String, Object> getConstants() {
        Map<String, Object> constants = new HashMap<>();
        constants.put(kLocationModuleCheckPermission, kLocationModuleCheckPermission);
        constants.put(kLocationModuleFail, kLocationModuleFail);
        constants.put(kLocationModuleUpdateLocation, kLocationModuleUpdateLocation);
        constants.put(kLocationModuleChangeAuthorization, kLocationModuleChangeAuthorization);
        constants.put(kLocationModuleUpdateNetworkState, kLocationModuleUpdateNetworkState);
        constants.put(kLocationModuleUpdateHeading, kLocationModuleUpdateHeading);
        return constants;
    }

    @ReactMethod
    public void config(String key) {
        WritableMap params = Arguments.createMap();
        params.putInt("errcode", 0);
        params.putString("errmsg", "Success");
        sendEvent(kLocationModuleCheckPermission, params);
    }

    @ReactMethod
    public void locationTimeout(int time) {
        locationTimeout = time;
    }

    @ReactMethod
    public void allowsBackground(boolean allows) {
        allowsBackground = allows;
    }

    @ReactMethod
    public void startUpdatingLocation() {
        initLocationClient();
        locationClient.start();
    }

    @ReactMethod
    public void stopUpdatingLocation() {
        if (locationClient != null) {
            locationClient.stop();
            locationClient = null;
        }
    }

    @ReactMethod
    public void startUpdatingHeading() {
    }

    @ReactMethod
    public void stopUpdatingHeading() {
    }
}
