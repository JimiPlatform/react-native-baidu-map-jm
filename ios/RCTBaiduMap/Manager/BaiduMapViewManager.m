//
//  RCTBaiduMapViewManager.m
//  RCTBaiduMap
//
//  Created by lovebing on Aug 6, 2016.
//  Copyright © 2016 lovebing.org. All rights reserved.
//

#import "BaiduMapViewManager.h"
#import <BaiduMapAPI_Map/BMKCircleView.h>
#import <BaiduMapAPI_Map/BMKPolygonView.h>
#import <BaiduMapAPI_Map/BMKPolylineView.h>
#import <BaiduMapAPI_Map/BMKArclineView.h>
#import "OverlayView.h"
#import "JMCircle.h"
#import "JMPolygon.h"
#import "JMPolyline.h"
#import "JMArc.h"
#import "JMPinAnnotationView.h"
#import "OverlayInfoWindow.h"

@implementation BaiduMapViewManager

RCT_EXPORT_MODULE(BaiduMapView)

RCT_EXPORT_VIEW_PROPERTY(mapType, int)
RCT_EXPORT_VIEW_PROPERTY(zoom, float)
RCT_EXPORT_VIEW_PROPERTY(zoomControlsVisible, BOOL)
RCT_EXPORT_VIEW_PROPERTY(trafficEnabled, BOOL)          //路况图层
RCT_EXPORT_VIEW_PROPERTY(baiduHeatMapEnabled, BOOL)     //热力图
RCT_EXPORT_VIEW_PROPERTY(buildingsEnabled, BOOL)        //3D建筑物
RCT_EXPORT_VIEW_PROPERTY(overlookEnabled, BOOL)         //俯仰角
RCT_EXPORT_VIEW_PROPERTY(markers, NSArray*)
RCT_EXPORT_VIEW_PROPERTY(onChange, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(visualRange, NSArray*)         //可视范围

RCT_CUSTOM_VIEW_PROPERTY(center, CLLocationCoordinate2D, BaiduMapView) {
    [view setCenterCoordinate:json ? [RCTConvert CLLocationCoordinate2D:json] : defaultView.centerCoordinate];
}

RCT_CUSTOM_VIEW_PROPERTY(correctPerspective, NSDictionary, BaiduMapView) {  //更新视角
    [view setCorrectPerspective:[RCTConvert NSDictionary:json]];
}

+ (void)initSDK:(NSString*)key {

    BMKMapManager *_mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [_mapManager start:key  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
}

- (UIView *)view {
    BaiduMapView *mapView = [[BaiduMapView alloc] init];
    mapView.delegate = self;

    return mapView;
}

#pragma mark - BMKMapViewDelegate

- (void)mapview:(BMKMapView *)mapView onDoubleClick:(CLLocationCoordinate2D)coordinate {
    NSLog(@"onDoubleClick");
    NSDictionary* event = @{
                            @"type": @"onMapDoubleClick",
                            @"params": @{
                                    @"latitude": @(coordinate.latitude),
                                    @"longitude": @(coordinate.longitude)
                                    }
                            };
    [self sendEvent:(BaiduMapView *)mapView params:event];
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
    NSLog(@"onClickedMapBlank");
    NSDictionary* event = @{
                            @"type": @"onMapClick",
                            @"params": @{
                                    @"latitude": @(coordinate.latitude),
                                    @"longitude": @(coordinate.longitude)
                                    }
                            };
    [self sendEvent:(BaiduMapView *)mapView params:event];
}

-(void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    NSDictionary* event = @{
                            @"type": @"onMapLoaded",
                            @"params": @{}
                            };
    [self sendEvent:(BaiduMapView *)mapView params:event];
}

-(void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    [view setSelected:false animated:true];
    NSString *title = [[view annotation] title];
    JMMarkerAnnotation *jmAnnotation = (JMMarkerAnnotation *)view.annotation;
    NSInteger tag = jmAnnotation.markerView.tag;
    if (!title) {
        title = @"";
    }
    NSDictionary* event = @{
                            @"type": @"onMarkerClick",
                            @"params": @{
                                    @"title": title,
                                    @"tag":@(tag),
                                    @"position": @{
                                            @"latitude": @([[view annotation] coordinate].latitude),
                                            @"longitude": @([[view annotation] coordinate].longitude)
                                            }
                                    }
                            };
    [self sendEvent:(BaiduMapView *)mapView params:event];
}

- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi *)mapPoi {
    NSDictionary* event = @{
                            @"type": @"onMapPoiClick",
                            @"params": @{
                                    @"name": mapPoi.text,
                                    @"uid": mapPoi.uid,
                                    @"latitude": @(mapPoi.pt.latitude),
                                    @"longitude": @(mapPoi.pt.longitude)
                                    }
                            };
    [self sendEvent:(BaiduMapView *)mapView params:event];
}
- (void)sendMarkerEventWithmMapView:(BMKMapView *)mapView marker:(OverlayMarker *)markerView{
    NSString *title = markerView.title;
    CLLocationCoordinate2D coordinate = markerView.location;
    NSInteger tag = markerView.tag;
    if (!title) {
        title = @"";
    }
    NSDictionary* event = @{
                            @"type": @"onMarkerClick",
                            @"params": @{
                                    @"title": title,
                                    @"tag":@(tag),
                                    @"position": @{
                                            @"latitude": @(coordinate.latitude),
                                            @"longitude": @(coordinate.longitude)
                                            }
                                    }
                            };
    [self sendEvent:(BaiduMapView *)mapView params:event];
}
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    JMMarkerAnnotation *jmAnnotation = (JMMarkerAnnotation *)annotation;
//    if (jmAnnotation.markerView) {
//        UIImage *image = jmAnnotation.markerView.image;
//        NSLog(@"jmAnnotation.markerView = %d",jmAnnotation.markerView.tag);
//        return jmAnnotation.markerView;
//    }
//    NSLog(@"jmAnnotation.markerView nil ");
//    return nil;
    JMPinAnnotationView *annotationView = (JMPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"JMMarkerJMPinAnnotation"];
    if (!annotationView) {
        annotationView = [[JMPinAnnotationView alloc] initWithAnnotation:jmAnnotation reuseIdentifier:@"JMMarkerJMPinAnnotation"];
    } else {
        [annotationView updateIcon:jmAnnotation];
    }
    //        annotationView.pinColor = BMKPinAnnotationColorPurple;
    //        annotationView.animatesDrop = YES;
//    UIView *view = jmAnnotation.markerView;
//    view.frame = CGRectMake(-10, -10, 20, 20);
//    view.backgroundColor = [UIColor redColor];
//    [annotationView addSubview:view];

    annotationView.hidePaopaoWhenSingleTapOnMap = NO;
    annotationView.hidePaopaoWhenDoubleTapOnMap = NO;
    annotationView.hidePaopaoWhenTwoFingersTapOnMap = NO;
    annotationView.hidePaopaoWhenSelectOthers = NO;
    annotationView.hidePaopaoWhenDragOthers = NO;
    annotationView.hidePaopaoWhenDrag = NO;
    annotationView.annotation = annotation;
    if (annotationView.paopaoView.tag != PAOPAOVIEW_TAG_NOEMPTY) {
        BMKActionPaopaoView *pView = [[BMKActionPaopaoView alloc] initWithCustomView:[[UIView alloc] init]];
        pView.backgroundColor = [UIColor clearColor];
        annotationView.paopaoView = pView;
        annotationView.paopaoView.tag = PAOPAOVIEW_TAG_EMPTY;
    }
    return annotationView;
}

- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view
{
    NSString *title = [[view annotation] title];
    if (!title) {
        title = @"";
    }
    NSDictionary* event = @{
                            @"type": @"onBubbleOfMarkerClick",
                            @"params": @{
                                    @"title": title,
                                    @"position": @{
                                            @"latitude": @([[view annotation] coordinate].latitude),
                                            @"longitude": @([[view annotation] coordinate].longitude)
                                            }
                                    }
                            };
    [self sendEvent:(BaiduMapView *)mapView params:event];
}

- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated reason:(BMKRegionChangeReason)reason
{
    if (reason != BMKRegionChangeReasonGesture) return;
    CLLocationCoordinate2D targetGeoPt = [mapView getMapStatus].targetGeoPt;
    NSDictionary* event = @{
                            @"type": @"onMapStatusChangeStart",
                            @"params": @{
                                    @"target": @{
                                            @"latitude": @(targetGeoPt.latitude),
                                            @"longitude": @(targetGeoPt.longitude)
                                            },
                                    @"zoom": @(mapView.zoomLevel),
                                    @"overlook": @(mapView.overlooking)
                                    }
                            };
    [self sendEvent:(BaiduMapView *)mapView params:event];
}

- (void)mapStatusDidChanged: (BMKMapView *)mapView {
    CLLocationCoordinate2D targetGeoPt = [mapView getMapStatus].targetGeoPt;
    NSDictionary* event = @{
                            @"type": @"onMapStatusChange",
                            @"params": @{
                                    @"target": @{
                                            @"latitude": @(targetGeoPt.latitude),
                                            @"longitude": @(targetGeoPt.longitude)
                                            },
                                    @"zoom": @(mapView.zoomLevel),
                                    @"overlook": @(mapView.overlooking)
                                    }
                            };
    [self sendEvent:(BaiduMapView *)mapView params:event];
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated reason:(BMKRegionChangeReason)reason
{
    if (reason != BMKRegionChangeReasonGesture) return;
    CLLocationCoordinate2D targetGeoPt = [mapView getMapStatus].targetGeoPt;
    NSDictionary* event = @{
                            @"type": @"onMapStatusChangeFinish",
                            @"params": @{
                                    @"target": @{
                                            @"latitude": @(targetGeoPt.latitude),
                                            @"longitude": @(targetGeoPt.longitude)
                                            },
                                    @"zoom": @(mapView.zoomLevel),
                                    @"overlook": @(mapView.overlooking)
                                    }
                            };
    [self sendEvent:(BaiduMapView *)mapView params:event];
}

#pragma mark -

- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
    if ([overlay isKindOfClass:[JMCircle class]]) {
        BMKCircleView *view = (BMKCircleView *)[mapView viewForOverlay:overlay];
        if (view == nil) {
            view = [[BMKCircleView alloc] initWithOverlay:overlay];
        }
        view.fillColor = ((JMCircle *)overlay).fillColor;
        view.strokeColor = ((JMCircle *)overlay).stroke.strokeColor;
        view.lineWidth = ((JMCircle *)overlay).stroke.lineWidth;
        return view;
    } else if ([overlay isKindOfClass:[JMPolygon class]]) {
        BMKPolygonView *view = (BMKPolygonView *)[mapView viewForOverlay:overlay];
        if (view == nil) {
            view = [[BMKPolygonView alloc] initWithPolygon:overlay];
        }
        view.fillColor = ((JMPolygon *)overlay).fillColor;
        view.strokeColor = ((JMPolygon *)overlay).stroke.strokeColor;
        view.lineWidth = ((JMPolygon *)overlay).stroke.lineWidth;
        return view;
    } else if ([overlay isKindOfClass:[JMPolyline class]]) {
        BMKPolylineView *view = (BMKPolylineView *)[mapView viewForOverlay:overlay];
        if (view == nil) {
            view = [[BMKPolylineView alloc] initWithPolyline:overlay];
        }
        view.fillColor = ((JMPolyline *)overlay).color;
        view.strokeColor = ((JMPolyline *)overlay).color;
        view.lineWidth = ((JMPolyline *)overlay).width;
        return view;
    } else if ([overlay isKindOfClass:[JMArc class]]) {
        BMKArclineView *view = (BMKArclineView *)[mapView viewForOverlay:overlay];
        if (view == nil) {
            view = [[BMKArclineView alloc] initWithArcline:overlay];
        }
        view.fillColor = ((JMArc *)overlay).color;
        view.strokeColor = ((JMArc *)overlay).color;
        view.lineWidth = ((JMArc *)overlay).width;
        return view;
    }

    return nil;
}

- (void)sendEvent:(BaiduMapView *) mapView params:(NSDictionary *) params {
    if (!mapView.onChange) {
        return;
    }
    mapView.onChange(params);
}

@end
