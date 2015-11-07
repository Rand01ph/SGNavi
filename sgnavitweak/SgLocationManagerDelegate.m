#import "SgLocationManagerDelegate.h"

//=======================================================
@implementation FixedLocationData

@synthesize mIsSet;
@synthesize mFixedLocation;

+ (FixedLocationData*) getNewInstance
{
    FixedLocationData* newInstance = [[[FixedLocationData alloc] init] autorelease];
    return newInstance;
}

- (void) dealloc
{
    self.mFixedLocation = nil;
    [super dealloc];
}

@end

//=======================================================
//加强版LocationManager+Delegate 集合
@implementation ExLocationManager_Delegate

@synthesize exLocationManager;
@synthesize exDelegate;

+ (ExLocationManager_Delegate*) getNewInstance
{
    ExLocationManager_Delegate* newInstance = [[[ExLocationManager_Delegate alloc] init] autorelease];

    return newInstance;
}

- (void) dealloc
{
    self.exLocationManager = nil;
    self.exDelegate = nil;
    [super dealloc];
}

@end


//=======================================================
//松果LocationManagerDelegate实现
@implementation SgLocationManagerDelegate
@synthesize mOriginalDelegates;

- (id) init
{
    self = [super init];
    if (self)
    {
        self.mOriginalDelegates = [NSMutableArray arrayWithCapacity: 5];
    }
    return self;
}

- (void) dealloc
{
    self.mOriginalDelegates =nil;
    [super dealloc];
}

- (CLLocation*) getFixedLocation
{
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:39.54
                                                 longitude:116.28];
    return loc;
}

- (ExLocationManager_Delegate*)getLocationManagerDelegateByLocationManager:(CLLocationManager*)aLocationManager
{
    for (ExLocationManager_Delegate *eLMD in self.mOriginalDelegates)
    {
        if (eLMD.exLocationManager == aLocationManager)
        {
            HBLogDebug(@"原始代理获取");
            return eLMD;
        }
    }

    return nil;
}


- (id<CLLocationManagerDelegate>) getOriginalDelegateByLocationManager:(CLLocationManager*)aLocationManager
{
    HBLogDebug(@"获取代理方法");
    ExLocationManager_Delegate* sLocationManager_delegate = [self getLocationManagerDelegateByLocationManager: aLocationManager];
    if (sLocationManager_delegate)
    {
        HBLogDebug(@"代理方法get");
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

    HBLogDebug(@"add my delegate.");

    [self removeOriginalDelegateByLocationManager: aLocationManager];

    ExLocationManager_Delegate* sLocationManager_delegate = [ExLocationManager_Delegate getNewInstance];
    sLocationManager_delegate.exLocationManager = aLocationManager;
    sLocationManager_delegate.exDelegate = aDelegate;

    [self.mOriginalDelegates addObject: sLocationManager_delegate];

    HBLogDebug(@"delegate added.");
}

- (void)removeOriginalDelegateByLocationManager:(CLLocationManager*) aLocationManager
{
    HBLogDebug(@"remove delegate");

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
        return;
    }

    id<CLLocationManagerDelegate> sDelegate = nil;
    sDelegate = newLocationManager_delegate.exDelegate;

    if (sDelegate && [sDelegate respondsToSelector:@selector(locationManager:didUpdateLocations:locations:)])
    {
        //FixedLocationData* sFixedLocationData = [self getFixedLocationData];
        CLLocation* sFixedLocation = [self getFixedLocation];
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

            //CLLocation* sFixedLocation = sFixedLocationData.mFixedLocation;

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

@end
