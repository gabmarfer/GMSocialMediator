//
//  GMFacebookUser.m
//  SocialMediatorExample
//
//  Created by Gabi Martelo on 26/02/14.
//  Copyright (c) 2014 Kenoca. All rights reserved.
//

#import "GMFacebookUser.h"

// Facebook parameters for response data
NSString * const GMSocialMediatorFacebookResponseUserId = @"id";
NSString * const GMSocialMediatorFacebookResponseUsername = @"name";
NSString * const GMSocialMediatorFacebookResponseFirstName = @"first_name";
NSString * const GMSocialMediatorFacebookResponseLastName = @"last_name";
NSString * const GMSocialMediatorFacebookResponseEmail = @"email";

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
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@",@{GMSocialMediatorFacebookResponseUserId: self.userId,
                                              GMSocialMediatorFacebookResponseUsername: self.name,
                                              GMSocialMediatorFacebookResponseFirstName: self.firstName,
                                              GMSocialMediatorFacebookResponseLastName: self.lastName,
                                              GMSocialMediatorFacebookResponseEmail: self.email,
                                              }];
}
@end
