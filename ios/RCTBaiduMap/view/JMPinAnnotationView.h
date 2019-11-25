//
//  JMPinAnnotationView.h
//  JiMiPlatfromProject
//
//  Created by lzj<lizhijian_21@163.com> on 2019/4/26.
//  Copyright © 2019 jimi. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKAnnotationView.h>
#import <UIKit/UIKit.h>
#import "JMMarkerAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

@interface JMPinAnnotationView : BMKAnnotationView

- (void)updateIcon:(JMMarkerAnnotation *)annotation;

@end

NS_ASSUME_NONNULL_END
