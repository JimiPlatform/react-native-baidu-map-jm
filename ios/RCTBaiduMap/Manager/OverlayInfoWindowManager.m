//
//  OverlayInfoWindowManager.m
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/3/4.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "OverlayInfoWindowManager.h"
#import "OverlayInfoWindow.h"

//OverlayInfoWindow *gOverlayInfoWindow = nil;

@implementation OverlayInfoWindowManager

RCT_EXPORT_MODULE(BaiduMapOverlayInfoWindow)

RCT_EXPORT_VIEW_PROPERTY(tag, int)
RCT_EXPORT_VIEW_PROPERTY(visible, BOOL)

RCT_CUSTOM_VIEW_PROPERTY(location, CLLocationCoordinate2D, OverlayInfoWindow) {
    view.location = json ? [RCTConvert CLLocationCoordinate2D:json] : view.location;
}

- (UIView *)view {
    OverlayInfoWindow *view = [[OverlayInfoWindow alloc] init];
    view.tag = -1;

    return view;
}

@end
