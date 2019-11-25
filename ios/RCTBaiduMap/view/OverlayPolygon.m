//
//  OverlayPolygon.m
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/3/1.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "OverlayPolygon.h"
#import "JMPolygon.h"
#import "JMCircle.h"
#import <React/RCTConvert+CoreLocation.h>

@interface OverlayPolygon ()

@property (nonatomic,strong) JMPolygon *polygon;
@property (nonatomic,assign) CLLocationCoordinate2D *pointArray;    //需要释放！！！
@property (nonatomic,assign) NSUInteger pointCount;

@end

@implementation OverlayPolygon

- (void)dealloc
{
    if (_pointArray) {
        free(_pointArray);
        _pointArray = NULL;
    }
}

- (JMPolygon *)polygon
{
    if (!_polygon) {
        _polygon = [[JMPolygon alloc] init];
    }

    return _polygon;
}

- (void)addTopMap:(BMKMapView *)mapView
{
    [super addTopMap:mapView];
    [self display];
}

- (void)removeTopMap:(BMKMapView *)mapView
{
    [self hide];
    _polygon = nil;

    [super removeTopMap:mapView];
}

- (void)display
{
    [super display];
    if (!_polygon) return;

    if (self.visible) {
        [self.baiduMap addOverlay:self.polygon];
    } else {
        [self.baiduMap removeOverlay:self.polygon];
    }
}

- (void)hide
{
    [super hide];
    if (!_polygon) return;

    [self.baiduMap removeOverlay:self.polygon];
}

#pragma mark -

- (void)setFillColor:(NSString *)fillColor
{
    _fillColor = fillColor;
    self.polygon.fillColor = [Stroke colorWithHexString:fillColor];
}

- (void)setStroke:(Stroke *)stroke
{
    self.polygon.stroke = stroke;
}

- (void)setPoints:(NSArray *)points
{
    _points = points;
    if (_pointCount < points.count) {
        if (_pointArray) {
            free(_pointArray);
            _pointArray = NULL;
        }
    }
    
    if (_pointArray == NULL) {
        _pointArray  = (CLLocationCoordinate2D *)malloc(points.count * sizeof(CLLocationCoordinate2D));
    }
    _pointCount = points.count;

    for (int i=0; i<points.count; i++) {
        _pointArray[i].latitude = [[[points objectAtIndex:i] objectForKey:@"latitude"] doubleValue];
        _pointArray[i].longitude = [[[points objectAtIndex:i] objectForKey:@"longitude"] doubleValue];
    }
    
    [self.polygon setPolygonWithCoordinates:_pointArray count:_pointCount];
}

- (void)setVisible:(BOOL)visible
{
    [super setVisible:visible];
    [self display];
}

@end
