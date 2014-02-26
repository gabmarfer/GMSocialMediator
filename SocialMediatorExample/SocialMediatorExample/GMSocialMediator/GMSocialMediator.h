//
//  GMSocialMediator.h
//  iParticipa
//
//  Created by Gabi Martelo on 31/01/14.
//  Copyright (c) 2014 Startcapps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GMSocialMediatorFacebookError) {
    GMSocialMediatorFacebookErrorNoLocalAccount,
    GMSocialMediatorFacebookErrorNotGrantedPermissions,
    GMSocialMediatorFacebookErrorCouldNotParseData,
    GMSocialMediatorFacebookErrorUnkown,
};

// Facebook response parameters
extern NSString * const GMSocialMediatorFacebookResponseUserId;
extern NSString * const GMSocialMediatorFacebookResponseUsername;
extern NSString * const GMSocialMediatorFacebookResponseFirstName;
extern NSString * const GMSocialMediatorFacebookResponseLastName;
extern NSString * const GMSocialMediatorFacebookResponseEmail;

@class ACAccount;

/// Interface for Facebook users
@interface GMFacebookUser : NSObject
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *email;
- (id)initFacebookUserWithAttributes:(NSDictionary *)attributes;
@end


/// Social Mediator
@interface GMSocialMediator : NSObject
@property (nonatomic, strong, readonly) GMFacebookUser *facebookUser;
+ (GMSocialMediator *)sharedMediator;
// Facebook methods
- (BOOL)hasFacebookReadAccess;
- (ACAccount *)facebookAccount;
- (void)requestReadAccessToFacebookWithBlock:(void (^)(NSError *error))block;
- (void)fetchFacebookUserInfoWithBlock:(void (^)(GMFacebookUser *facebookUser, NSError *error))block;
@end


