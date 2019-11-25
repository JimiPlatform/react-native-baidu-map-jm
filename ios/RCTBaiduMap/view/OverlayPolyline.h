//
//  OverlayPolyline.h
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/3/1.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "OverlayView.h"
#import "Stroke.h"
#import "JMPolyline.h"

NS_ASSUME_NONNULL_BEGIN

@interface OverlayPolyline : OverlayView

@property (nonatomic,strong) NSArray *points;
@property (nonatomic,copy) NSString *color;
@property (nonatomic,assign) float width;
//@property (nonatomic,assign) BOOL visible;

@end

NS_ASSUME_NONNULL_END
