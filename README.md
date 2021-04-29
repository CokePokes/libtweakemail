# libtweakemail
Email library for Jailbroken Devices

`Requires iOS10+ maybe lower haven't tested`

This library can be used in a sandboxed app or a regular tweak on a jailbroken device. 

How to use in your tweak/app:

```objc

#include <dlfcn.h>

@interface libtweakemail : NSObject
+ (void)sendEmailTo:(NSArray*)toArray bcc:(NSArray*)bccArray subject:(NSString*)subject body:(NSString*)body;
@end

- (void)showNotification {

	void *handle = dlopen("/Library/MobileSubstrate/DynamicLibraries/libtweakemail.dylib", RTLD_NOW);
	if (handle != NULL) {                                            
    
 	   [objc_getClass("libtweakemail") sendEmailTo:@[@"coolstuff123123@gmail.com", @"goddamn325w34@gmail.com"]]
                            bcc:nil
                        subject:@"Pretty Cool Tweak Huh?"
                           body:@"Hard body?"];
					       				       
	   dlclose(handle);
	}
}





```

```

```
