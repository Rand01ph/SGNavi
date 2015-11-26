#import "FixedLocationData.h"

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
