//
//  MoxtraMeetIntegration.h
//
//  Created by Jacob ding on 10/10/14.
//
//

#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVInvokedUrlCommand.h>
#import "Moxtra.h"


@interface MoxtraMeetIntegration : CDVPlugin <MXClientMeetDelegate>

- (void)setUser:(CDVInvokedUrlCommand*)command;
- (void)updateUser:(CDVInvokedUrlCommand*)command;
- (void)logout:(CDVInvokedUrlCommand*)command;
- (void)startMeet:(CDVInvokedUrlCommand*)command;
- (void)joinMeet:(CDVInvokedUrlCommand*)command;

@end

