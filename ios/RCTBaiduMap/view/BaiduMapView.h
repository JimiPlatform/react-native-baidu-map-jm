//
//  RCTBaiduMap.h
//  RCTBaiduMap
//
//  Created by lovebing on 4/17/2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#ifndef BaiduMapView_h
#define BaiduMapView_h


#import <React/RCTViewManager.h>
#import <React/RCTConvert+CoreLocation.h>
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Map/BMKPinAnnotationView.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <BaiduMapAPI_Map/BMKCircle.h>
#import <UIKit/UIKit.h>
#import "JMMarkerAnnotation.h"
#import "JMPinAnnotationView.h"

#define PAOPAOVIEW_TAG_EMPTY 1437898

#define PAOPAOVIEW_TAG_NOEMPTY 1437896


@interface BaiduMapView : BMKMapView <BMKMapViewDelegate>

@property (nonatomic,copy) RCTBubblingEventBlock onChange;
@property (nonatomic,assign) BOOL zoomControlsVisible;
@property (nonatomic,strong) NSArray *visualRange;

- (void)updateAnnotationView:(JMPinAnnotationView *)annotationView annotation:(JMMarkerAnnotation *)annotation dataDic:(NSDictionary *)dataDic;

- (void)setZoom:(float)zoom;
- (void)setCenterLatLng:(NSDictionary *)LatLngObj;

- (void)setMarkers:(NSArray *)markers;

- (void)setCorrectPerspective:(NSDictionary *)infoDic;

@end

#endif
