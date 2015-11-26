#import <SpringBoard/SpringBoard.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import "FixedLocationData.h"
#import "SgLocationCacheManager.h"
#import "SgLocationManagerDelegate.h"

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {

    CPDistributedMessagingCenter *messagingCenter;
    // Center name must be unique, recommend using application identifier.
    messagingCenter = [CPDistributedMessagingCenter centerNamed:@"com.sg.springboard.writeserver"];
    [messagingCenter runServerOnCurrentThread];

    [messagingCenter registerForMessageName:@"message" target:self selector:@selector(handleMessageNamed:withUserInfo:)];

    %orig;
}

%new
- (NSDictionary *)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userinfo {
    HBLogDebug(@"Tweak get the message");

    if (!userinfo) {
        HBLogDebug(@"But the message in null");
        return nil;
    }

    [SgLocationCacheManager setFakeParametersDict:userinfo];

    HBLogDebug(@"The userinfo is %@", userinfo);

    return userinfo;
}

%end


static SgLocationManagerDelegate* mSgDelegate = nil;

%hook CLLocationManager

+ (id)sharedInstance {
    %log;
    return %orig;
}

- (void)init {
    if (!mSgDelegate)
    {
        mSgDelegate = [[SgLocationManagerDelegate alloc] init];
        HBLogDebug(@"SgLocationManagerDelegate initialize");
    }
    %orig;
}

- (void)setDelegate:(id<CLLocationManagerDelegate>)aDelegate {

    if (aDelegate)
    {
        HBLogDebug(@"The Delegate is not NULL");
        HBLogDebug(@"The Original Delegate is:%@",NSStringFromClass([aDelegate class]));
        [mSgDelegate addOriginalDelegate:aDelegate CLLocationManager: self];
        %orig(mSgDelegate);
    }
    else
    {
        HBLogDebug(@"There is no original delegate");
        [mSgDelegate removeOriginalDelegateByLocationManager:self];
        %orig;
    }
}

- (CLLocation*)location
{
    HBLogDebug(@"I can get the location");
    %log;

    if (!mSgDelegate)
    {
        HBLogDebug(@"The SgDelegate is lose");
        return %orig;
    }
    else
    {
        FixedLocationData* sFixedLocationData = [mSgDelegate getFixedLocationData];
        if (sFixedLocationData)
        {
            HBLogDebug(@"Location has changed");
            return sFixedLocationData.mFixedLocation;
        }
        else
        {
            HBLogDebug(@"return the original loaction");
            return %orig;
        }
    }
}

- (void) dealloc
{
    [mSgDelegate removeOriginalDelegateByLocationManager:self];
    %orig;
}

%end
