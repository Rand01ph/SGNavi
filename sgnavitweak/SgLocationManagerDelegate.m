#import <Foundation/NSDistributedNotificationCenter.h>
#import "SgLocationManagerDelegate.h"

//=======================================================
//加强版LocationManager+Delegate 集合
@implementation ExLocationManager_Delegate

@synthesize exLocationManager;
@synthesize exDelegate;

+ (ExLocationManager_Delegate*)getNewInstance {
    ExLocationManager_Delegate* newInstance = [[[ExLocationManager_Delegate alloc] init] autorelease];
    return newInstance;
}

- (void)dealloc {
    self.exLocationManager = nil;
    self.exDelegate = nil;
    [super dealloc];
}

@end


//=======================================================
//松果LocationManagerDelegate实现
@implementation SgLocationManagerDelegate
@synthesize mOriginalDelegates;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.mOriginalDelegates = [NSMutableArray arrayWithCapacity: 5];
    }
    return self;
}

- (void)dealloc
{
    self.mOriginalDelegates = nil;
    [super dealloc];
}

- (void)createDistributedMessagingCenterServer
{
    NSString *fakeObserveObject = @"com.sg.fakeNotification";
    NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
    [center addObserver: self
               selector: @selector(sniffFixedLocationChange:)
                    name: @"NOTIFICATION_FIXED_LOCATION_CHANGE_SGNAVI"
                    object: fakeObserveObject];
}

- (void)sniffFixedLocationChange:(NSNotification *)notif
{
    NSDictionary* gLocationDict = nil;
    if ( [notif.userInfo isKindOfClass:[NSDictionary class]] ) {
        gLocationDict = notif.userInfo;
    }
    else {
        gLocationDict = [NSDictionary dictionaryWithContentsOfFile: [self getFixedLocationDataFilePath]];
    }
    FixedLocationData* gFixedLocationData = [FixedLocationData getNewInstance];
    gFixedLocationData.mIsSet = YES;
    CLLocation* gLocation = [NSKeyedUnarchiver unarchiveObjectWithData: (NSData *) [gLocationDict objectForKey:@"location"]];
    CLLocation* gFakeLocation = [[CLLocation alloc] initWithLatitude:gLocation.coordinate.latitude longitude:gLocation.coordinate.longitude];
    gFixedLocationData.mFixedLocation = gFakeLocation;
    [gFakeLocation release];
    [self notifyLocationChange: gFixedLocationData];
}

- (void)notifyLocationChange: (FixedLocationData*)fixedLocationData
{
    if ( [fixedLocationData isKindOfClass:[FixedLocationData class]] ) {
        if ( self.mOriginalDelegates.count != 0 ) {
            ExLocationManager_Delegate* oldLocationManager_delegate = [self.mOriginalDelegates objectAtIndex: 0];
            id<CLLocationManagerDelegate> gDelegate = nil;
            gDelegate = oldLocationManager_delegate.exDelegate;
            CLLocationManager *gLocationManager = nil;
            gLocationManager = oldLocationManager_delegate.exLocationManager;
            if (gDelegate && [gDelegate respondsToSelector:@selector(locationManager:didUpdateLocations:locations:)]) {
                FixedLocationData* gFixedLocationData = fixedLocationData;
                CLLocation* gFixedLocation = gFixedLocationData.mFixedLocation;
                NSMutableArray<CLLocation *> *newLocations = [[NSMutableArray alloc] init];

                [newLocations addObject: gFixedLocation];

                HBLogDebug(@"location fixed");

                [gDelegate locationManager:gLocationManager didUpdateLocations:newLocations];
            }else {
                return ;
            }
        }
    }
}

- (NSString*)getFixedLocationDataFilePath
{
    return @"/var/mobile/Library/Preferences/navi.sg";
}

- (FixedLocationData*)getFixedLocationData
{
    NSDictionary* sLocationDict = [NSDictionary dictionaryWithContentsOfFile: [self getFixedLocationDataFilePath]];

    if (sLocationDict)
    {
        HBLogDebug(@"Load success");
        FixedLocationData* sFixedLocationData = [FixedLocationData getNewInstance];
        sFixedLocationData.mIsSet = YES;

        @try{
            CLLocation* sLocation = [NSKeyedUnarchiver unarchiveObjectWithData: (NSData *) [sLocationDict objectForKey:@"location"]];

            CLLocation* sFakeLocation = [[CLLocation alloc] initWithLatitude:sLocation.coordinate.latitude longitude:sLocation.coordinate.longitude];

            sFixedLocationData.mFixedLocation = sFakeLocation;

            [sFakeLocation release];
        }
        @catch (NSException* exception) {
            HBLogDebug(@"Load loaction data fail");
            return nil;
        }
        return sFixedLocationData;
    }
    return nil;
}

- (CLLocation*)getFixedLocation
{
    //CLLocation *loc = [[CLLocation alloc] initWithLatitude:39.54 longitude:116.28];
    FixedLocationData* sFixedLocationData = [self getFixedLocationData];
    if (sFixedLocationData)
    {
        HBLogDebug(@"Start to fix loaction");
        return sFixedLocationData.mFixedLocation;
    }
    return nil;
}

- (ExLocationManager_Delegate*)getLocationManagerDelegateByLocationManager:(CLLocationManager*)aLocationManager
{
    for (ExLocationManager_Delegate *eLMD in self.mOriginalDelegates)
    {
        if (eLMD.exLocationManager == aLocationManager)
        {
            HBLogDebug(@"Get the LocationManagerDelegate by LocationManager");
            return eLMD;
        }
    }
    return nil;
}

- (id<CLLocationManagerDelegate>)getOriginalDelegateByLocationManager:(CLLocationManager*)aLocationManager
{
    HBLogDebug(@"get the original delegate");
    ExLocationManager_Delegate* sLocationManager_delegate = [self getLocationManagerDelegateByLocationManager: aLocationManager];
    if (sLocationManager_delegate)
    {
        HBLogDebug(@"the original delegate get");
        return sLocationManager_delegate.exDelegate;
    }
    else
    {
        return nil;
    }
}

- (void)addOriginalDelegate:(id<CLLocationManagerDelegate>)aDelegate CLLocationManager: (CLLocationManager*) aLocationManager
{
    if (!aDelegate || !aLocationManager)
    {
        return;
    }

    HBLogDebug(@"add the original delegate.");

    [self removeOriginalDelegateByLocationManager: aLocationManager];

    ExLocationManager_Delegate* sLocationManager_delegate = [ExLocationManager_Delegate getNewInstance];
    sLocationManager_delegate.exLocationManager = aLocationManager;
    sLocationManager_delegate.exDelegate = aDelegate;

    [self.mOriginalDelegates addObject: sLocationManager_delegate];

    HBLogDebug(@"delegate added.");
}

- (void)removeOriginalDelegateByLocationManager:(CLLocationManager*) aLocationManager
{
    HBLogDebug(@"remove the original delegate");

    NSMutableIndexSet* sIndexesToDelete = [NSMutableIndexSet indexSet];
    NSUInteger sCurrentIndex = 0;

    for (ExLocationManager_Delegate* eLMD in self.mOriginalDelegates)
    {
        if (eLMD.exLocationManager == aLocationManager)
        {
            [sIndexesToDelete addIndex:sCurrentIndex];
        }
        sCurrentIndex++;
    }

    HBLogDebug(@"delegate removed");

    [self.mOriginalDelegates removeObjectsAtIndexes:sIndexesToDelete];
}


#pragma mark -
#pragma mark Responding to Location Events
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    HBLogDebug(@"updateToLocation");

    ExLocationManager_Delegate* newLocationManager_delegate = [self getLocationManagerDelegateByLocationManager: manager];
    if (!newLocationManager_delegate)
    {
        HBLogDebug(@"I can't find the LocationManagerDelegate");
        return;
    }

    id<CLLocationManagerDelegate> sDelegate = nil;
    sDelegate = newLocationManager_delegate.exDelegate;

    if (sDelegate && [sDelegate respondsToSelector:@selector(locationManager:didUpdateLocations:locations:)])
    {
        FixedLocationData* sFixedLocationData = [self getFixedLocationData];
        CLLocation* sFixedLocation = sFixedLocationData.mFixedLocation;
        NSMutableArray<CLLocation *> *customLocations = [[NSMutableArray alloc] init];

        //未获取到Fixed位置或不需要Fixed
        if(!sFixedLocation)
        {
            //CLLocation *newLocation = [locations lastObject];
            //CLLocation *oldLocation = [locations objectAtIndex:locations.count-1];
            HBLogDebug(@"no fix origin location.");
        }
        else
        {

            CLLocation* sFixedLocation = sFixedLocationData.mFixedLocation;

            for (int i=0; i<locations.count; i++)
            {
                [customLocations addObject: sFixedLocation];
            }

            HBLogDebug(@"location fixed");
        }

        [sDelegate locationManager:manager didUpdateLocations:customLocations];
    }
    return;
}


- (void)locationManager:(CLLocationManager*)manager didFailWithError:(NSError *)error
{
    id<CLLocationManagerDelegate> sDelegate = nil;
    sDelegate = [self getOriginalDelegateByLocationManager: manager];
    if (!sDelegate)
    {
        return;
    }

    if (sDelegate && [sDelegate respondsToSelector:@selector(locationManager:didFailWithError:)])
    {
        [sDelegate locationManager:manager didFailWithError:error];
    }
    return;
}


#pragma mark -
#pragma mark Responding to Heading Events
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    id<CLLocationManagerDelegate> sDelegate = nil;
    sDelegate = [self getOriginalDelegateByLocationManager: manager];
    if (!sDelegate)
    {
        return;
    }

    if (sDelegate && [sDelegate respondsToSelector:@selector(locationManager:didUpdateHeading:)])
    {
        [sDelegate locationManager:manager didUpdateHeading:newHeading];
    }
    return;
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{

    id<CLLocationManagerDelegate> sDelegate = nil;
    sDelegate = [self getOriginalDelegateByLocationManager: manager];
    if (!sDelegate)
    {
        return NO;
    }

    if (sDelegate && [sDelegate respondsToSelector:@selector(locationManagerShouldDisplayHeadingCalibration:)])
    {
        [sDelegate locationManagerShouldDisplayHeadingCalibration:manager];
    }
    return NO;
}

#pragma mark -
#pragma mark Responding to Region Events
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    id<CLLocationManagerDelegate> sDelegate = nil;
    sDelegate = [self getOriginalDelegateByLocationManager: manager];
    if (!sDelegate)
    {
        return;
    }

    if (sDelegate && [sDelegate respondsToSelector:@selector(locationManager:didEnterRegion:)])
    {
        [sDelegate locationManager:manager didEnterRegion:region];
    }

    return;
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    id<CLLocationManagerDelegate> sDelegate = nil;
    sDelegate = [self getOriginalDelegateByLocationManager: manager];
    if (!sDelegate)
    {
        return;
    }

    if (sDelegate && [sDelegate respondsToSelector:@selector(locationManager:didExitRegion:)])
    {
        [sDelegate locationManager:manager didExitRegion:region];
    }
    return;
}

#pragma mark -
#pragma mark Responding to Authorization Changes
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    id<CLLocationManagerDelegate> sDelegate = nil;
    sDelegate = [self getOriginalDelegateByLocationManager: manager];
    if (!sDelegate)
    {
        return;
    }

    if (sDelegate && [sDelegate respondsToSelector:@selector(locationManager:didChangeAuthorizationStatus:)])
    {
        [sDelegate locationManager:manager didChangeAuthorizationStatus:status];
    }

    return;
}

@end
