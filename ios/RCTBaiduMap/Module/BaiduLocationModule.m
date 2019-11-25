//
//  BaiduLocationModule.m
//  react-native-baidu-map-jm
//
//  Created by lzj<lizhijian_21@163.com> on 2019/6/26.
//

#import "BaiduLocationModule.h"
#import <BMKLocationkit/BMKLocationComponent.h>

NSString *const kLocationModuleCheckPermission = @"kLocationModuleCheckPermission";
NSString *const kLocationModuleFail = @"kLocationModuleFail";
NSString *const kLocationModuleUpdateLocation = @"kLocationModuleUpdateLocation";
NSString *const kLocationModuleChangeAuthorization = @"kLocationModuleChangeAuthorization";
NSString *const kLocationModuleUpdateNetworkState = @"kLocationModuleUpdateNetworkState";
NSString *const kLocationModuleUpdateHeading = @"kLocationModuleUpdateHeading";

@interface BaiduLocationModule() <BMKLocationManagerDelegate, BMKLocationAuthDelegate>

@property (nonatomic, assign) BOOL isHasListeners;

@property (nonatomic, strong) BMKLocationManager *locationManager;
@property (nonatomic, strong) NSString *authKey;
@property (nonatomic, assign) BMKLocationAuthErrorCode permissionState;
@property (nonatomic, assign) NSInteger locationTimeout;
@property (nonatomic, assign) BOOL allowsBackground;

@property (nonatomic, assign) BOOL bLocation;
@property (nonatomic, assign) BOOL bHeading;

@end

@implementation BaiduLocationModule

RCT_EXPORT_MODULE(BaiduLocationModule);

- (void)startObserving {
    self.isHasListeners = YES;
    [super startObserving];
}

- (void)stopObserving {
    self.isHasListeners = NO;
    [super stopObserving];
}

- (NSArray<NSString *> *)supportedEvents {
    return @[kLocationModuleCheckPermission,
      kLocationModuleFail,
      kLocationModuleUpdateLocation,
      kLocationModuleChangeAuthorization,
      kLocationModuleUpdateNetworkState,
      kLocationModuleUpdateHeading
      ];    //添加监听方法名
}

- (NSDictionary *)constantsToExport {
    return @{kLocationModuleCheckPermission: kLocationModuleCheckPermission,
      kLocationModuleFail: kLocationModuleFail,
      kLocationModuleUpdateLocation: kLocationModuleUpdateLocation,
      kLocationModuleChangeAuthorization: kLocationModuleChangeAuthorization,
      kLocationModuleUpdateNetworkState: kLocationModuleUpdateNetworkState,
      kLocationModuleUpdateHeading: kLocationModuleUpdateHeading,
      };    //导出监听方法名，方便JS调用
}

#pragma mark -

- (NSMutableDictionary *)getEmptyBody {
    NSMutableDictionary *body = @{}.mutableCopy;
    return body;
}

- (void)sendEvent:(NSString *)name body:(NSMutableDictionary *)body {
    if (self.isHasListeners) {
        [self sendEventWithName:name body:body];
    }
}

- (BMKLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[BMKLocationManager alloc] init];
        _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        _locationManager.allowsBackgroundLocationUpdates = self.allowsBackground;
        _locationManager.locationTimeout = self.locationTimeout;
        _locationManager.reGeocodeTimeout = 10;
    }

    return _locationManager;
}

- (BOOL)checkAuth {
    if (self.permissionState == BMKLocationAuthErrorSuccess) {
        if (!_locationManager) {
            return NO;
        }
        return YES;
    } else {
        [self onCheckPermissionState:self.permissionState];
    }

    return NO;
}

- (BOOL)checkExit {
    if (!self.bLocation && !self.bHeading) {
        if (_locationManager) {
            [self.locationManager stopUpdatingLocation];
            [self.locationManager stopUpdatingHeading];
            self.locationManager.delegate = nil;
            _locationManager = nil;
            [[BMKLocationAuth sharedInstance] checkPermisionWithKey:self.authKey authDelegate:nil];
        }
        return YES;
    }

    return NO;
}

#pragma mark -

RCT_EXPORT_METHOD(config:(NSString *)key) {
    if (!key) {
        key = @"ohoabzkiHzDiKrvWGRngQtCCntwjXc8f";
    }
    self.authKey = key;
    self.permissionState = BMKLocationAuthErrorUnknown;
    self.locationTimeout = 10;
    self.allowsBackground = NO;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[BMKLocationAuth sharedInstance] checkPermisionWithKey:self.authKey authDelegate:self];
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
    });
}

RCT_EXPORT_METHOD(locationTimeout:(NSInteger)time) {
    self.locationTimeout = time;
}

RCT_EXPORT_METHOD(allowsBackground:(BOOL)allows) {
    self.allowsBackground = allows;
}

RCT_EXPORT_METHOD(startUpdatingLocation) {
    if (![self checkAuth]) return;

    self.bLocation = YES;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

RCT_EXPORT_METHOD(stopUpdatingLocation) {
    self.bLocation = NO;
    [self checkExit];
}

RCT_EXPORT_METHOD(startUpdatingHeading) {
    if (![self checkAuth]) return;

    self.bHeading = YES;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingHeading];
}

RCT_EXPORT_METHOD(stopUpdatingHeading) {
    self.bLocation = NO;
    [self checkExit];
}

#pragma mark - BMKLocationAuthDelegate

/**
 *@brief 返回授权验证错误
 *@param iError 错误号 : 为0时验证通过，具体参加BMKLocationAuthErrorCode
 */
- (void)onCheckPermissionState:(BMKLocationAuthErrorCode)iError
{
    self.permissionState = iError;

    NSString *errmsg = nil;
    NSMutableDictionary *body = [self getEmptyBody];
    switch (iError) {
        case 0:
            errmsg = @"Success";
            break;
        case 1:
            errmsg = @"因网络鉴权失败";
            break;
        case 2:
            errmsg = @"KEY非法鉴权失败";
            break;
        default:
            errmsg = @"未知错误";
            break;
    }
    body[@"errcode"] = [NSString stringWithFormat:@"%ld", (long)iError];
    body[@"errmsg"] = errmsg;

    [self sendEvent:kLocationModuleCheckPermission body:body];
}

#pragma mark - BMKLocationManagerDelegate

/**
 *  @brief 当定位发生错误时，会调用代理的此方法。
 *  @param manager 定位 BMKLocationManager 类。
 *  @param error 返回的错误，参考 CLError 。
 */
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error
{
    NSMutableDictionary *body = [self getEmptyBody];
    if (error) {
        body[@"errcode"] = [NSNumber numberWithInteger:error.code];
        body[@"errmsg"] = @"定位失败";
        [self sendEvent:kLocationModuleFail body:body];
    }
}

/**
 *  @brief 连续定位回调函数。
 *  @param manager 定位 BMKLocationManager 类。
 *  @param location 定位结果，参考BMKLocation。
 *  @param error 错误信息。
 */
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didUpdateLocation:(BMKLocation * _Nullable)location orError:(NSError * _Nullable)error
{
    NSMutableDictionary *body = [self getEmptyBody];
    body[@"latitude"] = [NSNumber numberWithDouble:location.location.coordinate.latitude];
    body[@"longitude"] = [NSNumber numberWithDouble:location.location.coordinate.longitude];
    [self sendEvent:kLocationModuleUpdateLocation body:body];
}

/**
 *  @brief 定位权限状态改变时回调函数
 *  @param manager 定位 BMKLocationManager 类。
 *  @param status 定位权限状态。
 */
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSMutableDictionary *body = [self getEmptyBody];
    body[@"state"] = [NSNumber numberWithInteger:status];
    [self sendEvent:kLocationModuleChangeAuthorization body:body];
}

/**
 * @brief 该方法为BMKLocationManager所在App系统网络状态改变的回调事件。
 * @param manager 提供该定位结果的BMKLocationManager类的实例
 * @param state 当前网络状态
 * @param error 错误信息
 */
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager
     didUpdateNetworkState:(BMKLocationNetworkState)state orError:(NSError * _Nullable)error
{
    NSMutableDictionary *body = [self getEmptyBody];
    body[@"state"] = [NSNumber numberWithInteger:state];
    [self sendEvent:kLocationModuleUpdateNetworkState body:body];
}

/**
 * @brief 该方法为BMKLocationManager提供设备朝向的回调方法。
 * @param manager 提供该定位结果的BMKLocationManager类的实例
 * @param heading 设备的朝向结果
 */
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager
          didUpdateHeading:(CLHeading * _Nullable)heading
{
    NSMutableDictionary *body = [self getEmptyBody];
    body[@"magneticHeading"] = [NSNumber numberWithDouble:heading.magneticHeading];
    body[@"trueHeading"] = [NSNumber numberWithDouble:heading.trueHeading];
    body[@"headingAccuracy"] = [NSNumber numberWithDouble:heading.headingAccuracy];
    body[@"timestamp"] = [NSNumber numberWithDouble:heading.timestamp.timeIntervalSince1970];
    [self sendEvent:kLocationModuleUpdateHeading body:body];
}

@end
