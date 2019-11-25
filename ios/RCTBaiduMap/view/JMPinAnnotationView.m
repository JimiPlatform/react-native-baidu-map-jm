//
//  JMPinAnnotationView.m
//  JiMiPlatfromProject
//
//  Created by lzj<lizhijian_21@163.com> on 2019/4/26.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "JMPinAnnotationView.h"
#import "OverlayInfoWindow.h"

@interface JMPinAnnotationView()

@property (nonatomic,strong) UIImageView *imageView;

@end

@implementation JMPinAnnotationView

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if ([annotation isKindOfClass:[JMMarkerAnnotation class]]) {
        JMMarkerAnnotation *annotation1 = (JMMarkerAnnotation *)annotation;
        [self updateIcon:annotation1];
    }

    return self;
}

- (UIImageView *)imageView
{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-10, -10, 30, 30)];
        _imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_imageView];
    }

    return _imageView;
}

- (void)setImage:(UIImage *)image
{
    NSInteger width = image.size.width;
    NSInteger height = image.size.height;
    CGRect frame = CGRectMake(-width/2.0, -height/2.0, width, height);
    self.imageView.frame = frame;
    self.imageView.image = image;
}

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)updateIcon:(JMMarkerAnnotation *)annotation
{
    JMMarkerAnnotation *annotation1 = (JMMarkerAnnotation *)annotation;
    if (annotation1.iconDic != nil) {
        if (!annotation1.iconImage) {
            annotation1.iconImage = [annotation1 getImage];
        }

        if (annotation1.iconImage) {
            if (annotation1.rotate != 0) {
                self.image = [JMMarkerAnnotation imageRotated:annotation1.iconImage radians:annotation1.rotate];
            } else {
                self.image = annotation1.iconImage;
            }
        }
    } else {
        self.image = nil;
    }
}

@end
