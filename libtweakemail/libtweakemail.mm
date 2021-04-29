//
//  libtweakemail.mm
//  libtweakemail
//
//  Created by CokePokes on 4/21/21.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

// CaptainHook by Ryan Petrich
// see https://github.com/rpetrich/CaptainHook/

#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <Foundation/Foundation.h>
#import "CaptainHook/CaptainHook.h"
#include <notify.h> // not required; for examples only
#import <dlfcn.h>
#import "mailheaders.h"
#import "NSDictionary+CDXPC.h"

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter();

@interface libtweakemail : NSObject
@end

@implementation libtweakemail

-(id)init
{
	if ((self = [super init]))
	{
	}
    return self;
}

+ (void)sendEmailTo:(NSArray*)toArray bcc:(NSArray*)bccArray subject:(NSString*)subject body:(NSString*)body {
    NSMutableDictionary *constructedDic = [NSMutableDictionary dictionary];
    if (toArray)
        [constructedDic setObject:toArray forKey:@"to"];
    if (bccArray)
        [constructedDic setObject:bccArray forKey:@"bcc"];
    if (subject)
        [constructedDic setObject:subject forKey:@"subject"];
    if (body)
        [constructedDic setObject:body forKey:@"body"];
 
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:constructedDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("com.cokepokes.libtweakemail"), (__bridge const void *)json, NULL, true); //we use this so sandboxed apps can send emails since xpc is not allowed
}

@end


static void sendEmail(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSData *data = [(__bridge NSString *)object dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *constructedDic = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil] mutableCopy];
    
    xpc_connection_t client = xpc_connection_create_mach_service("com.cokepokes.libtweakemaild",
                                                                 NULL,
                                                                 0);
    xpc_connection_set_event_handler(client, ^(xpc_object_t event) {
        CPLog("ERROR: xpc_connection_set_event_handler");
    });
    xpc_connection_resume(client);
    xpc_connection_send_message(client, [(NSDictionary*)constructedDic.copy XPCObject]);
}


CHConstructor // code block that runs immediately upon load
{
    @autoreleasepool {
        if ([NSProcessInfo.processInfo.processName isEqualToString:@"SpringBoard"]){ //only want springboard to run server
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                void *handle = dlopen("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation", RTLD_LAZY);
                void *impl = NULL;
                if (handle) {
                    impl = dlsym(handle, "CFNotificationCenterGetDistributedCenter");
                }
                if (impl) { // Available.
                    // Registration in receiver process.
                    CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(),
                                                    NULL,
                                                    sendEmail,
                                                    CFSTR("com.cokepokes.libtweakemail"),
                                                    NULL,
                                                    CFNotificationSuspensionBehaviorDeliverImmediately);
                    
                }
            });
        }
    }
}






