//
//  GMFacebookUser.h
//  SocialMediatorExample
//
//  Created by Gabi Martelo on 26/02/14.
//  Copyright (c) 2014 Kenoca. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Interface for Facebook users
@interface GMFacebookUser : NSObject
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *email;
- (id)initFacebookUserWithAttributes:(NSDictionary *)attributes;
@end
