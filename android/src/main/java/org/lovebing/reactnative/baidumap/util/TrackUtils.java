package org.lovebing.reactnative.baidumap.util;

import android.graphics.Bitmap;
import android.graphics.Matrix;

import com.baidu.mapapi.map.BaiduMap;
import com.baidu.mapapi.map.MapStatusUpdate;
import com.baidu.mapapi.map.MapStatusUpdateFactory;
import com.baidu.mapapi.map.PolylineOptions;
import com.baidu.mapapi.model.LatLng;
import com.baidu.mapapi.model.LatLngBounds;
import com.baidu.mapapi.utils.CoordinateConverter;
import com.baidu.mapapi.utils.DistanceUtil;

import java.util.ArrayList;
import java.util.List;

public class TrackUtils {
    //private BaiduMap baiduMap;
    //private List<LatLng> mPoints = new ArrayList<>(); //轨迹点集合
   // private List<LatLng> mTracks; //轨迹点详情

    /**
     *  原始gps坐标集转换百度坐标集
     * @param tracks 从服务器获取的GPS信息列表
     * @return 百度坐标点集合
     */
    public static List<LatLng> gpsConversionBaidu(List<LatLng> tracks){
        List<LatLng> points = new ArrayList<>();
        for(LatLng latLng : tracks){
            points.add(gpsConversionBaidu(latLng));
        }
        return points;
    }

    /**
     * 将设备采集到的GPS坐标转成百度坐标
     * @param pLatLng 坐标对象
     * @return 百度坐标
     */
    public static LatLng gpsConversionBaidu(LatLng pLatLng){
        // 将GPS设备采集的原始GPS坐标转换成百度坐标
        CoordinateConverter converter = new CoordinateConverter();
        converter.from(CoordinateConverter.CoordType.GPS);
        // sourceLatLng待转换坐标
        converter.coord(pLatLng);
        LatLng desLatLng = converter.convert();
        return desLatLng;
    }

    /**
     * 全部点的轨迹
     */
    public void drawAllTracks(BaiduMap baiduMap ,List<LatLng> points ,int lineColor){
        PolylineOptions ooPolyline = new PolylineOptions().width(8).color(lineColor).points(points);

    }

    /**
     * 调整所有设备位置到屏幕可见范围内
     * @param points
     * @param pMap
     */
    public static void setAllinVisibleRange(BaiduMap pMap, List<LatLng> points){
        if(points.size() == 0)
            return;
        if (points.size() == 1){
            if (points.get(0) != null){
                //设置图片中心点
                //MapStatusUpdate mapStatusUpdate = MapStatusUpdateFactory.newLatLng(points.get(0));
                //设置图片中心点和图片的放缩级别
                MapStatusUpdate mapStatusUpdate = MapStatusUpdateFactory.newLatLngZoom(points.get(0), pMap.getMaxZoomLevel() - 3);
                pMap.animateMapStatus(mapStatusUpdate);
            }
            return;
        }
        LatLng latMax = null, latMin = null, lngMax = null, lngMin = null;
        for (int i = 0; i < points.size(); i++){
            LatLng vMyLatLng = points.get(i);
            if (latMax == null) {
                latMax = vMyLatLng;
                latMin = vMyLatLng;
                lngMax = vMyLatLng;
                lngMin = vMyLatLng;
            } else {
                if (vMyLatLng.latitude > latMax.latitude) latMax = vMyLatLng;
                if (vMyLatLng.latitude < latMin.latitude) latMin = vMyLatLng;
                if (vMyLatLng.longitude > lngMax.longitude) lngMax = vMyLatLng;
                if (vMyLatLng.longitude < lngMin.longitude) lngMin = vMyLatLng;
            }
        }

        LatLng northeast = new LatLng(latMin.latitude, lngMax.longitude);
        LatLng southwest = new LatLng(latMax.latitude, lngMin.longitude);
        //地理范围数据结构，由西南以及东北坐标点确认
        LatLngBounds latLngBounds = new LatLngBounds.Builder().include(northeast).include(southwest).build();
        MapStatusUpdate mapStatusUpdate = MapStatusUpdateFactory.newLatLngBounds(latLngBounds);
        pMap.animateMapStatus(mapStatusUpdate);
    }

    /**
     * 通过坐标集合计算总里程
     */
    public static double getTotalDistance(List<LatLng> points){
        double vDistance = 0;
        for (int i = 0; i < points.size(); i++){
            if (i > 0){
                LatLng vMylatlng1 = points.get(i - 1);
                LatLng vMylatlng2 = points.get(i);
                vDistance += getDistance(vMylatlng1, vMylatlng2);
            }
        }
        //String.format("%.2f km", vDistance);
        return vDistance;
    }

    private static double DEF_PI180 = 0.01745329252; // PI/180.0
    private static double DEF_R = 6370693.5; // radius of earth
    /**
     * 计算两点之间距离
     * @param start
     * @param end
     * @return 米
     */
    public static double getDistance(LatLng start, LatLng end) {
        double ew1, ns1, ew2, ns2;
        double distance = 0;
        // 角度转换为弧度
        ew1 = start.longitude * DEF_PI180;
        ns1 = start.latitude * DEF_PI180;
        ew2 = end.longitude * DEF_PI180;
        ns2 = end.latitude * DEF_PI180;
        // 求大圆劣弧与球心所夹的角(弧度)
        distance = Math.sin(ns1) * Math.sin(ns2) + Math.cos(ns1)
                * Math.cos(ns2) * Math.cos(ew1 - ew2);
        // 调整到[-1..1]范围内，避免溢出
        if (distance > 1.0)
            distance = 1.0;
        else if (distance < -1.0)
            distance = -1.0;
        // 求大圆劣弧长度
        distance = DEF_R * Math.acos(distance);
        return distance / 1000;

    }

    public  static Bitmap zoomImg(Bitmap bm, int newWidth, int newHeight) {
        //获得图片的宽高
        int width = bm.getWidth();
        int height = bm.getHeight();
        //计算缩放比例
        float scaleWidth = ((float) newWidth) / width;
        float scaleHeight = ((float) newHeight) / height;
        //取得想要缩放的matrix参数
        Matrix matrix = new Matrix();
        matrix.postScale(scaleWidth, scaleHeight);
        //得到新的图片
        return Bitmap.createBitmap(bm, 0, 0, width, height, matrix, true);
    }

    /**
     * 根据两个点，切割成数个小点
     *
     * @param local1
     * @param local2
     */
    private List<LatLng> addLatLng(LatLng local1, LatLng local2) {
        final Double a_x = local1.latitude;
        final Double a_y = local1.longitude;
        final Double b_x = local2.latitude;
        final Double b_y = local2.longitude;
        final Double distance = DistanceUtil.getDistance(local1, local2);
        final Double partX = Math.abs(a_x - b_x) / distance;
        final Double partY = Math.abs(a_y - b_y) / distance;
        final List<LatLng> list = new ArrayList<>();
        for (int i = 0; i < distance; i++) {
            if (i % 5 == 0) {
                Double x;
                if (a_x < b_x) x = a_x + partX * i;
                else if (a_x > b_x) x = a_x - partX * i;
                else x = a_x;
                Double y;
                if (a_y < b_y) y = a_y + partY * i;
                else if (a_y > b_y) y = a_y - partY * i;
                else y = a_y;
                list.add(new LatLng(x, y));
            }
        }
        list.add(local2);
        return list;
    }
    //https://www.jianshu.com/p/fc1123fcc10d
}
