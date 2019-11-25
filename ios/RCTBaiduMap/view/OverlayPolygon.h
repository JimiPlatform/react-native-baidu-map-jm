//
//  OverlayPolygon.h
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/3/1.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "OverlayView.h"
#import "Stroke.h"

NS_ASSUME_NONNULL_BEGIN

@interface OverlayPolygon : OverlayView

@property (nonatomic,strong) NSArray *points;
@property (nonatomic,copy) NSString *fillColor;

- (void)setStroke:(Stroke *)stroke;

@end

NS_ASSUME_NONNULL_END
