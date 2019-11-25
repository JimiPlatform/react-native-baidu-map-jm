//
//  OverlayCircle.m
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/2/28.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "OverlayCircle.h"
#import "JMCircle.h"

@interface OverlayCircle ()

@property (nonatomic, strong) JMCircle *circle;

@end

@implementation OverlayCircle

- (JMCircle *)circle
{
    if (!_circle) {
        _circle = [[JMCircle alloc] init];
    }

    return _circle;
}

- (void)addTopMap:(BMKMapView *)mapView
{
    [super addTopMap:mapView];
    [self display];
}

- (void)removeTopMap:(BMKMapView *)mapView
{
    [self hide];
    _circle = nil;

    [super removeTopMap:mapView];
}

- (void)display
{
    [super display];
    if (!_circle) return;
    [self hide];

    if (self.visible) {
        [self.baiduMap addOverlay:self.circle];
    } else {
        [self.baiduMap removeOverlay:self.circle];
    }
}

- (void)hide
{
    [super hide];
    if (!_circle) return;

    [self.baiduMap removeOverlay:self.circle];
}

#pragma mark -

- (void)setCenterLatLng:(NSDictionary *)LatLngObj {
    if (LatLngObj) {
        double lat = 0;
        double lng = 0;
        if (LatLngObj[@"center"]) {  //lzj fixed
            NSDictionary *Dic = [LatLngObj objectForKey:@"center"];
            lat = [[Dic objectForKey:@"latitude"] doubleValue];
            lng = [[Dic objectForKey:@"longitude"] doubleValue];
        } else {
            lat = [RCTConvert double:LatLngObj[@"latitude"]];
            lng = [RCTConvert double:LatLngObj[@"longitude"]];
        }
        CLLocationCoordinate2D point = CLLocationCoordinate2DMake(lat, lng);

        _coordinate = point;
        self.circle.coordinate = point;
        if (self.circle.radius != 0) {
            [self display];
        }
    }
}

- (void)setRadius:(double)radius
{
    _radius = radius;
    self.circle.radius = radius;
    if (self.circle.coordinate.latitude != 0 && self.circle.coordinate.longitude != 0) {
        [self display];
    }
}

- (void)setFillColor:(NSString *)fillColor
{
    _fillColor = fillColor;
    self.circle.fillColor = [Stroke colorWithHexString:fillColor];
}

- (void)setStroke:(Stroke *)stroke
{
    self.circle.stroke = stroke;
}

- (void)setVisible:(BOOL)visible
{
    [super setVisible:visible];
    [self display];
}

@end
