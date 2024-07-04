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
        
    }
    else{
        NSLog(@"didChangeAuthorizationStatus: 没有获取定位权限");
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    _locationDone(locations.firstObject);
    [manager stopUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    _locationFail(error);
}

-(void)getLocationBack:(void(^)(CLLocation*))locationDone failed:(void(^)(NSError*))locationFail{
    [self reqAuth];
    self.locationDone = locationDone;
    self.locationFail = locationFail;
}

-(void)reqAuth{
    [_manager requestWhenInUseAuthorization];
}

-(BOOL)locIsAuth{
    if (@available(iOS 14.0, *)) {
        if (showlog) {
            NSLog(@"authorizationStatus: %d", [_manager authorizationStatus]);
        }
        return ([_manager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [_manager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) ? true : false;
    } else {
        // Fallback on earlier versions
    }
    return true;
}

@end
