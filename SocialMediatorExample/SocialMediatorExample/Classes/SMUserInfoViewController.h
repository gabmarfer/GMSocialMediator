//
//  SMUserInfoViewController.h
//  SocialMediatorExample
//
//  Created by Gabi Martelo on 26/02/14.
//  Copyright (c) 2014 Kenoca. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GMFacebookUser, GMTwitterUser;

@interface SMUserInfoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtSurname;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;

- (id)initUserInfoWithFacebookUser:(GMFacebookUser *)aFacebookUser twitterUser:(GMTwitterUser *)aTwitterUser;
@end
