//
//  GMTwitterUser.h
//  SocialMediatorExample
//
//  Created by Gabi Martelo on 26/02/14.
//  Copyright (c) 2014 Kenoca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GMTwitterUser : NSObject
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *username;
- (id)initTwitterUserWithAttributes:(NSDictionary *)attributes;
@end
