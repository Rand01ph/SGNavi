#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface FixedLocationData : NSObject
{
    BOOL mIsSet;
    CLLocation* mFixedLocation;
}

+ (FixedLocationData*) getNewInstance;
- (void) dealloc;
@property (nonatomic, assign) BOOL mIsSet;
@property (nonatomic, retain) CLLocation* mFixedLocation;

@end

