//
//  OverlayCircle.h
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/2/28.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "OverlayView.h"
#import <React/RCTConvert+CoreLocation.h>
#import "Stroke.h"

NS_ASSUME_NONNULL_BEGIN

@interface OverlayCircle : OverlayView

@property (nonatomic,assign) double radius;
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,copy) NSString *fillColor;

- (void)setCenterLatLng:(NSDictionary *)LatLngObj;

- (void)setStroke:(Stroke *)stroke;

@end

NS_ASSUME_NONNULL_END
