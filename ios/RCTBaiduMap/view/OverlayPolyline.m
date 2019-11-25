//
//  OverlayPolyline.m
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/3/1.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "OverlayPolyline.h"

@interface OverlayPolyline ()

@property (nonatomic,strong) JMPolyline *polyline;

@end

@implementation OverlayPolyline

- (JMPolyline *)polyline
{
    if (!_polyline) {
        _polyline = [[JMPolyline alloc] init];
    }

    return _polyline;
}

- (void)addTopMap:(BMKMapView *)mapView
{
    [super addTopMap:mapView];
    [self display];
}

- (void)removeTopMap:(BMKMapView *)mapView
{
    [self hide];
    _polyline = nil;
    
    [super removeTopMap:mapView];
}

- (void)display
{
    [super display];
    if (!_polyline) return;

    if (self.visible) {
        if (_points && self.points.count > 0) {
            [self.baiduMap addOverlay:self.polyline];
        }
    } else {
        [self.baiduMap removeOverlay:self.polyline];
    }
}

- (void)hide
{
    [super hide];
    if (!_polyline) return;

    [self.baiduMap removeOverlay:self.polyline];
}

#pragma mark -

- (void)setColor:(NSString *)color
{
    _color = color;
    self.polyline.color = [Stroke colorWithHexString:color];
}

- (void)setWidth:(float)width
{
    _width = width;
    self.polyline.width = width;
}

- (void)setPoints:(NSArray *)points
{
    _points = points;
    if (_points == nil || self.points.count == 0) {
        [self hide];
        return;
    }

    CLLocationCoordinate2D *coords = (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * self.points.count);
    for (int i = 0; i < self.points.count; i++) {
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake([[[self.points objectAtIndex:i] objectForKey:@"latitude"] doubleValue], [[[self.points objectAtIndex:i] objectForKey:@"longitude"] doubleValue]);
        coords[i] = coor;
    }

    [self.polyline setPolylineWithCoordinates:coords count:self.points.count];
    free(coords);

    [self display];
}

- (void)setVisible:(BOOL)visible
{
    [super setVisible:visible];
    [self display];
}

@end
