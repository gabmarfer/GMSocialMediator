//
//  GMFacebookUser.m
//  SocialMediatorExample
//
//  Created by Gabi Martelo on 26/02/14.
//  Copyright (c) 2014 Kenoca. All rights reserved.
//

#import "GMFacebookUser.h"

// Facebook parameters for response data
static NSString * const GMSocialMediatorFacebookResponseUserId = @"id";
static NSString * const GMSocialMediatorFacebookResponseUsername = @"name";
static NSString * const GMSocialMediatorFacebookResponseFirstName = @"first_name";
static NSString * const GMSocialMediatorFacebookResponseLastName = @"last_name";
static NSString * const GMSocialMediatorFacebookResponseEmail = @"email";
static NSString * const GMSocialMediatorFacebookResponseCity = @"location.name";
static NSString * const GMSocialMediatorFacebookResponseWebsite = @"website";
static NSString * const GMSocialMediatorFacebookResponseAboutMe = @"bio";
NSString * const GMSocialMediatorFacebookResponsePicture = @"data.url";
NSString * const GMSocialMediatorFacebookResponseFriendList = @"data";

@interface GMFacebookUser ()
@property (strong, nonatomic) NSMutableArray *friends;
@end

@implementation GMFacebookUser
- (id)initFacebookUserWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (self) {
        _userId = [[attributes valueForKeyPath:GMSocialMediatorFacebookResponseUserId] copy];
        _name = [[attributes valueForKeyPath:GMSocialMediatorFacebookResponseUsername] copy];
        _firstName = [[attributes valueForKeyPath:GMSocialMediatorFacebookResponseFirstName] copy];
        _lastName = [[attributes valueForKeyPath:GMSocialMediatorFacebookResponseLastName] copy];
        _email = [[attributes valueForKeyPath:GMSocialMediatorFacebookResponseEmail] copy];
        _city = [[attributes valueForKeyPath:GMSocialMediatorFacebookResponseCity] copy];
        _website = [[attributes valueForKeyPath:GMSocialMediatorFacebookResponseWebsite] copy];
        _aboutMe = [[attributes valueForKeyPath:GMSocialMediatorFacebookResponseAboutMe] copy];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", @{GMSocialMediatorFacebookResponseUserId: self.userId ?: [NSNull null],
                                               GMSocialMediatorFacebookResponseUsername: self.name ?: [NSNull null],
                                               GMSocialMediatorFacebookResponseFirstName: self.firstName ?: [NSNull null],
                                               GMSocialMediatorFacebookResponseLastName: self.lastName ?: [NSNull null],
                                               GMSocialMediatorFacebookResponseEmail: self.email ?: [NSNull null],
                                               GMSocialMediatorFacebookResponseCity: self.city ?: [NSNull null],
                                               @"photoURL": self.urlProfilePhoto ?: [NSNull null],
                                               GMSocialMediatorFacebookResponseWebsite: self.website ?: [NSNull null],
                                               GMSocialMediatorFacebookResponseAboutMe: self.aboutMe ?: [NSNull null],
                                               @"friendList": self.friends,
                                               }];
}

- (void)setFriendsWithArray:(NSArray *)friendList
{
    _friends = [NSMutableArray new];
    [_friends setArray:friendList];
}

- (NSArray *)friends
{
    if (!_friends) {
        _friends = [NSMutableArray new];
    }
    return _friends;
}

- (NSString *)friendsIds
{
    NSArray *arrayOfIds = [self.friends valueForKeyPath:@"userId"];
    return [arrayOfIds componentsJoinedByString:@","];
}
@end
