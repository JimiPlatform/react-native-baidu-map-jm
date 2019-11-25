//
//  BaiduMapOverlayMarker.h
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/2/27.
//  Copyright © 2019 jimi. All rights reserved.
//

#import <React/RCTViewManager.h>
#import <React/RCTConvert+CoreLocation.h>
#import <React/RCTConvert.h>
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Map/BMKOverlayView.h>
#import <BaiduMapAPI_Map/BMKAnnotationView.h>
#import <BaiduMapAPI_Map/BMKAnnotation.h>
#import <UIKit/UIKit.h>

#ifndef OverlayMarker_h
#define OverlayMarker_h

@interface OverlayMarker : BMKAnnotationView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) id icon;
@property (nonatomic, assign) float alpha;
@property (nonatomic, assign) float rotate;
@property (nonatomic, assign) BOOL flat;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, assign) BOOL visible;

@end

#endif
