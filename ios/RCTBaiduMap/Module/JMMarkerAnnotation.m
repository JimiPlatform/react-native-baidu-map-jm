//
//  MarkerPointAnnotation.m
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/2/28.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "JMMarkerAnnotation.h"
#import <React/RCTConvert.h>

@implementation JMMarkerAnnotation

- (instancetype)init
{
    if (self = [super init]) {
        _tag = -1;
    }
    return self;
}

- (UIImage *)getImage
{
    if (self.iconDic) {
        UIImage *img = [RCTConvert UIImage:self.iconDic];
        return img;
    }

    return nil;
}

+ (UIImage *)imageRotated:(UIImage *)image radians:(CGFloat)radians
{
    NSInteger num = (NSInteger)(floor(radians));
    if (!image || (num == radians && num % 360 == 0)) {
        return image;
    }
    double radius = -radians * M_PI / 180;

    CGSize rotatedSize = image.size;
    UIGraphicsBeginImageContextWithOptions(rotatedSize, false, [UIScreen mainScreen].scale);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, -rotatedSize.height/2);
    CGContextRotateCTM(bitmap, radius);
    CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, image.size.width, image.size.height), [image CGImage]);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

- (BOOL)isDifIcon:(id)iconDic
{
    if (!_iconDic || (self.iconDic && !iconDic)) return YES;

    NSString *newIcon = [iconDic objectForKey:@"uri"];
    NSString *oldIcon = [self.iconDic objectForKey:@"uri"];

    return (newIcon && oldIcon && ![newIcon isEqualToString:oldIcon]);
}

- (void)clear
{
    _iconDic = nil;
    _rotate = 0;
}

@end
