package org.lovebing.reactnative.baidumap.module;

import android.text.TextUtils;

import com.baidu.mapapi.model.LatLng;
import com.baidu.mapapi.search.core.PoiInfo;
import com.baidu.mapapi.search.core.SearchResult;
import com.baidu.mapapi.search.geocode.GeoCodeResult;
import com.baidu.mapapi.search.geocode.OnGetGeoCoderResultListener;
import com.baidu.mapapi.search.geocode.ReverseGeoCodeResult;
import com.baidu.mapapi.search.poi.OnGetPoiSearchResultListener;
import com.baidu.mapapi.search.poi.PoiDetailResult;
import com.baidu.mapapi.search.poi.PoiDetailSearchResult;
import com.baidu.mapapi.search.poi.PoiIndoorResult;
import com.baidu.mapapi.search.poi.PoiNearbySearchOption;
import com.baidu.mapapi.search.poi.PoiResult;
import com.baidu.mapapi.search.poi.PoiSearch;
import com.baidu.mapapi.search.sug.OnGetSuggestionResultListener;
import com.baidu.mapapi.search.sug.SuggestionResult;
import com.baidu.mapapi.search.sug.SuggestionSearch;
import com.baidu.mapapi.search.sug.SuggestionSearchOption;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;

import java.util.List;

/*
 * COPYRIGHT. ShenZhen JiMi Technology Co., Ltd. 2019.
 * ALL RIGHTS RESERVED.
 *
 * No part of this publication may be reproduced, stored in a retrieval system, or transmitted,
 * on any form or by any means, electronic, mechanical, photocopying, recording,
 * or otherwise, without the prior written permission of ShenZhen JiMi Network Technology Co., Ltd.
 *
 * @ProjectName newsmarthome2.0
 * @Description: 百度地图检索功能
 * @Date 2019/3/15 17:01
 * @author HuangJiaLin
 * @version 2.0
 */
public class MapSearchModule extends BaseModule{
    //声明Sug检索
    private SuggestionSearch mSuggestionSearch;
    private SuggestionSearchOption mSuggestionSearchOption;

    private PoiSearch mPoiSearch;

    public MapSearchModule(ReactApplicationContext reactContext) {
        super(reactContext);

    }

    @Override
    public String getName() {
        return "BaiduSearchModule";
    }

    //Sug检索监听
    private OnGetSuggestionResultListener listener = new OnGetSuggestionResultListener() {
        @Override
        public void onGetSuggestionResult(SuggestionResult suggestionResult) {
            //处理sug检索结果
            List<SuggestionResult.SuggestionInfo> infolist = suggestionResult.getAllSuggestions();
            if(infolist != null){
                WritableMap params = Arguments.createMap();
                WritableArray list = Arguments.createArray();
                for (SuggestionResult.SuggestionInfo info : infolist){
                    //Log.e("info.ccity", "info.city" + info.city + "info.district" + info.district + "info.key" + info.key);
                    WritableMap attr = Arguments.createMap();
                    attr.putString("city", info.city);
                    attr.putString("district", info.district);
                    attr.putString("key", info.key);
                    if(info.pt != null){
                        attr.putDouble("latitude", info.pt.latitude);
                        attr.putDouble("longitude", info.pt.longitude);
                    } else {
                        attr.putDouble("latitude", 22.0);
                        attr.putDouble("longitude", 32.0);
                    }
                    list.pushMap(attr);
                }
                params.putArray("sugList", list);
                sendEvent("onGetSuggestionResult", params);
            }

        }
    };

    //发起检索
    @ReactMethod
    public void requestSuggestion(String city , String keyWords){
        if(mSuggestionSearch == null){
            mSuggestionSearch = SuggestionSearch.newInstance();
            mSuggestionSearch.setOnGetSuggestionResultListener(listener);
        }
        if(mSuggestionSearchOption == null)
            mSuggestionSearchOption = new SuggestionSearchOption();

        if (TextUtils.isEmpty(city)) {
            city = "中国";
        }

        mSuggestionSearch.requestSuggestion(mSuggestionSearchOption
                .city(city)
                .keyword(keyWords));

    }


    /**
     * POI周边检索
     * @param lat 经度
     * @param lng 纬度
     * @param radius 搜索半径
     * @param keyword 关键词
     */
    @ReactMethod
    public void poiSearchNearby(double lat, double lng, int radius, String keyword){
        if(mPoiSearch == null){
            mPoiSearch = PoiSearch.newInstance();
            mPoiSearch.setOnGetPoiSearchResultListener(poilistener);
        }
        mPoiSearch.searchNearby(new PoiNearbySearchOption()
                .location(new LatLng(lat, lng))
                .radius(radius)
                .keyword(keyword)
                .pageNum(3));

    }

    //坐标转地址
    public void reverseGeoCode(){

    }

//    public static void init(Context context){
//        SDKInitializer.initialize(context.getApplicationContext());
//        SDKInitializer.setHttpsEnable(true);
//    }

    //不使用时请销毁,释放资源
    @ReactMethod
    public void destroy(){
        if(mSuggestionSearch != null){
            mSuggestionSearch.destroy();
            mSuggestionSearch = null;
        }
        if(mPoiSearch != null){
            mPoiSearch.destroy();
            mPoiSearch = null;
        }

    }

    private OnGetPoiSearchResultListener poilistener = new OnGetPoiSearchResultListener() {
        @Override
        public void onGetPoiResult(PoiResult poiResult) {
            List<PoiInfo> infolist = poiResult.getAllPoi();
            if(infolist != null){
                WritableMap params = Arguments.createMap();
                WritableArray list = Arguments.createArray();
                for (PoiInfo info : infolist){
                    //info.ccity: info.city深圳市info.address广东省深圳市宝安区留仙二路中粮商务公园1栋13楼info.name广东淳锋律师事务所
                    //Log.e("info.ccity", "info.city" + info.city + "info.address" + info.address + "info.name" + info.name);
                    WritableMap attr = Arguments.createMap();
                    attr.putString("city", info.city);
                    attr.putString("address", info.address);
                    attr.putString("name", info.name);
                    list.pushMap(attr);
                }
                params.putArray("poiList", list);
                sendEvent("onGetPoiResult", params);
            }
        }
        @Override
        public void onGetPoiDetailResult(PoiDetailSearchResult poiDetailSearchResult) {

        }

        @Override
        public void onGetPoiIndoorResult(PoiIndoorResult poiIndoorResult) {

        }
        //新版本已废弃
        @Override
        public void onGetPoiDetailResult(PoiDetailResult poiDetailResult) {

        }
    };

    private OnGetGeoCoderResultListener reverseGeoCodeListener = new OnGetGeoCoderResultListener(){

        @Override
        public void onGetGeoCodeResult(GeoCodeResult geoCodeResult) {

        }

        @Override
        public void onGetReverseGeoCodeResult(ReverseGeoCodeResult reverseGeoCodeResult) {
            if (reverseGeoCodeResult == null || reverseGeoCodeResult.error != SearchResult.ERRORNO.NO_ERROR) {
                //没有找到检索结果
                return;
            } else {
                //详细地址
                String address = reverseGeoCodeResult.getAddress();
                //行政区号
                //int adCode = reverseGeoCodeResult. getCityCode();
            }
        }
    };

}
