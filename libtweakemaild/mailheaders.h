//
//  mailheaders.h
//  libtweakemaild
//
//  Created by CokePokes on 4/21/21.
//

#import <Foundation/Foundation.h>

@protocol OS_dispatch_queue, OS_xpc_object;
@class NSObject;

@interface MSService : NSObject {

    int _canceled;
    //NSObject*<OS_dispatch_queue> _connectionQueue;
    //NSObject*<OS_dispatch_queue> _replyQueue;
    //NSObject*<OS_xpc_object> _connection;
    //NSObject*<OS_xpc_object> _responseListener;
    //NSObject*<OS_xpc_object> _responseHandler;
}
@property (getter=isCanceled,readonly) BOOL canceled;
-(id)_connection;
-(BOOL)isCanceled;
-(id)init;
-(id)_generateUnitTestReplyForMethod:(id)arg1 arg:(id)arg2 error:(id*)arg3 ;
-(void)stop;
-(void)cancel;
-(void)_generateUnitTestResponsesForResultArray:(id)arg1 ;
-(void)start;
-(void)dealloc;
-(BOOL)_unitTestsAreEnabled;
-(void)_callServicesMethod:(id)arg1 arguments:(id)arg2 callback:(/*^block*/id)arg3 ;
-(void)_simulateServicesMethod:(id)arg1 arguments:(id)arg2 callback:(/*^block*/id)arg3 ;
-(id)_handleMessageSendFailure:(id)arg1 message:(id)arg2 messageIndex:(long long)arg3 context:(inout id*)arg4 ;
-(id)_createServiceOnQueue:(id)arg1 ;
-(void)responseConnection:(id)arg1 handleError:(id)arg2 ;
-(void)_registerConnection:(id)arg1 onQueue:(id)arg2 ;
-(void)responseConnection:(id)arg1 handleResponse:(id)arg2 ;
-(void)_callServicesMethod:(id)arg1 arguments:(id)arg2 replyHandler:(/*^block*/id)arg3 ;
-(id)_createMessageForService:(id)arg1 arguments:(id)arg2 index:(long long*)arg3 ;
-(void)setupResponseConnectionOnQueue:(id)arg1 ;
@end

@interface MSMailDefaultService : MSService {

    BOOL _shouldLaunch;
}
@property (assign,nonatomic) BOOL shouldLaunchMobileMail;              //@synthesize shouldLaunch=_shouldLaunch - In the implementation block
-(id)init;
-(BOOL)shouldLaunchMobileMail;
-(void)setShouldLaunchMobileMail:(BOOL)arg1 ;
-(BOOL)_launchMobileMailSuspendedError:(id*)arg1 ;
-(id)_handleMessageSendFailure:(id)arg1 message:(id)arg2 messageIndex:(long long)arg3 context:(inout id*)arg4 ;
-(id)_createServiceOnQueue:(id)arg1 ;
@end

@interface MSSendEmail : MSMailDefaultService

+(id)sendMessageData:(id)arg1 autosaveIdentifier:(id)arg2 completionBlock:(/*^block*/id)arg3 ;
+(id)sendEmail:(id)arg1 playSound:(BOOL)arg2 completionBlock:(/*^block*/id)arg3 ;
+(id)sendEmail:(id)arg1 playSound:(BOOL)arg2 timeout:(double)arg3 error:(id*)arg4 ;
-(void)_simulateServicesMethod:(id)arg1 arguments:(id)arg2 callback:(/*^block*/id)arg3 ;
-(void)_sendMessageData:(id)arg1 autosaveIdentifier:(id)arg2 completionBlock:(/*^block*/id)arg3 ;
-(void)_sendEmail:(id)arg1 playSound:(BOOL)arg2 completionBlock:(/*^block*/id)arg3 ;
@end


@class NSString, NSArray, NSURL;

@interface MSEmailModel : NSObject <NSSecureCoding> {

    int _type;
    NSString* _subject;
    NSString* _sender;
    NSArray* _to;
    NSArray* _cc;
    NSArray* _bcc;
    NSString* _body;
    NSURL* _reference;
}
@property (nonatomic,copy) NSString * subject;               //@synthesize subject=_subject - In the implementation block
@property (nonatomic,copy) NSString * sender;                //@synthesize sender=_sender - In the implementation block
@property (nonatomic,copy) NSArray * to;                     //@synthesize to=_to - In the implementation block
@property (nonatomic,copy) NSArray * cc;                     //@synthesize cc=_cc - In the implementation block
@property (nonatomic,copy) NSArray * bcc;                    //@synthesize bcc=_bcc - In the implementation block
@property (nonatomic,retain) NSString * body;                //@synthesize body=_body - In the implementation block
@property (nonatomic,retain) NSURL * reference;              //@synthesize reference=_reference - In the implementation block
@property (assign,nonatomic) int type;                       //@synthesize type=_type - In the implementation block
+(BOOL)supportsSecureCoding;
-(NSArray *)to;
-(void)setBody:(NSString *)arg1 ;
-(NSArray *)cc;
-(NSArray *)bcc;
-(void)setSender:(NSString *)arg1 ;
-(void)setSubject:(NSString *)arg1 ;
-(void)setCc:(NSArray *)arg1 ;
-(void)setTo:(NSArray *)arg1 ;
-(NSURL *)reference;
-(void)setType:(int)arg1 ;
-(id)initWithCoder:(id)arg1 ;
-(NSString *)sender;
-(void)setReference:(NSURL *)arg1 ;
-(void)encodeWithCoder:(id)arg1 ;
-(void)setBcc:(NSArray *)arg1 ;
-(NSString *)body;
-(NSString *)subject;
-(int)type;
@end

@interface MSAccounts : MSMailDefaultService

+(id)attachmentCapabilities;
+(id)customSignatureForSendingEmailAddress:(id)arg1 ;
+(void)accountValuesForKeys:(id)arg1 originatingBundleID:(id)arg2 sourceAccountManagement:(int)arg3 launchMobileMail:(BOOL)arg4 completionBlock:(/*^block*/id)arg5 ;
+(BOOL)canSendMail;
+(BOOL)hasActiveAccounts;
+(BOOL)canSendMailSourceAccountManagement:(int)arg1 ;
+(void)accountValuesForKeys:(id)arg1 completionBlock:(/*^block*/id)arg2 ;
+(void)accountValuesForKeys:(id)arg1 launchMobileMail:(BOOL)arg2 completionBlock:(/*^block*/id)arg3 ;
+(BOOL)deleteAccountsWithUniqueIdentifiers:(id)arg1 error:(id*)arg2 ;
+(void)mailboxListingForAccountWithUniqueIdentifier:(id)arg1 keys:(id)arg2 completionBlock:(/*^block*/id)arg3 ;
+(BOOL)setPushStateForMailboxWithPath:(id)arg1 account:(id)arg2 pushState:(BOOL)arg3 error:(id*)arg4 ;
-(void)_listAccountKeys:(id)arg1 originatingBundleID:(id)arg2 sourceAccountManagement:(int)arg3 handler:(/*^block*/id)arg4 ;
-(void)_simulateServicesMethod:(id)arg1 arguments:(id)arg2 callback:(/*^block*/id)arg3 ;
@end


@class NSDictionary, NSString, NSArray;

@interface MFMailAccountProxy : NSObject {

    NSDictionary* _properties;
}
@property (nonatomic,readonly) NSString * fullUserName;
@property (nonatomic,readonly) NSString * username;
@property (nonatomic,readonly) NSString * firstEmailAddress;
@property (nonatomic,readonly) NSArray * emailAddresses;
@property (nonatomic,readonly) NSArray * fromEmailAddresses;
@property (nonatomic,readonly) NSArray * fromEmailAddressesIncludingDisabled;
@property (nonatomic,readonly) NSString * uniqueID;
@property (nonatomic,readonly) BOOL isDefaultDeliveryAccount;
@property (nonatomic,readonly) BOOL supportsThreadOperations;
@property (nonatomic,readonly) BOOL restrictsRepliesAndForwards;
@property (nonatomic,readonly) BOOL supportsMailDrop;
@property (nonatomic,readonly) BOOL isManaged;
@property (nonatomic,readonly) id mailAccount;
-(NSString *)uniqueID;
-(BOOL)_isActive;
-(BOOL)supportsThreadOperations;
-(NSString *)username;
-(BOOL)isManaged;
-(NSArray *)emailAddresses;
-(id)mailAccount;
-(BOOL)isDefaultDeliveryAccount;
-(id)_emailAddressesAndAliases;
-(BOOL)restrictsRepliesAndForwards;
-(BOOL)_isRestricted;
-(NSString *)fullUserName;
-(NSArray *)fromEmailAddressesIncludingDisabled;
-(NSString *)firstEmailAddress;
-(NSArray *)fromEmailAddresses;
-(id)_initWithProperties:(id)arg1 ;
-(BOOL)supportsMailDrop;
@end

@protocol MFMailAccountProxyGenerator <NSObject>
@required
-(id)defaultMailAccountProxyForDeliveryOriginatingBundleID:(id)arg1 sourceAccountManagement:(int)arg2;
-(id)accountProxyContainingEmailAddress:(id)arg1 includingInactive:(BOOL)arg2 originatingBundleID:(id)arg3 sourceAccountManagement:(int)arg4;
-(id)allAccountProxies;
-(id)activeAccountProxiesOriginatingBundleID:(id)arg1 sourceAccountManagement:(int)arg2;
-(id)accountProxyContainingEmailAddress:(id)arg1 includingInactive:(BOOL)arg2;

@end

@class _MFMailAccountProxySource, NSString;

@interface MFMailAccountProxyGenerator : NSObject <MFMailAccountProxyGenerator> {

    _MFMailAccountProxySource* _proxySource;
    BOOL _allowsRestrictedAccounts;
}
@property (readonly) unsigned long long hash;
@property (readonly) Class superclass;
@property (copy,readonly) NSString * description;
@property (copy,readonly) NSString * debugDescription;
-(id)init;
-(id)defaultMailAccountProxyForDeliveryOriginatingBundleID:(id)arg1 sourceAccountManagement:(int)arg2 ;
-(id)accountProxyContainingEmailAddress:(id)arg1 includingInactive:(BOOL)arg2 originatingBundleID:(id)arg3 sourceAccountManagement:(int)arg4 ;
-(id)initWithAllowsRestrictedAccounts:(BOOL)arg1 ;
-(id)allAccountProxies;
-(id)activeAccountProxiesOriginatingBundleID:(id)arg1 sourceAccountManagement:(int)arg2 ;
-(id)accountProxyContainingEmailAddress:(id)arg1 includingInactive:(BOOL)arg2 ;
@end
