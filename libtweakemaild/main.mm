//
//  main.m
//  libtweakemaild
//
//  Created by CokePokes on 4/21/21.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

// XPC Service: Lightweight helper tool that performs work on behalf of an application.
// see http://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingXPCServices.html

#include <xpc/xpc.h> // Create a symlink to OSX's SDK. For example, in Terminal run: ln -s /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.8.sdk/usr/include/xpc /opt/iOSOpenDev/include/xpc
#include <Foundation/Foundation.h>
#import "NSDictionary+CDXPC.h"
#import "mailheaders.h"
#include <objc/objc-runtime.h>
#include <dlfcn.h>
#import <Accounts/Accounts.h>

extern "C" CFNotificationCenterRef CFNotificationCenterGetDistributedCenter();
static void sendEmail(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    NSData *data = [(__bridge NSString *)object dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dic = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil] mutableCopy];
        
    void *open = dlopen("/System/Library/PrivateFrameworks/MailServices.framework/MailServices", RTLD_NOW);
    if (open){
        NSString *senderEmail = nil;
        void *openmf = dlopen("/System/Library/Frameworks/MessageUI.framework/MessageUI", RTLD_NOW);
        if (openmf){
            MFMailAccountProxyGenerator *generator = [[objc_getClass("MFMailAccountProxyGenerator") alloc] init];
            MFMailAccountProxy *mailProxy = [generator defaultMailAccountProxyForDeliveryOriginatingBundleID:@"com.apple.mobilemail" sourceAccountManagement:1];
            senderEmail = mailProxy.firstEmailAddress;
            dlclose(openmf);
        }
        
        MSEmailModel *emailModel = [[objc_getClass("MSEmailModel") alloc] init];
        emailModel.sender = senderEmail;
        if (!dic[@"bcc"]){
            emailModel.to = dic[@"to"];
        } else {
            emailModel.bcc = dic[@"bcc"];
        }
        emailModel.subject = dic[@"subject"];
        emailModel.body = dic[@"body"];
        emailModel.type = 1;
                
        NSError *err = nil;
        [objc_getClass("MSSendEmail") sendEmail:emailModel playSound:NO timeout:3.0 error:&err];
        if (err){
            CPLog("MSSendEmail error: %{public}@", err.localizedDescription);
        } else {
            CPLog("MSSendEmail sent email..yay!");
        }
        dlclose(open);
    }
}


int main(int argc, const char *argv[])
{
    @autoreleasepool {
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
        
        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
        for (;;)
            [runLoop run];
        return 0;
    }
}



