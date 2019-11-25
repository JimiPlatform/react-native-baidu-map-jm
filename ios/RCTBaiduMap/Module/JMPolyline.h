//
//  JMPolyline.h
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/3/1.
//  Copyright © 2019 jimi. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKPolyline.h>

NS_ASSUME_NONNULL_BEGIN

@interface JMPolyline : BMKPolyline

@property (nonatomic,strong) UIColor *color;
@property (nonatomic,assign) float width;

@end

NS_ASSUME_NONNULL_END
