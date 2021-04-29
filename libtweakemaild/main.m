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


static void sendEmailWithXPCObject(xpc_object_t object) {
    NSDictionary *dic = [NSDictionary dictionaryWithXPCObject:object];
    
    void *open = dlopen("/System/Library/PrivateFrameworks/MailServices.framework/MailServices", RTLD_NOW);
    if (open){
        NSString *senderEmail = nil;
        void *openmf = dlopen("/System/Library/Frameworks/MessageUI.framework/MessageUI", RTLD_NOW);
        if (openmf){
            CPLog("MFMailAccountProxyGenerator!");
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
        [objc_getClass("MSSendEmail") sendEmail:emailModel playSound:YES timeout:3.0 error:&err];
        if (err){
            CPLog("MSSendEmail error: %{public}@", err.localizedDescription);
        } else {
            CPLog("MSSendEmail sent email..yay!");
        }
        dlclose(open);
    }
}


static void libtweakemaild_peer_event_handler(xpc_connection_t peer, xpc_object_t event)
{
	xpc_type_t type = xpc_get_type(event);
	if (type == XPC_TYPE_ERROR) {
		if (event == XPC_ERROR_CONNECTION_INVALID) {
			// The client process on the other end of the connection has either
			// crashed or cancelled the connection. After receiving this error,
			// the connection is in an invalid state, and you do not need to
			// call xpc_connection_cancel(). Just tear down any associated state
			// here.
		} else if (event == XPC_ERROR_TERMINATION_IMMINENT) {
			// Handle per-connection termination cleanup.
		}
	} else {
		assert(type == XPC_TYPE_DICTIONARY);
        sendEmailWithXPCObject(event);

	}
}

static void libtweakemaild_event_handler(xpc_connection_t peer)
{
	// By defaults, new connections will target the default dispatch concurrent queue.
	xpc_connection_set_event_handler(peer, ^(xpc_object_t event) {
		libtweakemaild_peer_event_handler(peer, event);
	});
	
	// This will tell the connection to begin listening for events. If you
	// have some other initialization that must be done asynchronously, then
	// you can defer this call until after that initialization is done.
	xpc_connection_resume(peer);
}

int main(int argc, const char *argv[])
{
	xpc_connection_t service = xpc_connection_create_mach_service("com.cokepokes.libtweakemaild",
                                                                  dispatch_get_main_queue(),
                                                                  XPC_CONNECTION_MACH_SERVICE_LISTENER);
    
    if (!service) {
        NSLog(@"Failed to create service.");
        exit(EXIT_FAILURE);
    }
    
    xpc_connection_set_event_handler(service, ^(xpc_object_t connection) {
        libtweakemaild_event_handler(connection);
    });
    
    xpc_connection_resume(service);
    
    dispatch_main();
    
    // xpc_release(service);
    
    return EXIT_SUCCESS;
}



