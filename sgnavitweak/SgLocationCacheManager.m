#import "SgLocationCacheManager.h"
#import <Foundation/NSDistributedNotificationCenter.h>

@implementation SgLocationCacheManager

+ (_Bool)setFakeParametersDict:(NSDictionary *)sLocationDict {

    NSError *error;
    NSData *dataFakeNaviLocation = [NSPropertyListSerialization dataWithPropertyList:sLocationDict
                                                                              format:NSPropertyListBinaryFormat_v1_0
                                                                             options:0
                                                                               error:&error];

    if (dataFakeNaviLocation == nil) {
        HBLogDebug(@"数据序列化失败");
        return false;
    }else {
        BOOL writeStatus = [dataFakeNaviLocation writeToFile:@"/var/mobile/Library/Preferences/navi.sg"
                                                     options:NSDataWritingAtomic
                                                       error:&error];
        if (!writeStatus) {
            HBLogDebug(@"写文件失败");
            return false;
        }else {
            NSString *observeObject = @"com.sg.notification";
            NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
            [center postNotificationName: @"NOTIFICATION_FAKE_PARAMETERS_CHANGE"
                                  object: observeObject
                                userInfo: sLocationDict
                      deliverImmediately: YES];
        }
        return true;
    }
}

+ (id)sharedManager {
    static SgLocationCacheManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        NSString *observeObject = @"com.sg.notification";
        NSDistributedNotificationCenter *center = [NSDistributedNotificationCenter defaultCenter];
        [center addObserver: self
                   selector: @selector(sniffFakeParametersChange:)
                       name: @"NOTIFICATION_FAKE_PARAMETERS_CHANGE"
                     object: observeObject];
    }
    return self;
}

- (void)sniffFakeParametersChange:(NSNotification*)notif {
    NSString *fakeObserveObject = @"com.sg.fakeNotification";
    NSDistributedNotificationCenter *fakeCenter = [NSDistributedNotificationCenter defaultCenter];
    [fakeCenter postNotificationName: @"NOTIFICATION_FIXED_LOCATION_CHANGE_SGNAVI"
                              object: fakeObserveObject
                            userInfo: notif.userInfo
                  deliverImmediately: YES];
    return ;
}

- (void)dealloc {
    [super dealloc];
}

@end
