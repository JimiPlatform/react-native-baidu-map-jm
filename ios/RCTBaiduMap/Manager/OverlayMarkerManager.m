//
//  OverlayMarkerManager.m
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/2/27.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "OverlayMarkerManager.h"

@implementation OverlayMarkerManager

RCT_EXPORT_MODULE(BaiduMapOverlayMarker)

RCT_EXPORT_VIEW_PROPERTY(tag, int)
RCT_EXPORT_VIEW_PROPERTY(title, NSString)
RCT_EXPORT_VIEW_PROPERTY(icon, id)
RCT_EXPORT_VIEW_PROPERTY(alpha, float)
RCT_EXPORT_VIEW_PROPERTY(isIteration, BOOL)
RCT_EXPORT_VIEW_PROPERTY(width, float)
RCT_EXPORT_VIEW_PROPERTY(height, float)
RCT_EXPORT_VIEW_PROPERTY(rotate, float)
RCT_EXPORT_VIEW_PROPERTY(flat, BOOL)
RCT_EXPORT_VIEW_PROPERTY(visible, BOOL)

RCT_CUSTOM_VIEW_PROPERTY(location, CLLocationCoordinate2D, OverlayMarker) {
    view.location = json ? [RCTConvert CLLocationCoordinate2D:json] : view.location;
}

- (UIView *)view {
    OverlayMarker *view = [[OverlayMarker alloc] init];
    return view;
}

@end
