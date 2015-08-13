//
//  MoxtraMeetIntegration.m
//
//  Created by Jacob ding on 10/10/14.
//
//

#import "MoxtraMeetIntegration.h"


typedef void(^MXBLOCK_INV)();

@interface MoxtraMeetIntegration()
@property(nonatomic, readwrite, assign) BOOL registedFlag;

@property(nonatomic, readwrite, assign) BOOL userSetupFlag;
@property(nonatomic, readwrite, assign) BOOL waitingForUserSetupCallbackFlag;

@property(nonatomic, readwrite, retain) NSMutableArray *operationQueue; //MXBLOCK_INV items.

- (void)_registerAppIfNeed;
@end

@implementation MoxtraMeetIntegration

- (void)_registerAppIfNeed
{
    if( !self.registedFlag )
    {
        self.registedFlag = YES;
        [Moxtra clientWithApplicationClientID:@"APP_ID" applicationClientSecret:@"CLIENT_SECRET" serverType:productionServer];
    }
}

- (void)setUser:(CDVInvokedUrlCommand*)command
{
    [self _registerAppIfNeed];
    if( [[Moxtra sharedClient] isUserLoggedIn])
        return;
    if( self.userSetupFlag )
        return;
    if( command.arguments.count < 4 || [[command.arguments objectAtIndex:2] length] <= 0 )
    {
        [self.commandDelegate evalJs:@"alert('Invalid user account setting!')"];
        return;
        //
    }
    
    self.waitingForUserSetupCallbackFlag = YES;
    MXUserIdentity *userIdentity = [[MXUserIdentity alloc] init];
    userIdentity.userIdentityType = kUserIdentityTypeIdentityUniqueID;
    userIdentity.userIdentity = [command.arguments objectAtIndex:2];
    [[Moxtra sharedClient] initializeUserAccount:userIdentity orgID:[command.arguments objectAtIndex:3] firstName:[command.arguments objectAtIndex:0] lastName:[command.arguments objectAtIndex:1] avatar:nil devicePushNotificationToken:nil withTimeout:0.0 success:^{
        self.waitingForUserSetupCallbackFlag = NO;
        [self.commandDelegate evalJs:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').setupUserSuccessCallback();"];
        
        //invoke all actions in queue.
        [self.operationQueue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MXBLOCK_INV invoke = obj;
            invoke();
        }];
        [self.operationQueue removeAllObjects];
        
    } failure:^(NSError *error) {
         self.waitingForUserSetupCallbackFlag = NO;
        [self.commandDelegate evalJs:[NSString stringWithFormat:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').setupUserFailedCallback('%ld', '%@');", (long)[error code], [error localizedDescription]]];
        
        //invoke all actions in queue.
        [self.operationQueue enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MXBLOCK_INV invoke = obj;
            invoke();
        }];
        [self.operationQueue removeAllObjects];
    }];
}

- (void)updateUser:(CDVInvokedUrlCommand*)command;
{
    [self _registerAppIfNeed];
    NSString *firstName = [command.arguments objectAtIndex:0];
    NSString *lastName = [command.arguments objectAtIndex:1];
    MXBLOCK_INV invoke = ^(){
        [[Moxtra sharedClient] updateUserProfile:firstName lastName:lastName avatar:nil success:^{
            [self.commandDelegate evalJs:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').updateUserProfileSuccessCallback();"];
        } failure:^(NSError *error) {
            [self.commandDelegate evalJs:[NSString stringWithFormat:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').updateUserProfileFailedCallback('%ld', '%@');", (long)[error code], [error localizedDescription]]];
        }];
    };
    if( self.waitingForUserSetupCallbackFlag )
    {
        if( self.operationQueue == nil )
            self.operationQueue = [NSMutableArray array];
        [self.operationQueue addObject: [invoke copy]];
    }
    else
    {
        invoke();
    }
}

- (void)logout:(CDVInvokedUrlCommand*)command
{
    if( ![[Moxtra sharedClient] isUserLoggedIn])
        return;
    [[Moxtra sharedClient] unlinkAccount:^(BOOL success) {
        [self.commandDelegate evalJs:[NSString stringWithFormat:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').unlinkAccountCompletionCallback('%d');", success]];
    }];
}

- (void) startMeet:(CDVInvokedUrlCommand*)command;
{
    [self _registerAppIfNeed];
    NSString *arg1 = [command.arguments objectAtIndex:0];
    MXBLOCK_INV invoke = ^(){
        [[Moxtra sharedClient] startMeet:arg1 withDelegate:self inviteAttendeesBlock:nil success:^(NSString *meetID) {
            NSLog(@"Start meet success with MeetId [%@]", meetID);
            [self.commandDelegate evalJs:[NSString stringWithFormat:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').startMeetSuccessCallback('%@');",meetID]];
        } failure:^(NSError *error) {
            NSLog(@"error code [%ld] description: [%@] info [%@]", (long)[error code], [error localizedDescription], [[error userInfo] description]);
            [self.commandDelegate evalJs:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').startMeetFailedCallback();"];
        }];
    };
    if( self.waitingForUserSetupCallbackFlag )
    {
        if( self.operationQueue == nil )
            self.operationQueue = [NSMutableArray array];
        [self.operationQueue addObject: [invoke copy]];
    }
    else
    {
        invoke();
    }
}

- (void)joinMeet:(CDVInvokedUrlCommand*)command;
{
    [self _registerAppIfNeed];
    NSString *username = [command.arguments objectAtIndex:0];
    NSString *meetid = [command.arguments objectAtIndex:1];
    MXBLOCK_INV invoke = ^(){
        [[Moxtra sharedClient] joinMeet:meetid withUserName:username withDelegate:self inviteAttendeesBlock:nil success:^(NSString *meetID) {
            [self.commandDelegate evalJs:[NSString stringWithFormat:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').startMeetSuccessCallback('%@');",meetID]];
        } failure:^(NSError *error) {
            [self.commandDelegate evalJs:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').startMeetFailedCallback();"];
        }];
    };
    if( self.waitingForUserSetupCallbackFlag )
    {
        if( self.operationQueue == nil )
            self.operationQueue = [NSMutableArray array];
        [self.operationQueue addObject: [invoke copy]];
    }
    else
    {
        invoke();
    }
}


#pragma mark - 
#pragma mark - MXClientMeetDelegate
- (void)meetEnded
{
    NSString* javascript = [NSString stringWithFormat:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').endMeetCallback();"];
    [self.commandDelegate evalJs:javascript];
}

- (BOOL)hideInviteButton
{
    NSString* javascript = [NSString stringWithFormat:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').hideInviteButton();"];
    NSString* returnFlag = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    if( [returnFlag isEqualToString:@"false"] )
        return NO;
    else
        return YES;
}

- (BOOL)supportAutoJoinAudio
{
    NSString* javascript = [NSString stringWithFormat:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').supportAutoJoinAudio();"];
    NSString* returnFlag = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    if( [returnFlag isEqualToString:@"false"] )
        return NO;
    else
        return YES;
}

- (BOOL)supportAutoStartScreenShare
{
    NSString* javascript = [NSString stringWithFormat:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').supportAutoStartScreenShare();"];
    NSString* returnFlag = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    if( [returnFlag isEqualToString:@"false"] )
        return NO;
    else
        return YES;
}

- (BOOL)supportInviteContactsBySMS
{
    NSString* javascript = [NSString stringWithFormat:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').supportInviteContactsBySMS();"];
    NSString* returnFlag = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    if( [returnFlag isEqualToString:@"false"] )
        return NO;
    else
        return YES;
}

- (BOOL)supportInviteContactsByEmail
{
    NSString* javascript = [NSString stringWithFormat:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').supportInviteContactsByEmail();"];
    NSString* returnFlag = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    if( [returnFlag isEqualToString:@"false"] )
        return NO;
    else
        return YES;
}

/**
 * Called when the user invite attendees via pressing invite button in meet. Return the customized subject/body.
 * There will be default subject/body if return value is null.
 */
- (NSString *)bodyOfSMSContentWithMeetLink:(NSString*)meetLink
{
    NSString* javascript = [NSString stringWithFormat:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').getBodyOfSMSContentWithMeetLink('%@');",meetLink];
    NSString* returnFlag = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    if( returnFlag.length == 0 || [returnFlag isEqualToString:@"null"])
        return nil;
    return returnFlag;

}
- (NSString *)subjectOfEmailContent
{
    NSString* javascript = [NSString stringWithFormat:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').subjectOfEmailContentTitle();"];
    NSString* subject = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    if( subject.length == 0 || [subject isEqualToString:@"null"])
        return nil;
    return subject;
}

- (NSString *)HTMLBodyOfEmailContentWithMeetLink:(NSString*)meetLink
{
    NSString* javascript = [NSString stringWithFormat:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').getBodyOfEmailContentWithMeetLink('%@');",meetLink];
    NSString* returnFlag = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    if( returnFlag.length == 0 || [returnFlag isEqualToString:@"null"])
        return nil;
    return returnFlag;
}

- (NSString *)customizedInviteMessage:(NSString *)meetLink withBeJoinedAudio:(BOOL)beJoinedAudio withBeStartedSharing:(BOOL)beStartedSharing
{
    NSString* javascript = [NSString stringWithFormat:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').getCustomizedInviteMessage('%@', '%d', '%d');",meetLink, beJoinedAudio, beStartedSharing];
    NSString* returnFlag = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    if( returnFlag.length == 0 || [returnFlag isEqualToString:@"null"])
        return nil;
    return returnFlag;
}

- (BOOL)autoHideControlBar
{
    NSString* javascript = [NSString stringWithFormat:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').autoHideControlBar();"];
    NSString* returnFlag = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    if( [returnFlag isEqualToString:@"false"] )
        return NO;
    else
        return YES;
}

- (BOOL)supportVoIP
{
    NSString* javascript = [NSString stringWithFormat:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').supportVoIP();"];
    NSString* returnFlag = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    if( [returnFlag isEqualToString:@"false"] )
        return NO;
    else
        return YES;
}

- (BOOL)supportChat
{
    NSString* javascript = [NSString stringWithFormat:@"window.cordova.require('cordova/plugin/MoxtraMeetIntegration').supportChat();"];
    NSString* returnFlag = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    if( [returnFlag isEqualToString:@"false"] )
        return NO;
    else
        return YES;
}

@end
