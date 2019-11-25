//
//  TrackUtils.m
//  JiMiPlatfromProject
//
//  Created by lzj<lizhijian_21@163.com> on 2019/4/10.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "TrackUtils.h"
#import <BMKLocationkit/BMKLocationComponent.h>

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

+ (void)setVisualRange:(BaiduMapView *)mapView pointArray:(NSArray *)points
{
    if (points.count == 0) {
        return;
    } else if (points.count == 1){
        BMKMapStatus *mapStatus = [[BMKMapStatus alloc] init];
        mapStatus.targetGeoPt = [self getCoordinate:[points firstObject]];
        mapStatus.fLevel = 18;
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

@end
