//
//  MyLocationManagerDelegate.h
//  UberHackTweak
//
//  Created by Rand01ph on 15-11-4.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>

#import "FixedLocationData.h"

@interface ExLocationManager_Delegate : NSObject

{
    CLLocationManager* exLocationManager;
    id<CLLocationManagerDelegate> exDelegate;
}

+ (ExLocationManager_Delegate*) getNewInstance;

@property (nonatomic, retain) CLLocationManager* exLocationManager;
@property (nonatomic, retain) id<CLLocationManagerDelegate> exDelegate;

@end


@interface SgLocationManagerDelegate : NSObject<CLLocationManagerDelegate>
{
    NSMutableArray* mOriginalDelegates;
}

@property (nonatomic, retain) NSMutableArray* mOriginalDelegates;

- (CLLocation*) getFixedLocation;
- (FixedLocationData*) getFixedLocationData;

- (void)createDistributedMessagingCenterServer;
- (void)sniffFixedLocationChange:(NSDictionary *)sLocationDict;
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations;
- (void)addOriginalDelegate:(id<CLLocationManagerDelegate>)aDelegate CLLocationManager: (CLLocationManager*) aLocationManager;
- (void)removeOriginalDelegateByLocationManager:(CLLocationManager*) aLocationManager;

@end
