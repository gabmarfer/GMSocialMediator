//
//  GMTwitterUser.m
//  SocialMediatorExample
//
//  Created by Gabi Martelo on 26/02/14.
//  Copyright (c) 2014 Kenoca. All rights reserved.
//

#import "GMTwitterUser.h"

// Twitter parameters for response data
NSString * const GMSocialMediatorTwitterResponseUserId = @"id_str";
NSString * const GMSocialMediatorTwitterResponseUsername = @"name";
NSString * const GMSocialMediatorTwitterResponseName = @"screen_name";

@implementation GMTwitterUser
- (id)initTwitterUserWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (self) {
        _userId = [[attributes valueForKeyPath:GMSocialMediatorTwitterResponseUserId] copy];
        _name = [[attributes valueForKeyPath:GMSocialMediatorTwitterResponseUsername] copy];
        _username = [[attributes valueForKeyPath:GMSocialMediatorTwitterResponseName] copy];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@",@{GMSocialMediatorTwitterResponseUserId: self.userId,
                                              GMSocialMediatorTwitterResponseUsername: self.name,
                                              GMSocialMediatorTwitterResponseName: self.username,
                                              }];
}

@end
