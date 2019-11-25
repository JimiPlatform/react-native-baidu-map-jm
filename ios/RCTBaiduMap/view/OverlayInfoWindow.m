//
//  OverlayInfoWindow.m
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/3/4.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "OverlayInfoWindow.h"
#import "Stroke.h"

NSString *const kBaiduMapViewChangeInfoWinfoTag = @"kBaiduMapViewChangeInfoWinfoTag";
NSString *const kBaiduMapViewChangeInfoWinfoVisible = @"kBaiduMapViewChangeInfoWinfoVisible";

@implementation OverlayInfoWindow

- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];

    [[NSNotificationCenter defaultCenter] postNotificationName:kBaiduMapViewChangeInfoWinfoTag object:nil];
}

- (void)setLocation:(CLLocationCoordinate2D)location
{
    _location = location;
}

- (void)setVisible:(BOOL)visible {
    [super setVisible:!visible];
    [[NSNotificationCenter defaultCenter] postNotificationName:kBaiduMapViewChangeInfoWinfoVisible object:nil];
}

@end
