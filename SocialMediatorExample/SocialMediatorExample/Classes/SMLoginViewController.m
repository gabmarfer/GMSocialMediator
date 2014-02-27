//
//  SMLoginViewController.m
//  SocialMediatorExample
//
//  Created by Gabi Martelo on 26/02/14.
//  Copyright (c) 2014 Kenoca. All rights reserved.
//

#import "SMLoginViewController.h"
#import "GMSocialMediator.h"
#import "SMUserInfoViewController.h"

@interface SMLoginViewController ()

@end

@implementation SMLoginViewController

- (id)initLoginVC
{
    self = [super initWithNibName:@"SMLoginViewController" bundle:nil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    @throw [NSException exceptionWithName:@"Wrong initializer"
                                   reason:@"Use initLoginVC"
                                 userInfo:nil];
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Customize
    
    [[self navigationItem] setTitle:@"Login"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GMSocialMediator
#pragma mark --- Facebook
- (void)fetchFacebookInfo
{
    [[self spinner] startAnimating];
    [[self view] setUserInteractionEnabled:NO];
    
    __weak SMLoginViewController *weakSelf = self;
    [[GMSocialMediator sharedMediator] requestReadAccessToFacebookWithBlock:^(NSError *error) {
        if (!error) {
            [[GMSocialMediator sharedMediator] fetchFacebookUserInfoWithBlock:^(GMFacebookUser *facebookUser, NSError *error) {
                [weakSelf fetchFacebookInfoSucceededWithUser:facebookUser];
            }];
        } else {
            [weakSelf fetchFacebookInfoFailedWithError:error];
        }
    }];
}

- (void)fetchFacebookInfoSucceededWithUser:(GMFacebookUser *)fbUser
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self spinner] stopAnimating];
        [[self view] setUserInteractionEnabled:YES];
        SMUserInfoViewController *userInfoVC = [[SMUserInfoViewController alloc] initUserInfoWithFacebookUser:fbUser twitterUser:nil];
        [[self navigationController] pushViewController:userInfoVC animated:YES];
    });
}

- (void)fetchFacebookInfoFailedWithError:(NSError *)error
{
    NSLog(@"fetchFacebookInfoFailedWithError: %ld(%@)",(long)[error code], [error localizedDescription]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self spinner] stopAnimating];
        [[self view] setUserInteractionEnabled:YES];
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:[error localizedDescription]
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil, nil] show];
    });
}

#pragma mark --- Twitter
- (void)fetchTwitterInfo
{
    __weak SMLoginViewController *weakSelf = self;
    // Request access to Twitter accounts
    [[GMSocialMediator sharedMediator] requestReadAccessToTwitterWithBlock:^(NSError *error) {
        if (!error)
        {
            // Request the user to select one account
            [[GMSocialMediator sharedMediator] selectTwitterAccountWithSelectorInView:[self view] block:^(ACAccount *selectedTwitterAccount, NSError *error) {
                if (selectedTwitterAccount && !error)
                {
                    [[self spinner] startAnimating];
                    [[self view] setUserInteractionEnabled:NO];
                    [[GMSocialMediator sharedMediator] fetchUserDataForAccount:selectedTwitterAccount block:^(GMTwitterUser *twitterUser, NSError *error) {
                        if (twitterUser && !error)
                        {
                            [weakSelf fetchTwitterInfoSucceededWithUser:twitterUser];
                        }
                        else
                        {
                            [weakSelf fetchTwitterInfoFailedWithError:error];
                        }
                        
                    }];
                }
                else
                {
                    [weakSelf fetchTwitterInfoFailedWithError:error];
                }
            }];
        }
        else
        {
            [weakSelf fetchTwitterInfoFailedWithError:error];
        }
    }];
}

- (void)fetchTwitterInfoSucceededWithUser:(GMTwitterUser *)twUser
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self spinner] stopAnimating];
        [[self view] setUserInteractionEnabled:YES];
        SMUserInfoViewController *userInfoVC = [[SMUserInfoViewController alloc] initUserInfoWithFacebookUser:nil twitterUser:twUser];
        [[self navigationController] pushViewController:userInfoVC animated:YES];
    });
}

- (void)fetchTwitterInfoFailedWithError:(NSError *)error
{
    NSLog(@"fetchTwitterInfoFailedWithError: %ld(%@)",(long)[error code], [error localizedDescription]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self spinner] stopAnimating];
        [[self view] setUserInteractionEnabled:YES];
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:[error localizedDescription]
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil, nil] show];
    });
}

#pragma mark - IBActions
-(IBAction)handleTapBtnLoginFacebook:(id)sender
{
    [self fetchFacebookInfo];
}

- (IBAction)handleTapBtnLoginTwitter:(id)sender
{
    [self fetchTwitterInfo];
}

@end
