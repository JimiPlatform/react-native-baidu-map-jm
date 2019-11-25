//
//  TrackUtils.h
//  JiMiPlatfromProject
//
//  Created by lzj<lizhijian_21@163.com> on 2019/4/10.
//  Copyright © 2019 jimi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaiduMapView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TrackUtils : NSObject

+ (CLLocationCoordinate2D)getCoordinate:(NSDictionary *)coordinateDic;

/**
 将GPS坐标字典转百度地图坐标

 @param coordinateDic GPS坐标字典
 @return 百度地图坐标
 */
+ (CLLocationCoordinate2D)getCoordinateBaidu:(NSDictionary *)coordinateDic;

/**
 将GPS坐标字典数组转百度地图坐标字典数组

 @param array GPS坐标数组
 @return 百度地图坐标数组
 */
+ (NSArray *)gpsConversionBaidu:(NSArray *)array;

/**
 将显示坐标点中心，并缩放适当比例

 @param mapView 百度地图
 @param points 坐标数组
 */
+ (void)setVisualRange:(BaiduMapView *)mapView pointArray:(NSArray *)points;

@end

NS_ASSUME_NONNULL_END
