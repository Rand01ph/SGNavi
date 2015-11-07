#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import "SgLocationManagerDelegate.h"

SgLocationManagerDelegate* mSgDelegate = nil;

%hook CLLocationManager

+ (id)sharedInstance
{
    %log;

    return %orig;
}

- (id)init
{
    if (!mSgDelegate)
    {
        mSgDelegate = [[SgLocationManagerDelegate alloc] init];
        HBLogDebug(@"sg代理初始化");
    }
    return %orig;
}

- (void) setDelegate:(id<CLLocationManagerDelegate>)aDelegate
{

    if (aDelegate)
    {
        HBLogDebug(@"代理不为空");
        HBLogDebug(@"原装代理为:%@",NSStringFromClass([aDelegate class]));
        [mSgDelegate addOriginalDelegate:aDelegate CLLocationManager: self];
        %orig(mSgDelegate);
    }
    else
    {
        HBLogDebug(@"代理不存在");
        [mSgDelegate removeOriginalDelegateByLocationManager:self];
        %orig;
    }
}

- (CLLocation*) location
{
    HBLogDebug(@"I can get the location");
    %log;

    if (!mSgDelegate)
    {
        HBLogDebug(@"接管失败？");
        return %orig;
    }
    else
    {
        CLLocation* sFixedLocation = [mSgDelegate getFixedLocation];
        if (sFixedLocation)
        {
            HBLogDebug(@"位置改变");
            return sFixedLocation;
        }
        else
        {
            HBLogDebug(@"返回原始位置");
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
