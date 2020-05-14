//
//  TrackUtils.m
//  JiMiPlatfromProject
//
//  Created by lzj<lizhijian_21@163.com> on 2019/4/10.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "TrackUtils.h"
#import <BMKLocationkit/BMKLocationComponent.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
@implementation TrackUtils

+ (CLLocationCoordinate2D)getCoordinate:(NSDictionary *)coordinateDic
{
    CLLocationCoordinate2D coor = {0,0};
    if (coordinateDic) {
        double lat = [[coordinateDic objectForKey:@"latitude"] doubleValue];
        double lng = [[coordinateDic objectForKey:@"longitude"] doubleValue];
        coor = CLLocationCoordinate2DMake(lat, lng);
    }

    return coor;
}

+ (CLLocationCoordinate2D)getCoordinateBaidu:(NSDictionary *)coordinateDic
{
    CLLocationCoordinate2D coor = [self getCoordinate:coordinateDic];
    BMKLocationCoordinateType srctype = BMKLocationCoordinateTypeWGS84;
    BMKLocationCoordinateType destype = BMKLocationCoordinateTypeBMK09LL;   //lzj fixed
    coor = [BMKLocationManager BMKLocationCoordinateConvert:coor SrcType:srctype DesType:destype];

    return coor;
}

+ (NSArray *)gpsConversionBaidu:(NSArray *)array
{
    NSMutableArray *dataArray = [NSMutableArray array];
    for (NSDictionary *data in array) {
        CLLocationCoordinate2D baiduCoor = [self getCoordinateBaidu:data];
        [dataArray addObject:@{@"latitude": [NSNumber numberWithDouble:baiduCoor.latitude],
                               @"longitude": [NSNumber numberWithDouble:baiduCoor.longitude]}];
    }

    return dataArray;
}

+ (void)setVisualRange:(BaiduMapView *)mapView pointArray:(NSArray *)points fLevel:(float)fLevel
{
    if ([TrackUtils judgeVisualRangeWithMap:mapView pointArray:points]) {//坐标点在可视区域内不做处理
        return;
    }
    if (points.count == 0) {
        return;
    } else if (points.count == 1){
        BMKMapStatus *mapStatus = [[BMKMapStatus alloc] init];
        mapStatus.targetGeoPt = [self getCoordinate:[points firstObject]];
        mapStatus.fLevel = fLevel;
        [mapView setMapStatus:mapStatus withAnimation:YES];
    } else {
        double latMax = 0, latMin = 0, lngMax = 0, lngMin = 0;
        for (NSDictionary *data in points) {
            CLLocationDegrees lat = [[data objectForKey:@"latitude"] doubleValue];
            CLLocationDegrees lng = [[data objectForKey:@"longitude"] doubleValue];
            if (latMax == 0) {
                latMax = lat;
                latMin = lat;
                lngMax = lng;
                lngMin = lng;
            } else {
                if (lat > latMax) latMax = lat;
                else if (lat < latMin) latMin = lat;
                if (lng > lngMax) lngMax = lng;
                else if (lng < lngMin) lngMin = lng;
            }
        }

        CGRect frame = [mapView convertRegion:BMKCoordinateRegionMake(CLLocationCoordinate2DMake((latMax-latMin)/2.0 + latMin, (lngMax-lngMin)/2.0 + lngMin), BMKCoordinateSpanMake(latMax-latMin, lngMax - lngMin)) toRectToView:mapView];
        BMKMapRect rect = [mapView convertRect:frame toMapRectFromView:mapView];
        [mapView fitVisibleMapRect:rect edgePadding:UIEdgeInsetsMake(20, 20, 20, 20) withAnimated:YES];
    }
}
//坐标点是否在可视区域内
+(BOOL)isItOnTheScreenAndBMKMapView:(BMKMapView *)mapView AndCLLocationCoordinate2D:(CLLocationCoordinate2D)coor{
    // 当前屏幕中心点的经纬度
    double centerLongitude = mapView.region.center.longitude;
    double centerLatitude = mapView.region.center.latitude;
    //当前屏幕显示范围的经纬度
    CLLocationDegrees pointssLongitudeDelta = mapView.region.span.longitudeDelta;
    CLLocationDegrees pointssLatitudeDelta = mapView.region.span.latitudeDelta;
    double leftUpLong = centerLongitude + pointssLongitudeDelta/2.0;
    double leftUpLati = centerLatitude - pointssLatitudeDelta/2.0;
    double leftDownLong = centerLongitude - pointssLongitudeDelta/2.0;
    double leftDownlati = centerLatitude - pointssLatitudeDelta/2.0;
    double rightDownLong = centerLongitude - pointssLongitudeDelta/2.0;
    double rightDownLati = centerLatitude + pointssLatitudeDelta/2.0;
    double rightUpLong = centerLongitude + pointssLongitudeDelta/2.0;
    double rightUpLati = centerLatitude + pointssLatitudeDelta/2.0;
    //构造BMKPolygonContainsCoordinate函数的参数数组
    CLLocationCoordinate2D coordinates[4];
    coordinates[0].latitude = leftUpLati;
    coordinates[0].longitude = leftUpLong;
    coordinates[1].latitude = leftDownlati;
    coordinates[1].longitude = leftDownLong;
    coordinates[2].latitude =  rightDownLati;
    coordinates[2].longitude = rightDownLong;
    coordinates[3].latitude = rightUpLati;
    coordinates[3].longitude = rightUpLong;
    return BMKPolygonContainsCoordinate(coor,coordinates,4);
}
//坐标点数组是否在可视区域内
+ (BOOL)judgeVisualRangeWithMap:(BaiduMapView *)mapView pointArray:(NSArray *)points{
    //当前屏幕显示范围的经纬度
    for (NSDictionary *data in points) {
        CLLocationDegrees lat = [[data objectForKey:@"latitude"] doubleValue];
        CLLocationDegrees lng = [[data objectForKey:@"longitude"] doubleValue];
        if (![TrackUtils isItOnTheScreenAndBMKMapView:mapView AndCLLocationCoordinate2D:CLLocationCoordinate2DMake(lat, lng)]) {
            return false;
        }
    }
    return true;
}
@end
