//
//  JMCircle.h
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/3/1.
//  Copyright © 2019 jimi. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKCircle.h>
#import "Stroke.h"

NS_ASSUME_NONNULL_BEGIN

@interface JMCircle : BMKCircle

@property (nonatomic,strong) UIColor *fillColor;
@property (nonatomic,strong) Stroke *stroke;

@end

NS_ASSUME_NONNULL_END
