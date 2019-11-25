//
//  OverlayPolylineManager.m
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/3/1.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "OverlayPolylineManager.h"
#import "OverlayPolyline.h"

@implementation OverlayPolylineManager

RCT_EXPORT_MODULE(BaiduMapOverlayPolyline)

RCT_EXPORT_VIEW_PROPERTY(points, NSArray*)
RCT_EXPORT_VIEW_PROPERTY(color, NSString)
RCT_EXPORT_VIEW_PROPERTY(width, float)
RCT_EXPORT_VIEW_PROPERTY(visible, BOOL)

- (UIView *)view {
    OverlayPolyline *view = [[OverlayPolyline alloc] init];
    return view;
}

@end
