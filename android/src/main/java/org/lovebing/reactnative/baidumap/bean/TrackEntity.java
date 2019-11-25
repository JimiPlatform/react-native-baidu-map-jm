package org.lovebing.reactnative.baidumap.bean;

import com.baidu.mapapi.model.LatLng;

/*
 * COPYRIGHT. ShenZhen JiMi Technology Co., Ltd. 2019.
 * ALL RIGHTS RESERVED.
 *
 * No part of this publication may be reproduced, stored in a retrieval system, or transmitted,
 * on any form or by any means, electronic, mechanical, photocopying, recording,
 * or otherwise, without the prior written permission of ShenZhen JiMi Network Technology Co., Ltd.
 *
 * @ProjectName MyMedia
 * @Description: 轨迹点
 * @Date 2019/3/25 15:43
 * @author HuangJiaLin
 * @version 2.0
 */
public class TrackEntity {
    public String startTime;
    public String endTime;
    public String durSecond;
    /**
     * imei号
     */
    private String imei;
    /**
     * 车牌号
     */
    private String vehicleNumber;
    /**
     * 纬度
     */
    private String lat;
    /**
     * 经度
     */
    private String lng;
    /**
     * GPS时间
     */
    private String gpsTime;
    /**
     * 方位
     */
    public int direction;
    /**
     * 位置
     */
    public String addr = "";
    /**
     * GPS速度
     */
    private double gpsSpeed = -1;
    /**
     * 地标名称
     */
    private String geoname;
    /**
     * 速度类型
     */
    private String speedType = "0";
    /**
     * 定位类型。1是卫星定位 2是基站定位 3是wifi定位
     */
    private String posType;

    public LatLng getLatLng() {
        if (getLat() != -200 && getLng() != -200) {
            return new LatLng(getLat(), getLng());
        }
        return null;
    }

    public String getImei() {
        return imei;
    }

    public void setImei(String imei) {
        this.imei = imei;
    }

    public String getVehicleNumber() {
        return vehicleNumber;
    }

    public void setVehicleNumber(String vehicleNumber) {
        this.vehicleNumber = vehicleNumber;
    }

    public double getLat() {
        double latlng = -200;
        if (lat != null){
            try {
                latlng = Double.valueOf(lat);
            }catch (Exception e){
                return latlng;
            }
            return latlng;
        }
        return latlng;
    }

    public void setLat(String lat) {
        this.lat = lat;
    }

    public double getLng() {
        double latlng = -200;
        if (lng != null){
            try {
                latlng = Double.valueOf(lng);
            }catch (Exception e){
                return latlng;
            }
            return latlng;
        }
        return latlng;
    }

    public void setLng(String lng) {
        this.lng = lng;
    }

    public String getGpsTime() {
        return gpsTime;
    }

    public void setGpsTime(String gpsTime) {
        this.gpsTime = gpsTime;
    }

    public int getDirection() {
        return direction;
    }

    public void setDirection(int direction) {
        this.direction = direction;
    }

    public double getGpsSpeed() {
        return gpsSpeed;
    }

    public void setGpsSpeed(double gpsSpeed) {
        this.gpsSpeed = gpsSpeed;
    }

    public String getGeoname() {
        return geoname;
    }

    public void setGeoname(String geoname) {
        this.geoname = geoname;
    }

    public String getSpeedType() {
        return speedType;
    }

    public void setSpeedType(String speedType) {
        this.speedType = speedType;
    }

    public String getPosType() {
        return posType;
    }

    public void setPosType(String posType) {
        this.posType = posType;
    }

    /**
     * 获取速度
     * @return
     */
    public String getSpeed() {

        String vSpeed = "";
        if (speedType != null && !speedType.equals("0")) {
            switch (speedType) {
                case "1":
                    vSpeed = "正常";
                    break;
                case "2":
                    vSpeed = "较快";
                    break;
                case "3":
                    vSpeed = "无";
                    break;
            }
        } else {
            if (gpsSpeed < 0){
                vSpeed = "无";

            }else{
                vSpeed =  String.format("%.1fkm/h",gpsSpeed);
            }
        }

        return vSpeed;
    }
}
