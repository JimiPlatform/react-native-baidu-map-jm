//
//  RCTBaiduMap.m
//  RCTBaiduMap
//
//  Created by lovebing on 4/17/2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#import "BaiduMapView.h"
#import "OverlayCircle.h"
#import "OverlayInfoWindow.h"
#import "OverlayPolyline.h"
#import "TrackUtils.h"
#import <BaiduMapAPI_Map/BMKPolylineView.h>
#import "JMPinAnnotationView.h"
#import "OverlayInfoWindow.h"
#include "OverlayMarker.h"
#include "UIView+React.h"
@interface BaiduMapView()

@property (nonatomic, strong) NSMutableArray *annotationArray;
@property (nonatomic, strong) OverlayInfoWindow *overlayInfoWindow;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *,JMMarkerAnnotation *> * annotationDic;
@end

@implementation BaiduMapView

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfoWindows) name:kBaiduMapViewChangeInfoWinfoTag object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfoWindows) name:kBaiduMapViewChangeInfoWinfoVisible object:nil];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addSubview:(UIView *)view
{
    if ([view isKindOfClass:[OverlayView class]]) {
        [((OverlayView *)view) addTopMap:self];
        if ([view isKindOfClass:[OverlayInfoWindow class]]) {
            self.overlayInfoWindow = (OverlayInfoWindow *)view;
            [self updateInfoWindows];
        }
    } else if([view isKindOfClass:[OverlayMarker class]]){
//        [self addMarkerView:(OverlayMarker *)view];
    }  else {
        [super addSubview:view];
    }
}


- (void)willRemoveSubview:(UIView *)subview
{
    [super willRemoveSubview:subview];
    if ([subview isKindOfClass:[OverlayView class]]) {
        [((OverlayView *)subview) removeTopMap:self];
    }
}

- (void)removeFromSuperview
{
    [self removeAnnotations:self.annotationArray];
    _overlayInfoWindow = nil;
    _annotationArray = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kRemoveMapViewFromSuperview" object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super removeFromSuperview];
}

#pragma mark - 

-(void)setZoom:(float)zoom {
    self.zoomLevel = zoom;
}

- (void)setZoomControlsVisible:(BOOL)zoomControlsVisible
{
//    self.showMapScaleBar = zoomControlsVisible;
}

- (void)setCenterLatLng:(NSDictionary *)LatLngObj {
    double lat = [RCTConvert double:LatLngObj[@"lat"]];
    double lng = [RCTConvert double:LatLngObj[@"lng"]];
    CLLocationCoordinate2D point = CLLocationCoordinate2DMake(lat, lng);
    self.centerCoordinate = point;
}

#pragma mark - Marker

- (void)setMarkers:(NSArray *)markers{
    BOOL isRun = true;
    for (NSUInteger i = 0; i < markers.count; ++i) {
        NSDictionary *option = [markers objectAtIndex:i];

        BOOL isIteration =  [RCTConvert BOOL:option[@"isIteration"]];
        if (isIteration) {//如果是之前的代码还是用这个方法
            isRun = false;
        }
    }
    NSInteger markersCount = [markers count];
    if (_annotationArray == nil) {
        _annotationArray = [[NSMutableArray alloc] init];
    }

    if (markers != nil && isRun) {
        for (NSInteger i = 0, markersMax = markersCount; i < markersMax; i++)  {
            NSDictionary *option = [markers objectAtIndex:i];
            
            JMMarkerAnnotation *annotation = nil;
            if (i < [_annotationArray count]) {
                annotation = [self.annotationArray objectAtIndex:i];
            }

            if (![RCTConvert BOOL:option[@"visible"]]) {  //隐藏则移除此Marker;
                markersCount --;
            } else {
                if (annotation == nil) {
                    annotation = [[JMMarkerAnnotation alloc] init];
                    [self addMarker:annotation option:option];
                    [self.annotationArray addObject:annotation];
                } else {
                    [self updateMarker:annotation option:option];
                }
            }
        }
        
        NSInteger annotationsCount = [_annotationArray count];
        if (markersCount < annotationsCount) {
            NSInteger start = annotationsCount - 1;
            for (NSInteger i = start; i >= markersCount ; i--) {
                JMMarkerAnnotation *annotation = [self.annotationArray objectAtIndex:i];
                [annotation clear];
                [self removeAnnotation:annotation];
                [self.annotationArray removeObject:annotation];
            }
        }

        [self updateInfoWindows];
    }else if(markers != nil){
        [self updateAnnotationWithMartker:markers];
    }
}

- (CLLocationCoordinate2D)getCoorFromMarkerOption:(NSDictionary *)option {
    double lat = 0;
    double lng= 0;
    if (option[@"location"]) {  //lzj fixed
        NSDictionary *Dic = [RCTConvert NSDictionary:option[@"location"]];
        lat = [[Dic objectForKey:@"latitude"] doubleValue];
        lng = [[Dic objectForKey:@"longitude"] doubleValue];
    } else {
        lat = [RCTConvert double:option[@"latitude"]];
        lng = [RCTConvert double:option[@"longitude"]];
    }
    CLLocationCoordinate2D coor;
    coor.latitude = lat;
    coor.longitude = lng;
    return coor;
}

- (void)addMarker:(JMMarkerAnnotation *)annotation option:(NSDictionary *)option {
    [self updateMarker:annotation option:option];
    [self addAnnotation:annotation];
}

-(void)updateMarker:(JMMarkerAnnotation *)annotation option:(NSDictionary *)option {
    JMPinAnnotationView *annotationView = (JMPinAnnotationView *)[self viewForAnnotation:annotation];
    [self updateAnnotationView:annotationView annotation:annotation dataDic:option];
}

- (void)updateAnnotationView:(JMPinAnnotationView *)annotationView annotation:(JMMarkerAnnotation *)annotation dataDic:(NSDictionary *)dataDic
{

    if (!annotation) return;

    CLLocationCoordinate2D coor = annotation.coordinate;
    NSString *title = annotation.title;
    float alpha = annotation.alpha;
    BOOL flat =  annotation.flat;
    float rotate = annotation.rotate;
    int tag = annotation.tag;
    NSDictionary *iconDic = annotation.iconDic;

    if (dataDic) {

        tag = [RCTConvert int:dataDic[@"tag"]];
        title = [RCTConvert NSString:dataDic[@"title"]];
        alpha = [RCTConvert float:dataDic[@"alpha"]];
        flat = [RCTConvert BOOL:dataDic[@"flat"]];
        coor = [self getCoorFromMarkerOption:dataDic];
        rotate = [RCTConvert float:dataDic[@"rotate"]];
        iconDic = dataDic[@"icon"];
//        iconUrl = [RCTConvert NSString:dataDic[@"icon"]];
//        iconDic = dataDic[@"icon"];
    }
    if (annotationView) {
        if ([annotation isDifIcon:iconDic] || ( !annotationView.image && (annotationView.image != annotation.iconImage) && iconDic) || !dataDic) {
            annotation.iconDic = iconDic;
//            if ([iconDic isKindOfClass:[NSString class]]) {
//  
            annotation.iconImage = [annotation getImage];
         
            annotationView.image = annotation.iconImage;
            annotation.rotate = 0;
        }
//        else if (iconUrl){
//            annotation.iconImage = [UIImage imageWithContentsOfFile:(NSString *)iconDic];
//            annotationView.image = annotation.iconImage;
//            annotation.rotate = 0;
//        }

        if (annotation.rotate != rotate) {
            annotation.rotate = rotate;
            annotationView.image = [JMMarkerAnnotation imageRotated:annotation.iconImage radians:annotation.rotate];
        }
        if (tag >= 0 && annotation.tag != tag) {
            annotation.tag = tag;
            [self updateInfoWindows];
        } else if (tag >= 0 && annotation.tag == tag && annotationView.paopaoView == nil) {
            [self updateInfoWindows];
        }
    }
    annotation.tag = tag;
    annotation.coordinate = coor;
    annotation.title = title ? title : @" ";
    annotation.flat = flat;
    annotation.iconDic = iconDic;
    annotation.rotate = rotate;
}

#pragma mark - InfoWindow

- (void)updateInfoWindows
{
    if (!self.overlayInfoWindow) return;

    BOOL isRemove = NO;
    NSArray *array = [NSArray arrayWithArray:self.annotations];
    for (JMMarkerAnnotation *annotation in array) {
        BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[self viewForAnnotation:annotation];
        if (annotation.tag == self.overlayInfoWindow.tag && !self.overlayInfoWindow.visible) {
            if (annotationView && (!annotationView.paopaoView || annotationView.paopaoView.tag == PAOPAOVIEW_TAG_EMPTY)) {
                [annotation clear];     //清除数据

                dispatch_async(dispatch_get_main_queue(), ^{
                    BMKActionPaopaoView *pView = [[BMKActionPaopaoView alloc] initWithCustomView:self.overlayInfoWindow];
                    pView.backgroundColor = [UIColor clearColor];
                    annotationView.paopaoView = pView;
                    annotationView.paopaoView.tag = PAOPAOVIEW_TAG_NOEMPTY;
                    [self selectAnnotation:annotation animated:YES];
                });
            }
            if (isRemove) {
                break;
            }
        } else if (annotationView.paopaoView) {
            isRemove = YES;
            [self removeAnnotation:annotation];
            [self addAnnotation:annotation];
        }
    }
}

#pragma mark - 轨迹

- (void)setCorrectPerspective:(NSDictionary *)info
{
    if (!info) return;

    double latitude = [[info objectForKey:@"latitude"] doubleValue];
    double longitude = [[info objectForKey:@"longitude"] doubleValue];

    if (!latitude && !longitude) {
        return;
    }

    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(latitude, longitude);
    CGPoint point = [self convertCoordinate:coor toPointToView:self];
    if (![self.layer containsPoint:point]) {    //范围放大之后，更新当前坐标，即视角根据车移动
        BMKMapStatus *mapStatus = [self getMapStatus];
        mapStatus.targetGeoPt = coor;
        [self setMapStatus:mapStatus withAnimation:YES];
    }
}

- (void)setVisualRange:(NSArray *)tracePoints
{
    if (tracePoints.count > 0) {
        BMKMapStatus *status = [self getMapStatus];
        [TrackUtils setVisualRange:self pointArray:tracePoints fLevel:status.fLevel];
    }
}

#pragma mark ---
- (void)addMarkerView:(OverlayMarker *)markerView{
    if (!markerView || !markerView.isIteration) {//如果是之前代码测不管
        return;
    }
    JMMarkerAnnotation *annotation = nil;
    NSNumber *number = [NSNumber numberWithInteger:markerView.tag];
    if (!markerView.visible ) {
        if ([self.annotationDic.allKeys containsObject:number] ) {
             annotation = self.annotationDic[number];
             [self removeAnnotation:annotation];
             [self updateAnnotation:annotation markerView:markerView];
//             [self addAnnotation:annotation];
             self.annotationDic[number] = annotation;
        }else{
            annotation = [[JMMarkerAnnotation alloc] init];
            [self updateAnnotation:annotation markerView:markerView];
//            [self addAnnotation:annotation];
            self.annotationDic[number] = annotation;
        }
//        if ([self.annotationDic.allKeys containsObject:number]) {
//            annotation = self.annotationDic[number];
//            [annotation clear];
//            [self removeAnnotation:annotation];
//            [self.annotationDic removeObjectForKey:number];
//        }
        
    } else if ([self.annotationDic.allKeys containsObject:number]) {
        annotation = self.annotationDic[number];
        [self removeAnnotation:annotation];
        [self updateAnnotation:annotation markerView:markerView];
        [self addAnnotation:annotation];
        self.annotationDic[number] = annotation;
    }else{
        annotation = [[JMMarkerAnnotation alloc] init];
        [self updateAnnotation:annotation markerView:markerView];
        [self addAnnotation:annotation];
        self.annotationDic[number] = annotation;
    }
//    annotation.tag = (int)markerView.tag;
//    annotation.title = markerView.title;
//    annotation.flat = markerView.flat;
//    annotation.iconDic = markerView.icon;
//    annotation.alpha = markerView.alpha;
//    annotation.rotate = markerView.rotate;
//    annotation.coordinate = markerView.location;
//    annotation.iconImage = [annotation getImage];
//    JMPinAnnotationView *annotationView = (JMPinAnnotationView *)[self viewForAnnotation:annotation];
//    annotationView.image = annotation.iconImage;
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//    view.backgroundColor = [UIColor blueColor];
//    [annotationView addSubview:view];
////    UIImage *image = annotation.iconImage;
////    markerView.image = image;
////    annotation.markerView = markerView;
//    NSLog(@"markerView.icon == %@ annotationView.image = %@",markerView.icon,annotationView.image);
    
}
- (void)updateAnnotation:(JMMarkerAnnotation *)annotation markerView:(OverlayMarker *)markerView
{

    if (!annotation) return;
    JMPinAnnotationView *annotationView = (JMPinAnnotationView *)[self viewForAnnotation:annotation];

    CLLocationCoordinate2D coor = annotation.coordinate;
    NSString *title = annotation.title;
    float alpha = annotation.alpha;
    BOOL flat =  annotation.flat;
    float rotate = annotation.rotate;
    int tag = annotation.tag;
    NSDictionary *iconDic = annotation.iconDic;

    if (markerView) {
        tag = (int)markerView.tag;
        title = markerView.title;
        alpha = markerView.alpha;
        flat = markerView.flat;
        coor = markerView.location;
        rotate = markerView.rotate;
        iconDic = markerView.icon;
    }

    if (annotationView) {
        if ([annotation isDifIcon:iconDic] || (!annotationView.image && iconDic) || !markerView) {
            annotation.iconDic = iconDic;
//            if ([iconDic isKindOfClass:[NSString class]]) {
//                annotation.iconImage = [UIImage imageWithContentsOfFile:(NSString *)iconDic];
//            }else{
//            }
            annotation.iconImage = [annotation getImage];
         
            annotationView.image = annotation.iconImage;
            annotation.rotate = 0;
        }

        if (annotation.rotate != rotate) {
            annotation.rotate = rotate;
            annotationView.image = [JMMarkerAnnotation imageRotated:annotation.iconImage radians:annotation.rotate];
        }
        if (tag >= 0 && annotation.tag != tag) {
            annotation.tag = tag;
            [self updateInfoWindows];
        } else if (tag >= 0 && annotation.tag == tag && annotationView.paopaoView == nil) {
            [self updateInfoWindows];
        }
    }
    annotation.tag = tag;
    annotation.coordinate = coor;
    annotation.title = title ? title : @" ";
    annotation.flat = flat;
    annotation.iconDic = iconDic;
    annotation.rotate = rotate;
//    if (markerView.width && markerView.height) {
        annotation.markerView = markerView;
//    }
    
}
- (void)updateAnnotationWithMartker:(NSArray *)markers{
    for (NSDictionary *option in markers) {
        int tag = [RCTConvert int:option[@"tag"]];
        NSNumber *number = [NSNumber numberWithInteger:tag];
        if ([self.annotationDic.allKeys containsObject:number]) {
            JMMarkerAnnotation *annotation = self.annotationDic[number];
            
            JMPinAnnotationView *annotationView = (JMPinAnnotationView *)[self viewForAnnotation:annotation];
            [self updateAnnotationView:annotationView annotation:annotation dataDic:option];
            [self removeAnnotation:annotation];
            if ([RCTConvert BOOL:option[@"visible"]]) {
//                NSLog(@"[self addAnnotation:annotation]; tag = %ld",annotation.markerView.tag);
                [self addAnnotation:annotation];
            }else{
//                NSLog(@"[self removeAnnotation:annotation]; tag = %ld",annotation.markerView.tag);
                [self removeAnnotation:annotation];
            }
            self.annotationDic[number] = annotation;
        }
    }
}
- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)atIndex{
    if([subview isKindOfClass:[OverlayMarker class]]){
        [self addMarkerView:(OverlayMarker *)subview];
    }
    [super insertReactSubview:subview atIndex:atIndex];
}
- (void)removeReactSubview:(UIView *)subview{
    if([subview isKindOfClass:[OverlayMarker class]]){
        OverlayMarker *markerView = (OverlayMarker *)subview;
        NSNumber *number = [NSNumber numberWithInteger:markerView.tag];
        if ([self.annotationDic.allKeys containsObject:number]) {
            JMMarkerAnnotation *annotation = self.annotationDic[number];
            [annotation clear];
            [self removeAnnotation:annotation];
            [self.annotationDic removeObjectForKey:number];
        }
    }
    [super removeReactSubview:subview];
}
- (NSMutableDictionary<NSNumber *,JMMarkerAnnotation *> *)annotationDic{
    if (!_annotationDic) {
        _annotationDic = [[NSMutableDictionary alloc] init];
    }
    return _annotationDic;
}
@end
