//
//  GMSocialMediator.h
//  iParticipa
//
//  Created by Gabi Martelo on 31/01/14.
//  Copyright (c) 2014 Startcapps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMFacebookUser.h"
#import "GMFacebookStory.h"
#import "GMTwitterUser.h"

typedef NS_ENUM(NSUInteger, GMSocialMediatorError) {
    GMSocialMediatorErrorNoLocalAccount,
    GMSocialMediatorErrorNotGrantedPermissions,
    GMSocialMediatorErrorCouldNotParseData,
    GMSocialMediatorErrorUnkown,
    GMSocialMediatorErrorNotSelectedTwitterAccount,
    GMSocialMediatorErrorInviteFriends,
};

@class ACAccount;

/// Social Mediator
@interface GMSocialMediator : NSObject

+ (GMSocialMediator *)sharedMediator;

+ (NSString *)defaultTextToShare;

#pragma mark - Facebook methods
// ---------------
//
//
// Facebook methods
//
// ---------------
- (BOOL)hasFacebookReadAccess;
- (BOOL)hasFacebookPublishAccess;
- (ACAccount *)facebookAccount;

/**
 * Request Read Access Permissions to Facebook
 *
 * @discussion Only make the request if we don't have requested the same
 * permissions previously
 * @param block A Block with an error or nil
 * @return
 */
- (void)requestReadAccessToFacebookWithBlock:(void (^)(NSError *error))block;

/**
 * Request Publish Access Permissions to Facebook
 *
 * @discussion Only make the request if we don't have requested the same permissions previosly
 * @param block A block with an error or nil
 * @return
 */
- (void)requestPublishPermissionsToFacebookWithBlock:(void (^)(NSError *error))block;

/**
 * Get basic info for the device Facebook user
 *
 * @discussion This method only makes the request if we have requested the Read permissions previously
 * @param block A block with a facebook user and an error or nil
 * @return
 */
- (void)requestFacebookUserBasicInfoWithBlock:(void (^)(GMFacebookUser *facebookUser, NSError *error))block;

/**
 * Get the URL for the profile photo for the device Facebook user
 *
 * @param block A block with the URL and an error or nil
 * @return
 */
- (void)requestFacebookUserProfilePhotoWithBlock:(void (^)(NSURL *photoUrl, NSError *error))block;

/**
 * Get the list of Facebook friends for the device Facebook user
 *
 * @param block A block with an array of GMFacebookUser objects and an error or nil
 * @return
 */
- (void)requestFacebookUserFriendsWithBlock:(void (^)(NSArray *friends, NSError *error))block;

/**
 * Invite friends to use this app
 *
 * @param block A block with an error or nil
 * @return
 */
- (void)makeFriendRequestWithBlock:(void (^)(NSError *error))block;

/**
 * Publish a story to Facebook
 *
 * @param fbStory The Facebook story to be published
 * @param block A block with an error or nil
 * @return
 */
- (void)requestPublishFacebookStory:(GMFacebookStory *)fbStory block:(void (^)(NSError *error))block;

#pragma mark - Twitter methods
// ---------------
//
//
// Twitter methods
//
// ---------------

- (BOOL)hasTwitterReadAccess;
- (NSArray *)allTwitterAccounts;
- (ACAccount *)twitterAccount;

/**
 * Request Read Access Permissions to Twitter accounts
 *
 * @discussion Only make the request if we don't have requested the same
 * permissions previously
 * @param block A Block with an error or nil
 * @return
 */
- (void)requestReadAccessToTwitterWithBlock:(void (^)(NSError *error))block;

/**
 * Present an ActionSheet to the user to select a Twitter Account
 *
 * @param aView The UIView in which to present the ActionSheet
 * @param block A Block with the selected Twitter account or an error
 * @return
 */
- (void)selectTwitterAccountWithSelectorInView:(UIView *)aView
                                   block:(void (^)(ACAccount *selectedTwitterAccount, NSError *error))block;

/**
 * Fetch Twitter user info
 *
 * @param twitterAccount The ACAccount from which to read user info
 * @param block A block with the GMTwitterUser or an error
 * @return
 */
- (void)requestTwitterUserDataForAccount:(ACAccount *)twitterAccount
                          block:(void (^)(GMTwitterUser *twitterUser, NSError *error))block;

/**
 * Fetch friends list (people that i am following)
 *
 * @param twitterAccount The Twitter account from which to fetch the friends
 * @param block A Block with the list of friends and an error or nil
 * @return
 */
- (void)requestTwitterAllUserFriendsForAccount:(ACAccount *)twitterAccount
                                block:(void (^)(NSArray *friends, NSError *error))block;

/**
 * Fetch followers list (people that are following me)
 *
 * @param twitterAccount The Twitter account to fetch the friends
 * @param block A Block with the list of followers and an error or nil
 * @return
 */
- (void)requestTwitterAllFollowersForAccount:(ACAccount *)twitterAccount
                              block:(void (^)(NSArray *followers, NSError *error))block;
@end


