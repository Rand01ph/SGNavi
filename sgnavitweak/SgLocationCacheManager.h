#import <Foundation/Foundation.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "FixedLocationData.h"

@interface SgLocationCacheManager : NSObject
{
}

+ (_Bool)setFakeParametersDict:(NSDictionary *)sLocationDict;
+ (id)sharedManager;
- (id)init;
- (void)dealloc;


@end
