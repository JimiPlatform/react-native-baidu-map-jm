//
//  OverlayView.m
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/2/28.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "OverlayView.h"
#import <React/RCTConvert.h>

@implementation OverlayView

- (void)addTopMap:(BMKMapView *)mapView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeFromMapView:) name:@"kRemoveMapViewFromSuperview" object:nil];
    _baiduMap = mapView;
}

- (void)removeTopMap:(BMKMapView *)mapView
{
    _baiduMap = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    [self removeTopMap:_baiduMap];
}

- (void)display
{
    if (!self.baiduMap) return;
}

- (void)hide
{
    if (!self.baiduMap) return;
}

- (void)removeFromMapView:(NSNotification *)noti
{
    BMKMapView *mapView = noti.object;
    if (_baiduMap && mapView == _baiduMap) {
        [self removeTopMap:mapView];
    }
}

@end
