//
//  SMUserInfoViewController.m
//  SocialMediatorExample
//
//  Created by Gabi Martelo on 26/02/14.
//  Copyright (c) 2014 Kenoca. All rights reserved.
//

#import "SMUserInfoViewController.h"
#import "GMFacebookUser.h"
#import "GMTwitterUser.h"

@interface SMUserInfoViewController ()
@property (nonatomic, strong) GMFacebookUser *facebookUser;
@property (nonatomic, strong) GMTwitterUser *twitterUser;
@end

@implementation SMUserInfoViewController

- (id)initUserInfoWithFacebookUser:(GMFacebookUser *)aFacebookUser twitterUser:(GMTwitterUser *)aTwitterUser
{
    self = [super initWithNibName:@"SMUserInfoViewController" bundle:nil];
    if (self) {
        // Custom initialization
        _facebookUser = aFacebookUser;
        _twitterUser = aTwitterUser;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:@"Wrong initializer"
                                   reason:@"Use initUserInfoWithFacebookUser: or initUserInfoWithTwitterUser:"
                                 userInfo:nil];
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    
    // Set placeholders
    [[self txtName] setPlaceholder:@"Name"];
    [[self txtSurname] setPlaceholder:@"Surname"];
    [[self txtEmail] setPlaceholder:@"Email"];
    [[self txtUsername] setPlaceholder:@"Username"];
    
    if ([self facebookUser])
    {
        [self fillDataForFacebookUser];
    }
    
    else if ([self twitterUser])
    {
        [self fillDataForTwitterUser];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Customize
    
    [[self navigationItem] setTitle:@"User info"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Supplementary methods
- (void)fillDataForFacebookUser
{
    [[self txtName] setText:[[self facebookUser] firstName]];
    [[self txtSurname] setText:[[self facebookUser] lastName]];
    [[self txtEmail] setText:[[self facebookUser] email]];
    [[self txtUsername] setText:[[self facebookUser] name]];
}

- (void)fillDataForTwitterUser
{
    [[self txtName] setText:[[self twitterUser] name]];
    [[self txtUsername] setText:[[self twitterUser] username]];
}
@end
