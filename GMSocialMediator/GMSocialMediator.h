//
//  GMSocialMediator.h
//  iParticipa
//
//  Created by Gabi Martelo on 31/01/14.
//  Copyright (c) 2014 Startcapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMFacebookUser.h"
#import "GMTwitterUser.h"

typedef NS_ENUM(NSUInteger, GMSocialMediatorError) {
    GMSocialMediatorErrorNoLocalAccount,
    GMSocialMediatorErrorNotGrantedPermissions,
    GMSocialMediatorErrorCouldNotParseData,
    GMSocialMediatorErrorUnkown,
    GMSocialMediatorErrorNotSelectedTwitterAccount,
};

@class ACAccount;

/// Social Mediator
@interface GMSocialMediator : NSObject

@property (nonatomic, strong, readonly) GMFacebookUser *facebookUser;
@property (nonatomic, strong, readonly) GMTwitterUser *twitterUser;

+ (GMSocialMediator *)sharedMediator;

// Facebook methods
- (BOOL)hasFacebookReadAccess;
- (ACAccount *)facebookAccount;
- (void)requestReadAccessToFacebookWithBlock:(void (^)(NSError *error))block;
- (void)fetchFacebookUserInfoWithBlock:(void (^)(GMFacebookUser *facebookUser, NSError *error))block;

// Twitter methods
- (BOOL)hasTwitterReadAccess;
- (NSArray *)allTwitterAccounts;
- (ACAccount *)twitterAccount;
- (void)requestReadAccessToTwitterWithBlock:(void (^)(NSError *error))block;
- (void)selectTwitterAccountWithSelectorInView:(UIView *)aView
                                   block:(void (^)(ACAccount *selectedTwitterAccount, NSError *error))block;
- (void)fetchUserDataForAccount:(ACAccount *)twitterAccount
                          block:(void (^)(GMTwitterUser *twitterUser, NSError *error))block;
- (void)fetchAllUserFriendsForAccount:(ACAccount *)twitterAccount
                                block:(void (^)(NSArray *friends, NSError *error))block;
- (void)fetchAllFollowersForAccount:(ACAccount *)twitterAccount
                              block:(void (^)(NSArray *followers, NSError *error))block;
@end


