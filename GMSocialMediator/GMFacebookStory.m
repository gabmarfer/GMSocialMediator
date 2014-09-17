//
//  GMFacebookStory.m
//  Yume
//
//  Created by Gabi Martelo on 08/08/14.
//  Copyright (c) 2014 Startcapps. All rights reserved.
//

#import "GMFacebookStory.h"

NSString * const GMFacebookStoryMessage = @"message";
NSString * const GMFacebookStoryLink = @"link";
NSString * const GMFacebookStoryPicture = @"picture";
NSString * const GMFacebookStoryName = @"name";
NSString * const GMFacebookStoryCaption = @"caption";
NSString * const GMFacebookStoryDescription = @"description";

@implementation GMFacebookStory

- (id)initWithMessage:(NSString *)message
           pictureUrl:(NSString *)pictureUrl
                 link:(NSString *)link
                 name:(NSString *)name
              caption:(NSString *)caption
     storyDescription:(NSString *)storyDescription
{
    self = [super init];
    if (self)  {
        _message = [message copy];
        _pictureUrl = [pictureUrl copy];
        _link = [link copy];
        _name = [name copy];
        _caption = [caption copy];
        _storyDescription = [storyDescription copy];
    }
    return self;
}

- (NSDictionary *)toDictionary
{
    return @{GMFacebookStoryMessage: self.message ?: [NSNull null],
             GMFacebookStoryLink: self.link ?: [NSNull null],
             GMFacebookStoryPicture: self.pictureUrl ?: [NSNull null],
             GMFacebookStoryName: self.name ?: [NSNull null],
             GMFacebookStoryCaption: self.caption ?: [NSNull null],
             GMFacebookStoryDescription: self.storyDescription ?: [NSNull null],
             };
}
@end
