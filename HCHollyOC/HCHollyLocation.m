//
//  HCHollyLocation.m
//  HCHollyOC
//
//  Created by 林龙成 on 2019/6/20.
//  Copyright © 2019 loganv. All rights reserved.
//

#import "HCHollyLocation.h"

@interface HCHollyLocation()<CLLocationManagerDelegate>

@property(nonatomic, strong)CLLocationManager *manager;

@property(nonatomic, copy) void(^locationDone)(CLLocation*);
@property(nonatomic, copy) void(^locationFail)(NSError*);

@end

@implementation HCHollyLocation

static HCHollyLocation *_instance = nil;
static BOOL showlog = false;

+(void)showlog:(BOOL)iss{
    showlog = iss;
}
+(HCHollyLocation*)share{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[HCHollyLocation alloc]init];

        _instance.manager = [[CLLocationManager alloc]init];
        _instance.manager.delegate = _instance;
    });
    return _instance;
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    if (showlog) {
        NSLog(@"didDetermineState: %ld", state);
    }
    
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (showlog) {
        NSLog(@"didChangeAuthorizationStatus: %d", status);
    }
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        if (self.locationDone) {
            [self.manager startUpdatingLocation];
        }
    }
    else if (status != kCLAuthorizationStatusNotDetermined) {
        if (self.locationFail) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"没有获取定位权限"};
            NSError *error = [NSError errorWithDomain:@"HCHollyLocation" code:-1 userInfo:userInfo];
            self.locationFail(error);
        }
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    if (!_locationDone) {
        return;
    }
    
    CLLocation *location = locations.firstObject;
    if (location) {
        _locationDone(location);
        _locationDone = nil;
        _locationFail = nil;
    }
    [manager stopUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if (!_locationFail) {
        return;
    }
    
    _locationFail(error);
    _locationDone = nil;
    _locationFail = nil;
    [manager stopUpdatingLocation];
}

-(void)getLocationBack:(void(^)(CLLocation*))locationDone failed:(void(^)(NSError*))locationFail{
    self.locationDone = locationDone;
    self.locationFail = locationFail;
    
    if ([self locIsAuth]) {
        [self.manager startUpdatingLocation];
    } else {
        [self reqAuth];
    }
}

-(void)reqAuth{
    [_manager requestWhenInUseAuthorization];
}

-(BOOL)locIsAuth{
    CLAuthorizationStatus status;
    if (@available(iOS 14.0, *)) {
        status = [_manager authorizationStatus];
    } else {
        status = [CLLocationManager authorizationStatus];
    }
    if (showlog) {
        NSLog(@"authorizationStatus: %d", status);
    }
    return (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways);
}

@end
