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
@property (nonatomic,strong) UIView *backgroundView;

@end

@implementation JMPinAnnotationView

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if ([annotation isKindOfClass:[JMMarkerAnnotation class]]) {
        JMMarkerAnnotation *annotation1 = (JMMarkerAnnotation *)annotation;
        self.frame = CGRectMake(0, 0, 30, 30);
        [self updateIcon:annotation1];
    }
  
    return self;
}
- (UIView *)backgroundView{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//        _backgroundView.userInteractionEnabled = true;
        [self addSubview:_backgroundView];
    }
    return _backgroundView;
}
- (UIImageView *)imageView
{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _imageView.contentMode = UIViewContentModeCenter;
        _imageView.userInteractionEnabled = true;
        [self addSubview:_imageView];
    }

    return _imageView;
}

- (void)setImage:(UIImage *)image
{
    NSInteger width = image.size.width;
    NSInteger height = image.size.height;
    CGRect frame = CGRectMake(0, 0, width, height);
    self.frame = CGRectMake(0, 0, width, height);
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
    if (annotation1.markerView != nil) {
        for (UIView *view in self.backgroundView.subviews) {
            if ([view isKindOfClass:[OverlayMarker class]]) {
                NSArray<UIGestureRecognizer *> *taps = [view gestureRecognizers];
                for (UIGestureRecognizer *gest in taps) {
                    [view removeGestureRecognizer:gest];
                }
            }
//            [view removeFromSuperview];
        }
        [self.backgroundView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        OverlayMarker *markerView = annotation1.markerView;
        [self.backgroundView addSubview:markerView];
        markerView.frame = CGRectMake(0, 0, 30, 30);
    }
}
@end
