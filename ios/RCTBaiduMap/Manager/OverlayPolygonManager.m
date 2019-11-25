//
//  OverlayPolygonManager.m
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/3/1.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "OverlayPolygonManager.h"
#import "OverlayPolygon.h"

@implementation OverlayPolygonManager

RCT_EXPORT_MODULE(BaiduMapOverlayPolygon)

RCT_EXPORT_VIEW_PROPERTY(points, NSArray*)
RCT_EXPORT_VIEW_PROPERTY(fillColor, NSString)
RCT_EXPORT_VIEW_PROPERTY(visible, BOOL)

RCT_CUSTOM_VIEW_PROPERTY(stroke, CLLocationCoordinate2D, OverlayPolygon) {
    json ? [view setStroke:[Stroke getStroke:[RCTConvert NSDictionary:json]]] : nil;
}

- (UIView *)view {
    OverlayPolygon *view = [[OverlayPolygon alloc] init];
    return view;
}

@end
