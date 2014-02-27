//
//  SMLoginViewController.h
//  SocialMediatorExample
//
//  Created by Gabi Martelo on 26/02/14.
//  Copyright (c) 2014 Kenoca. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
- (id)initLoginVC;
- (IBAction)handleTapBtnLoginFacebook:(id)sender;
- (IBAction)handleTapBtnLoginTwitter:(id)sender;

@end
