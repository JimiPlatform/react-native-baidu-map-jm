//
//  OverlayInfoWindow.h
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/3/4.
//  Copyright © 2019 jimi. All rights reserved.
//
#import "OverlayView.h"
#import <React/RCTConvert+CoreLocation.h>

extern NSString * _Nullable const kBaiduMapViewChangeInfoWinfoTag;
extern NSString * _Nullable const kBaiduMapViewChangeInfoWinfoVisible;

NS_ASSUME_NONNULL_BEGIN

@interface OverlayInfoWindow : OverlayView

@property (nonatomic, assign) CLLocationCoordinate2D location;

@end

NS_ASSUME_NONNULL_END
