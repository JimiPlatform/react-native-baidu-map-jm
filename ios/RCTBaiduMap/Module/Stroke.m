//
//  Stroke.m
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/3/1.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "Stroke.h"
#import <React/RCTConvert.h>

@implementation Stroke

+ (Stroke *)getStroke:(NSDictionary *)StrokeObj
{
    if (StrokeObj) {
        int width = [RCTConvert int:StrokeObj[@"width"]];
        NSString *color = [RCTConvert NSString:StrokeObj[@"color"]];

        Stroke *stroke = [[Stroke alloc] init];
        stroke.lineWidth = width;
        stroke.strokeColor = [Stroke colorWithHexString:color];

        return stroke;
    }

    return nil;
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    //去除空格
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    //把开头截取
    if ([cString hasPrefix:@"0x"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    //6位或8位(带透明度)
    if ([cString length] < 6) {
        return nil;
    }
    //取出透明度、红、绿、蓝
    unsigned int a, r, g, b;
    NSRange range;
    range.location = 0;
    range.length = 2;
    if (cString.length == 8) {
        //r
        NSString *rString = [cString substringWithRange:range];
        //g
        range.location = 2;
        NSString *gString = [cString substringWithRange:range];
        //b
        range.location = 4;
        NSString *bString = [cString substringWithRange:range];
        //a
        range.location = 6;
        NSString *aString = [cString substringWithRange:range];

        [[NSScanner scannerWithString:aString] scanHexInt:&a];
        [[NSScanner scannerWithString:rString] scanHexInt:&r];
        [[NSScanner scannerWithString:gString] scanHexInt:&g];
        [[NSScanner scannerWithString:bString] scanHexInt:&b];

        return [UIColor colorWithRed:(r / 255.0f) green:(g / 255.0f) blue:(b / 255.0f) alpha:(a / 255.0f)];
    } else {
        //r
        NSString *rString = [cString substringWithRange:range];
        //g
        range.location = 2;
        NSString *gString = [cString substringWithRange:range];
        //b
        range.location = 4;
        NSString *bString = [cString substringWithRange:range];

        [[NSScanner scannerWithString:rString] scanHexInt:&r];
        [[NSScanner scannerWithString:gString] scanHexInt:&g];
        [[NSScanner scannerWithString:bString] scanHexInt:&b];

        return [UIColor colorWithRed:(r / 255.0f) green:(g / 255.0f) blue:(b / 255.0f) alpha:1.0];
    }
}

@end
