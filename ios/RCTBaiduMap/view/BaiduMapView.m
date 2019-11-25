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

@interface BaiduMapView()

@property (nonatomic, strong) NSMutableArray *annotationArray;
@property (nonatomic, strong) OverlayInfoWindow *overlayInfoWindow;

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
    } else {
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

- (void)setMarkers:(NSArray *)markers
{
    NSInteger markersCount = [markers count];
    if (_annotationArray == nil) {
        _annotationArray = [[NSMutableArray alloc] init];
    }

    if (markers != nil) {
        for (NSInteger i = 0, markersMax = markersCount; i < markersMax; i++)  {
            NSDictionary *option = [markers objectAtIndex:i];
            
            JMMarkerAnnotation *annotation = nil;
            if (i < [_annotationArray count]) {
                annotation = [self.annotationArray objectAtIndex:i];
            }
            NSLog(@"Marker%ld:%@", (long)i, option);

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
    }

    if (annotationView) {
        if ([annotation isDifIcon:iconDic] || (!annotationView.image && iconDic) || !dataDic) {
            annotation.iconDic = iconDic;
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
    annotation.title = title;
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
            if (annotationView && !annotationView.paopaoView) {
                [annotation clear];     //清除数据

                dispatch_async(dispatch_get_main_queue(), ^{
                    BMKActionPaopaoView *pView = [[BMKActionPaopaoView alloc] initWithCustomView:self.overlayInfoWindow];
                    pView.backgroundColor = [UIColor clearColor];
                    annotationView.paopaoView = pView;
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
        [TrackUtils setVisualRange:self pointArray:tracePoints];
    }
}

@end
