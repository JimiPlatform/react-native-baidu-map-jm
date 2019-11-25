//
//  JMArc.h
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/3/4.
//  Copyright © 2019 jimi. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKArcline.h>

NS_ASSUME_NONNULL_BEGIN

@interface JMArc : BMKArcline

@property (nonatomic,strong) UIColor *color;
@property (nonatomic,assign) float width;

@end

NS_ASSUME_NONNULL_END
