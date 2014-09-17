//
//  GMFacebookStory.h
//  Yume
//
//  Created by Gabi Martelo on 08/08/14.
//  Copyright (c) 2014 Startcapps. All rights reserved.
//

/**
 * A Facebook story that can be published to Facebook
 * 
 * Example:
 * Jorge Gonzalez
 * 21 de mayo via Friendkhana
 *
 * Has created a new challenge --> message
 *
 * Picture --> pictureUrl + link
 *         #aSegunda --> name
 *         End in 2 days --> caption
 *         Este año subimos a segunda. La afición está volcada --> description
 *
 */

extern NSString * const GMFacebookStoryMessage;
extern NSString * const GMFacebookStoryLink;
extern NSString * const GMFacebookStoryPicture;
extern NSString * const GMFacebookStoryName;
extern NSString * const GMFacebookStoryCaption;
extern NSString * const GMFacebookStoryDescription;

#import <Foundation/Foundation.h>

@interface GMFacebookStory : NSObject
/// The text that describes the action
@property (copy, nonatomic) NSString *message;
/// The link of the site that will be open when the user tap on the picture
@property (copy, nonatomic) NSString *link;
/// The picture url
@property (copy, nonatomic) NSString *pictureUrl;
/// The title of the picture that appears near to it
@property (copy, nonatomic) NSString *name;
/// The subtitle of the picture that appears just below the title
@property (copy, nonatomic) NSString *caption;
/// A text that appears below the caption
@property (copy, nonatomic) NSString *storyDescription;

- (id)initWithMessage:(NSString *)message
           pictureUrl:(NSString *)pictureUrl
                 link:(NSString *)link
                 name:(NSString *)name
              caption:(NSString *)caption
     storyDescription:(NSString *)storyDescription;

- (NSDictionary *)toDictionary;
@end
