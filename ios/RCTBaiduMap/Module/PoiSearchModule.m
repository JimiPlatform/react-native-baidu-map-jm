//
//  PoiSearchModule.m
//  JiMiPlatfromProject
//
//  Created by lzj<lizhijian_21@163.com> on 2019/4/15.
//  Copyright © 2019 jimi. All rights reserved.
//

#import "PoiSearchModule.h"
#import "GeolocationModule.h"

@implementation PoiSearchModule

@synthesize bridge = _bridge;

static BMKPoiSearch *poiSearch;
static BMKSuggestionSearch *suggestionSearch;

- (BMKPoiSearch *)getPoiSearch {
    if (poiSearch == nil) {
        poiSearch = [[BMKPoiSearch alloc] init];
    }
    return poiSearch;
}

- (BMKSuggestionSearch *)getSuggestionSearch {
    if (suggestionSearch == nil) {
        suggestionSearch = [[BMKSuggestionSearch alloc] init];
    }
    return suggestionSearch;
}

RCT_EXPORT_MODULE(BaiduSearchModule);

RCT_EXPORT_METHOD(poiSearchNearby:(double)lat lng:(double)lng radius:(int)radius keyword:(NSString *)keyword)
{
    BMKPoiSearch *poiSearch = [self getPoiSearch];
    poiSearch.delegate = self;
    self.poiSearchCount ++;

    BMKPOINearbySearchOption *nearbySearchOption = [[BMKPOINearbySearchOption alloc] init];
    nearbySearchOption.location = CLLocationCoordinate2DMake(lat, lng);
    nearbySearchOption.radius = radius;
    nearbySearchOption.keywords = [NSArray arrayWithObject:keyword];
    nearbySearchOption.pageSize = 3;

    BOOL flag = [poiSearch poiSearchNearBy:nearbySearchOption];
    if (flag) {
        NSLog(@"建议检索发送成功");
    } else {
        NSLog(@"建议检索发送失败");
        self.poiSearchCount --;
        if (self.poiSearchCount == 0) {
            poiSearch.delegate = nil;
        }
    }
}

RCT_EXPORT_METHOD(requestSuggestion:(NSString *)city keyword:(NSString *)keyword)
{
#if 0
    BMKPoiSearch *poiSearch = [self getPoiSearch];
    poiSearch.delegate = self;
    self.poiSearchCount ++;

    BMKPOICitySearchOption *citySearchOption = [[BMKPOICitySearchOption alloc] init];
    citySearchOption.city = (city && ![city isEqualToString:@""]) ? city : @"中国";
    citySearchOption.keyword = keyword;
    citySearchOption.pageSize = 3;

    BOOL flag = [poiSearch poiSearchInCity:citySearchOption];
    if (flag) {
        NSLog(@"建议检索发送成功");
    } else {
        NSLog(@"建议检索发送失败");
        self.poiSearchCount --;
        if (self.poiSearchCount == 0) {
            poiSearch.delegate = nil;
        }
    }
#else

    BMKSuggestionSearch *suggestionSearch = [self getSuggestionSearch];
    suggestionSearch.delegate = self;
    self.suggestionSearchCount ++;

    BMKSuggestionSearchOption *option = [[BMKSuggestionSearchOption alloc] init];
    option.cityname = (city && ![city isEqualToString:@""]) ? city : @"中国";
    option.keyword = keyword;

    BOOL flag = [suggestionSearch suggestionSearch:option];
    if (flag) {
        NSLog(@"建议检索发送成功");
    } else {
        NSLog(@"建议检索发送失败");
        self.suggestionSearchCount --;
        if (self.suggestionSearchCount == 0) {
            suggestionSearch.delegate = nil;
        }
    }
#endif
}

- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPOISearchResult*)poiResult errorCode:(BMKSearchErrorCode)errorCode
{
    self.poiSearchCount --;
    if (self.poiSearchCount == 0) {
        [self getPoiSearch].delegate = nil;
    }

    NSMutableDictionary *body = [self getEmptyBody];
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        NSMutableArray *dataArray = [NSMutableArray array];
        for (BMKPoiInfo *poiInfo in poiResult.poiInfoList) {
            NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
            if (poiInfo.city != nil) [dataDic setObject:poiInfo.city forKey:@"city"];
            else continue;
            if (poiInfo.area != nil) [dataDic setObject:poiInfo.area forKey:@"district"];
            if (poiInfo.name != nil) [dataDic setObject:poiInfo.name forKey:@"key"];
            [dataDic setObject:[NSNumber numberWithDouble:poiInfo.pt.latitude] forKey:@"latitude"];
            [dataDic setObject:[NSNumber numberWithDouble:poiInfo.pt.longitude] forKey:@"longitude"];
            [dataArray addObject:dataDic];
        }
        body[@"sugList"] = dataArray;
    } else {
        body[@"errcode"] = [NSString stringWithFormat:@"%d", errorCode];
        body[@"errmsg"] = [GeolocationModule getSearchErrorInfo:errorCode];
    }
    NSLog(@"%@", body);
    [self sendEvent:@"onGetSuggestionResult" body:body];
}

- (void)onGetSuggestionResult:(BMKSuggestionSearch *)searcher result:(BMKSuggestionSearchResult *)result errorCode:(BMKSearchErrorCode)errorCode
{
    self.suggestionSearchCount --;
    if (self.suggestionSearchCount == 0) {
        [self getSuggestionSearch].delegate = nil;
    }

    NSMutableDictionary *body = [self getEmptyBody];
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        NSMutableArray *dataArray = [NSMutableArray array];
        for (BMKSuggestionInfo *poiInfo in result.suggestionList) {
            NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
            if (poiInfo.city != nil) [dataDic setObject:poiInfo.city forKey:@"city"];
            else continue;
            if (poiInfo.district != nil) [dataDic setObject:poiInfo.district forKey:@"district"];
            if (poiInfo.key != nil) [dataDic setObject:poiInfo.key forKey:@"key"];
            [dataDic setObject:[NSNumber numberWithDouble:poiInfo.location.latitude] forKey:@"latitude"];
            [dataDic setObject:[NSNumber numberWithDouble:poiInfo.location.longitude] forKey:@"longitude"];
            [dataArray addObject:dataDic];
        }
        body[@"sugList"] = dataArray;
    } else {
        body[@"errcode"] = [NSString stringWithFormat:@"%d", errorCode];
        body[@"errmsg"] = [GeolocationModule getSearchErrorInfo:errorCode];
    }
    NSLog(@"%@", body);
    [self sendEvent:@"onGetSuggestionResult" body:body];
}


- (void)sendEvent:(NSString *)name body:(NSMutableDictionary *)body {
    [self.bridge.eventDispatcher sendDeviceEventWithName:name body:body];
}

@end
