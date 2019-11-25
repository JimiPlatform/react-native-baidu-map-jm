//
//  OverlayArcManager.m
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/3/4.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "OverlayArcManager.h"
#import "OverlayArc.h"

@implementation OverlayArcManager

RCT_EXPORT_MODULE(BaiduMapOverlayArc)

RCT_EXPORT_VIEW_PROPERTY(points, NSArray*)
RCT_EXPORT_VIEW_PROPERTY(color, NSString)
RCT_EXPORT_VIEW_PROPERTY(width, float)
RCT_EXPORT_VIEW_PROPERTY(visible, BOOL)

- (UIView *)view {
    OverlayArc *view = [[OverlayArc alloc] init];
    return view;
}

@end
