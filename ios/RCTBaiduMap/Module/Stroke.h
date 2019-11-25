//
//  Stroke.h
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/3/1.
//  Copyright © 2019 jimi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Stroke : NSObject

@property (nonatomic,strong) UIColor *strokeColor;
@property (nonatomic,assign) int lineWidth;

+ (Stroke *)getStroke:(NSDictionary *)StrokeObj;


+ (UIColor *)colorWithHexString:(NSString *)hexString;

@end

NS_ASSUME_NONNULL_END
