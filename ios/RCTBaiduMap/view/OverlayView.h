//
//  OverlayView.h
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/2/28.
//  Copyright © 2019 jimi. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKCircleView.h>
#import <BaiduMapAPI_Map/BMKMapView.h>

NS_ASSUME_NONNULL_BEGIN

@interface OverlayView : UIView

@property (nonatomic, strong) BMKMapView *baiduMap;
@property (nonatomic, assign) BOOL visible;

/**
 往地图注入BMKOverlay，继承的视图需要重写并实现

 @param mapView 父视图-地图
 */
- (void)addTopMap:(BMKMapView *)mapView;

- (void)removeTopMap:(BMKMapView *)mapView;

- (void)display;

- (void)hide;

@end

NS_ASSUME_NONNULL_END
