//  Copyright © 2016 Onegini. All rights reserved.

#import "OGCDVUserAuthenticationClient.h"
#import "OGCDVUserClientHelper.h"
#import "OGCDVConstants.h"

@implementation OGCDVUserAuthenticationClient {
}

- (void)getAuthenticatedUserProfile:(CDVInvokedUrlCommand *)command
{
    ONGUserProfile *authenticatedUserProfile = [[ONGUserClient sharedInstance] authenticatedUserProfile];
    if (authenticatedUserProfile == nil) {
        [self sendErrorResultForCallbackId:command.callbackId withMessage:OGCDVPluginErrorKeyNoUserAuthenticated];
    } else {
        NSDictionary *result = @{OGCDVPluginKeyProfileId: authenticatedUserProfile.profileId};
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result] callbackId:command.callbackId];
    }
}

- (void)start:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        NSDictionary *options = command.arguments[0];
        NSString *profileId = options[OGCDVPluginKeyProfileId];

        ONGUserProfile *authenticatedUserProfile = [[ONGUserClient sharedInstance] authenticatedUserProfile];
        if (authenticatedUserProfile && [authenticatedUserProfile.profileId isEqualToString:profileId]) {
            [self sendErrorResultForCallbackId:command.callbackId withMessage:@"Onegini: User already authenticated."];
            return;
        }

        self.authenticationCallbackId = command.callbackId;

        ONGUserProfile *user = [OGCDVUserClientHelper getRegisteredUserProfile:profileId];
        if (user == nil) {
            [self sendErrorResultForCallbackId:command.callbackId withMessage:@"Onegini: No registered user found."];
        } else {
            [[ONGUserClient sharedInstance] authenticateUser:user delegate:self];
        }
    }];
}

- (void)providePin:(CDVInvokedUrlCommand *)command
{
    if (!self.pinChallenge) {
        [self sendErrorResultForCallbackId:command.callbackId withMessage:@"Onegini: please invoke 'onegini.user.authenticate.start' first."];
        return;
    }
    [self.commandDelegate runInBackground:^{
        self.checkPinCallbackId = command.callbackId;
        NSDictionary *options = command.arguments[0];
        NSString *pin = options[OGCDVPluginKeyPin];
        [self.pinChallenge.sender respondWithPin:pin challenge:self.pinChallenge];
    }];
}

- (void)respondToFingerprintRequest:(CDVInvokedUrlCommand *)command
{
    if (!self.fingerprintChallenge) {
        [self sendErrorResultForCallbackId:command.callbackId withMessage:@"Onegini: no pin challenge active"];
        return;
    }

    [self.commandDelegate runInBackground:^{
        NSDictionary *options = command.arguments[0];
        BOOL shouldAccept = [options[OGCDVPluginKeyAccept] boolValue];

        if (shouldAccept) {
            NSString *prompt = options[OGCDVPluginKeyPrompt];
            [self.fingerprintChallenge.sender respondWithPrompt:prompt challenge:self.fingerprintChallenge];
        } else {
            [self.fingerprintChallenge.sender cancelChallenge:self.fingerprintChallenge];
        }
    }];
}

- (void)fallbackToPin:(CDVInvokedUrlCommand *)command
{
    if (!self.fingerprintChallenge) {
        [self sendErrorResultForCallbackId:command.callbackId withMessage:@"Onegini: no pin challenge active"];
        return;
    }

    [self.commandDelegate runInBackground:^{
        [self.fingerprintChallenge.sender respondWithPinFallbackForChallenge:self.fingerprintChallenge];
    }];
}

- (void)reauthenticate:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        NSDictionary *options = command.arguments[0];
        NSString *profileId = options[OGCDVPluginKeyProfileId];

        self.authenticationCallbackId = command.callbackId;

        ONGUserProfile *user = [OGCDVUserClientHelper getRegisteredUserProfile:profileId];
        if (user == nil) {
            [self sendErrorResultForCallbackId:command.callbackId withMessage:@"Onegini: No registered user found."];
        } else {
            [[ONGUserClient sharedInstance] reauthenticateUser:user delegate:self];
        }
    }];
}

- (void)logout:(CDVInvokedUrlCommand *)command
{
    [self.commandDelegate runInBackground:^{
        [[ONGUserClient sharedInstance] logoutUser:^(ONGUserProfile *_Nonnull userProfile, NSError *_Nullable error) {
            if (error != nil) {
                [self sendErrorResultForCallbackId:command.callbackId withError:error];
            } else {
                [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
            }
        }];
    }];
}

@end
