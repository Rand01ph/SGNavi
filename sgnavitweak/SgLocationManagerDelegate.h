//
//  MyLocationManagerDelegate.h
//  UberHackTweak
//
//  Created by Rand01ph on 15-11-4.
//

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>


@interface FixedLocationData : NSObject
{
    BOOL mIsSet;
    CLLocation* mFixedLocation;
}
@property (nonatomic, assign) BOOL mIsSet;
@property (nonatomic, retain) CLLocation* mFixedLocation;

@end


@interface ExLocationManager_Delegate : NSObject

{
    CLLocationManager* exLocationManager;
    id<CLLocationManagerDelegate> exDelegate;
}
@property (nonatomic, retain) CLLocationManager* exLocationManager;
@property (nonatomic, retain) id<CLLocationManagerDelegate> exDelegate;

+ (ExLocationManager_Delegate*) getNewInstance;

@end




@interface SgLocationManagerDelegate : NSObject<CLLocationManagerDelegate>
{
    NSMutableArray* mOriginalDelegates;
}

@property (nonatomic, retain) NSMutableArray* mOriginalDelegates;

- (CLLocation*) getFixedLocation;

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations;

- (void)addOriginalDelegate:(id<CLLocationManagerDelegate>)aDelegate CLLocationManager: (CLLocationManager*) aLocationManager;

- (void)removeOriginalDelegateByLocationManager:(CLLocationManager*) aLocationManager;

@end
