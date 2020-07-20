//
//  BaiduMapOverlayMarker.m
//  JMSmallAppEngine
//
//  Created by lzj<lizhijian_21@163.com> on 2019/2/27.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "OverlayMarker.h"

@implementation OverlayMarker
//- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)atIndex{
//    NSLog(@"subview  = %@  atIndex = %ld",subview,atIndex);
//    [super insertReactSubview:subview atIndex:atIndex];
//}
//- (void)removeReactSubview:(UIView *)subview{
//    [super removeReactSubview:subview];
//}
-(instancetype)init{
    if ([super init]) {
        _isIteration = false;
    }
    return self;
}
- (void)setVisible:(BOOL)visible{
    _visible = visible;
}
@end
