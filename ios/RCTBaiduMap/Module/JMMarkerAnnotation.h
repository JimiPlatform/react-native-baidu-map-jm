//
//  MarkerPointAnnotation.h
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/2/28.
//  Copyright © 2019 jimi. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <UIKit/UIKit.h>
#include "OverlayMarker.h"
NS_ASSUME_NONNULL_BEGIN

@interface JMMarkerAnnotation : BMKPointAnnotation

@property (nonatomic, assign) int tag;
@property (nonatomic, strong) NSDictionary *iconDic;
@property (nonatomic, assign) float alpha;
@property (nonatomic, assign) float rotate;
@property (nonatomic, assign) BOOL flat;
@property (nonatomic, strong) OverlayMarker *markerView;
@property (nonatomic, strong) UIImage *iconImage;

- (UIImage *)getImage;

+ (UIImage *)imageRotated:(UIImage *)image radians:(CGFloat)radians;

- (BOOL)isDifIcon:(id)iconDic;

- (void)clear;

@end

NS_ASSUME_NONNULL_END
