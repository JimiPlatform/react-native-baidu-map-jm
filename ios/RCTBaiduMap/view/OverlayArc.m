//
//  OverlayArc.m
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/3/4.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "OverlayArc.h"
#import "JMArc.h"
#import "Stroke.h"
#import <React/RCTConvert+CoreLocation.h>

@interface OverlayArc ()

@property (nonatomic,strong) JMArc *arcLine;
@property (nonatomic,assign) CLLocationCoordinate2D *pointArray;    //需要释放！！！

@end

@implementation OverlayArc

- (void)dealloc
{
    if (_pointArray) {
        free(_pointArray);
        _pointArray = NULL;
    }
}

- (JMArc *)arcLine
{
    if (!_arcLine) {
        _arcLine = [[JMArc alloc] init];
    }

    return _arcLine;
}

- (void)addTopMap:(BMKMapView *)mapView
{
    [super addTopMap:mapView];
    [self display];
}

- (void)removeTopMap:(BMKMapView *)mapView
{
    [self hide];
    _arcLine = nil;

    [super removeTopMap:mapView];
}

- (void)display
{
    [super display];
    if (!_arcLine) return;

    if (self.visible) {
        [self.baiduMap addOverlay:self.arcLine];
    } else {
        [self.baiduMap removeOverlay:self.arcLine];
    }
}

- (void)hide
{
    [super hide];
    if (!_arcLine) return;

    [self.baiduMap removeOverlay:self.arcLine];
}

#pragma mark -

- (void)setColor:(NSString *)color
{
    _color = color;
    self.arcLine.color = [Stroke colorWithHexString:color];
}

- (void)setWidth:(float)width
{
    _width = width;
    self.arcLine.width = width;
}

- (void)setPoints:(NSArray *)points
{
    if (points.count != 3) {
        return;
    }

    _points = points;
    if (_pointArray == NULL) {
        _pointArray  = (CLLocationCoordinate2D *)malloc(points.count * sizeof(CLLocationCoordinate2D));
    }

    for (int i=0; i<points.count; i++) {
        _pointArray[i].latitude = [[[points objectAtIndex:i] objectForKey:@"latitude"] doubleValue];
        _pointArray[i].longitude = [[[points objectAtIndex:i] objectForKey:@"longitude"] doubleValue];
    }

    [self.arcLine setArclineWithCoordinates:_pointArray];
}

- (void)setVisible:(BOOL)visible
{
    [super setVisible:visible];
    [self display];
}

@end
