//
//  GMFacebookUser.h
//  SocialMediatorExample
//
//  Created by Gabi Martelo on 26/02/14.
//  Copyright (c) 2014 Kenoca. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const GMSocialMediatorFacebookResponsePicture;
extern NSString * const GMSocialMediatorFacebookResponseFriendList;

/// Interface for Facebook users
@interface GMFacebookUser : NSObject
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, strong) NSURL *urlProfilePhoto;
@property (nonatomic, copy) NSString *website;
@property (nonatomic, copy) NSString *aboutMe;

- (id)initFacebookUserWithAttributes:(NSDictionary *)attributes;

/// An array or GMFacebookUsers that are friends of mine and have the Yume app
- (NSArray *)friends;
- (void)setFriendsWithArray:(NSArray *)friendList;
/// Returns a list of facebook friends user ids separated by commas
- (NSString *)friendsIds;
@end
