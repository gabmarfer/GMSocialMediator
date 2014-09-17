//
//  GMSocialMediator.m
//  iParticipa
//
//  Created by Gabi Martelo on 31/01/14.
//  Copyright (c) 2014 Startcapps. All rights reserved.
//

#import "GMSocialMediator.h"
#import "UIActionSheet+Blocks.h"
@import Accounts;
@import Social;
#import <FacebookSDK/FacebookSDK.h>

//static NSString * const GMSocialMediatorFacebookAppId = @"1436396976626996";
static NSString * const GMSocialMediatorFacebookAppId = @"1426906887537214";

@interface GMSocialMediator () <UIActionSheetDelegate>
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccount *facebookAccount;
@property (nonatomic, strong) NSArray *allTwitterAccounts;
@property (nonatomic, strong) ACAccount *twitterAccount;
@property (nonatomic, getter = hasFacebookReadAccess) __block BOOL facebookReadAccess;
@property (nonatomic, getter = hasFacebookPublishAccess) __block BOOL facebookPublishAccess;
@property (nonatomic, getter = hasTwitterReadAccess) __block BOOL twitterReadAccess;
@end

@implementation GMSocialMediator

+ (NSString *)defaultTextToShare
{
    return [NSString stringWithFormat:NSLocalizedString(@"kTextFacebookRequest", nil), YMYumeUrliTunes, YMYumeUrlGooglePlay];
}

+ (GMSocialMediator *)sharedMediator
{
    static GMSocialMediator *_sharedMediator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMediator = [[GMSocialMediator alloc] init];
    });
    
    return _sharedMediator;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Create an Account Store
        _accountStore = [[ACAccountStore alloc] init];
    }
    return self;
}

- (NSString *)localizedStringForKey:(NSString *)key withDefault:(NSString *)defaultString
{
    static NSBundle *bundle = nil;
    if (bundle == nil)
    {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:NSStringFromClass([self class]) ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:bundlePath];
        NSString *language = [[NSLocale preferredLanguages] count] ? [NSLocale preferredLanguages][0] : @"es";
        if (![[bundle localizations] containsObject:language])
        {
            language = [language componentsSeparatedByString:@"-"][0];
        }
        if ([[bundle localizations] containsObject:language])
        {
            bundlePath = [bundle pathForResource:language ofType:@"lproj"];
        }
        bundle = [NSBundle bundleWithPath:bundlePath] ?: [NSBundle mainBundle];
    }
    defaultString = [bundle localizedStringForKey:key value:defaultString table:nil];
    return [[NSBundle mainBundle] localizedStringForKey:key value:defaultString table:nil];
}

#pragma mark - Facebook methods
- (BOOL)hasFacebookReadAccess
{
    return _facebookReadAccess;
}

- (BOOL)hasFacebookPublishAccess
{
    return _facebookPublishAccess;
}

- (ACAccount *)facebookAccount
{
    return _facebookAccount;
}

#pragma mark --- Request permissions methods
- (void)requestReadAccessToFacebookWithBlock:(void (^)(NSError *error))block
{
    if (![self hasFacebookReadAccess])
    {
        // Specify the permissions required
        NSArray *permissions = @[@"basic_info",
                                 @"user_about_me",
                                 @"user_friends",
                                 @"user_location",
                                 @"user_website",
                                 @"email"];
        
        // Specify the audience
        NSDictionary *facebookOptions = @{ACFacebookAppIdKey : GMSocialMediatorFacebookAppId,
                                          ACFacebookPermissionsKey : permissions,
                                          };
        
        // Specify the Account Type
        ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        if (!accountType.accessGranted)
        {
            _facebookReadAccess = NO;
        }
        
        // Perform the permission request
        [self.accountStore requestAccessToAccountsWithType:accountType options:facebookOptions completion:^(BOOL granted, NSError *error) {
            if (granted)
            {
                NSLog(@"Facebook read access granted.");

                _facebookReadAccess = YES;
                NSArray *allAccounts = [self.accountStore accountsWithAccountType:accountType];
                self.facebookAccount = [allAccounts lastObject];
                
                if (block)
                    block(nil);
            }
            
            if (error)
            {
                NSUInteger statusCode = 0;
                
                if (error.code == 6)
                {
                    NSLog(@"Error: There is no Facebook account setup.");
                    statusCode = GMSocialMediatorErrorNoLocalAccount;
                }
                else
                {
                    NSLog(@"Error: %ld(%@)", (long)[error code], [error localizedDescription]);
                    statusCode = GMSocialMediatorErrorUnkown;
                }
                
                NSError *anError = [NSError errorWithDomain:NSStringFromClass([self class])
                                                       code:statusCode
                                                   userInfo:@{NSLocalizedDescriptionKey: [error localizedDescription]}];
                if (block)
                    block(anError);
            }
        }];
    }
    else
    {
        // We already have read access, so go on
        if (block)
            block(nil);
    }
}

- (void)requestPublishPermissionsToFacebookWithBlock:(void (^)(NSError *error))block
{
    if (![self hasFacebookPublishAccess])
    {
        // Specify the permissions required
        NSArray *permissions = @[@"publish_actions"];
        
        // Specify the audience
        NSDictionary *facebookOptions = @{ACFacebookAppIdKey : GMSocialMediatorFacebookAppId,
                                          ACFacebookPermissionsKey : permissions,
                                          ACFacebookAudienceKey: ACFacebookAudienceFriends,
                                          };
        
        // Specify the Account Type
        ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        if (!accountType.accessGranted)
        {
            _facebookPublishAccess = NO;
        }
        
        // Perform the permission request
        [self.accountStore requestAccessToAccountsWithType:accountType options:facebookOptions completion:^(BOOL granted, NSError *error) {
            if (granted)
            {
                NSLog(@"Facebook publish permissions granted.");
                
                _facebookPublishAccess = YES;
                NSArray *allAccounts = [self.accountStore accountsWithAccountType:accountType];
                self.facebookAccount = [allAccounts lastObject];
                
                if (block)
                    block(nil);
            }
            
            if (error)
            {
                NSUInteger statusCode = 0;
                
                if (error.code == 6)
                {
                    NSLog(@"Error: There is no Facebook account setup.");
                    statusCode = GMSocialMediatorErrorNoLocalAccount;
                }
                else
                {
                    NSLog(@"Error: %ld(%@)", (long)[error code], [error localizedDescription]);
                    statusCode = GMSocialMediatorErrorUnkown;
                }
                
                NSError *anError = [NSError errorWithDomain:NSStringFromClass([self class])
                                                       code:statusCode
                                                   userInfo:@{NSLocalizedDescriptionKey: [error localizedDescription]}];
                if (block)
                    block(anError);
            }
        }];
    }
    else
    {
        // We already have read access, so go on
        if (block)
            block(nil);
    }
}

#pragma mark --- Get basic info
- (void)requestFacebookUserBasicInfoWithBlock:(void (^)(GMFacebookUser *, NSError *))block
{
    if ([self hasFacebookReadAccess])
    {
        // Basic info request
        NSURL *urlMe = [NSURL URLWithString:@"https://graph.facebook.com/me"];
        SLRequest *requestBasicInfo = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:urlMe parameters:nil];
        
        ACAccountType *account_type_facebook = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        [self.facebookAccount setAccountType:account_type_facebook];
        [requestBasicInfo setAccount:self.facebookAccount];
        
        __weak GMSocialMediator *weakSelf = self;
        // REQUEST BASIC INFO
        [requestBasicInfo performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error)
            {
                NSDictionary *parsedResponse = [weakSelf p_parseJSONWithData:responseData];
                if (parsedResponse)
                {
                    STLog(@"FacebookResponse: %@", parsedResponse);
                    GMFacebookUser *aFbUser = [[GMFacebookUser alloc] initFacebookUserWithAttributes:parsedResponse];
                    if (block)
                        block(aFbUser, nil);
                }
                else
                {
                    NSError *anError = [NSError errorWithDomain:NSStringFromClass([self class])
                                                           code:GMSocialMediatorErrorCouldNotParseData
                                                       userInfo:@{NSLocalizedDescriptionKey: [self localizedStringForKey:@"kCouldNotParseResponse"
                                                                                                             withDefault:@"Cannot fetch user info."]}];
                    if (block)
                        block(nil, anError);
                }
                
            }
            else
            {
                NSLog(@"Error %ld", (long)[urlResponse statusCode]);
                NSError *anError = [NSError errorWithDomain:NSStringFromClass([self class])
                                                       code:GMSocialMediatorErrorUnkown
                                                   userInfo:@{NSLocalizedDescriptionKey: [self localizedStringForKey:@"kErrorCouldNotConnectWithFacebook"
                                                                                                         withDefault:@"Cannot connect with Facebook"]}];
                if (block)
                    block(nil, anError);
            }
        }];
    }
    else
    {
        NSError *anError = [NSError errorWithDomain:NSStringFromClass([self class])
                                               code:GMSocialMediatorErrorNotGrantedPermissions
                                           userInfo:@{NSLocalizedDescriptionKey: [self localizedStringForKey:@"kErrorAccessNotGranted"
                                                                                                 withDefault:@"Need Read Access permissions to your Facebook account."]}];
        if (block)
            block(nil, anError);
    }
}

#pragma mark --- Get photo
- (void)requestFacebookUserProfilePhotoWithBlock:(void (^)(NSURL *photoUrl, NSError *error))block
{
    NSURL *urlPicture = [NSURL URLWithString:@"https://graph.facebook.com/me/picture"];
    SLRequest *requestPicture = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                   requestMethod:SLRequestMethodGET
                                                             URL:urlPicture
                                                      parameters:@{@"redirect": @"false"}];
    
    ACAccountType *account_type_facebook = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    [self.facebookAccount setAccountType:account_type_facebook];
    [requestPicture setAccount:self.facebookAccount];
    
    // REQUEST PROFILE PHOTO
    __weak GMSocialMediator *weakSelf = self;
    [requestPicture performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (!error)
        {
            NSDictionary *parsedResponse = [weakSelf p_parseJSONWithData:responseData];
            if (parsedResponse)
            {
                NSString *profilePhoto = [parsedResponse valueForKeyPath:GMSocialMediatorFacebookResponsePicture];
                NSURL *urlProfilePhoto = (profilePhoto != nil) ? [NSURL URLWithString:profilePhoto] : nil;
                if (block)
                    block(urlProfilePhoto, nil);
            }
            else
            {
                NSError *anError = [NSError errorWithDomain:NSStringFromClass([self class])
                                                       code:GMSocialMediatorErrorCouldNotParseData
                                                   userInfo:@{NSLocalizedDescriptionKey: [self localizedStringForKey:@"kCouldNotParseResponse"
                                                                                                         withDefault:@"Cannot fetch user info."]}];
                if (block)
                    block(nil, anError);
            }
        }
        else
        {
            NSError *anError = [NSError errorWithDomain:NSStringFromClass([self class])
                                                   code:GMSocialMediatorErrorUnkown
                                               userInfo:@{NSLocalizedDescriptionKey: [self localizedStringForKey:@"kErrorCouldNotConnectWithFacebook"
                                                                                                     withDefault:@"Cannot connect with Facebook"]}];
            if (block)
                block(nil, anError);
        }
    }];
}

#pragma mark --- Get friends
- (void)requestFacebookUserFriendsWithBlock:(void (^)(NSArray *friends, NSError *error))block
{
    NSURL *urlFriends = [NSURL URLWithString:@"https://graph.facebook.com/me/friends"];
    SLRequest *requestFriends = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:urlFriends parameters:nil];
    
    ACAccountType *account_type_facebook = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    [self.facebookAccount setAccountType:account_type_facebook];
    [requestFriends setAccount:self.facebookAccount];
    
    __weak GMSocialMediator *weakSelf = self;
    [requestFriends performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (!error)
        {
            NSDictionary *parsedResponse = [weakSelf p_parseJSONWithData:responseData];
            if (parsedResponse)
            {
                NSArray *friendList = [parsedResponse valueForKeyPath:GMSocialMediatorFacebookResponseFriendList];
                NSMutableArray *friends = [NSMutableArray new];
                [friendList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    GMFacebookUser *anUser = [[GMFacebookUser alloc] initFacebookUserWithAttributes:(NSDictionary *)obj];
                    [friends addObject:anUser];
                }];
                
                if (block)
                    block(friends, nil);
            }
            else
            {
                NSError *anError = [NSError errorWithDomain:NSStringFromClass([self class])
                                                       code:GMSocialMediatorErrorCouldNotParseData
                                                   userInfo:@{NSLocalizedDescriptionKey: [self localizedStringForKey:@"kCouldNotParseResponse"
                                                                                                         withDefault:@"Cannot fetch user info."]}];
                if (block)
                    block(@[], anError);
            }
        }
        else
        {
            NSError *anError = [NSError errorWithDomain:NSStringFromClass([self class])
                                                   code:GMSocialMediatorErrorUnkown
                                               userInfo:@{NSLocalizedDescriptionKey: [self localizedStringForKey:@"kErrorCouldNotConnectWithFacebook"
                                                                                                     withDefault:@"Cannot connect with Facebook"]}];
            if (block)
                block(@[], anError);
        }
    }];
}

#pragma mark --- Publish to Facebook
- (void)requestPublishFacebookStory:(GMFacebookStory *)fbStory block:(void (^)(NSError *))block
{
    if ([self hasFacebookPublishAccess])
    {
        // Basic info request
        NSURL *urlFeed = [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
        NSDictionary *params = [fbStory toDictionary];
        NSLog(@"facebookParams: %@", params);
        SLRequest *requestPublish = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodPOST URL:urlFeed parameters:params];
        
        ACAccountType *account_type_facebook = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        [self.facebookAccount setAccountType:account_type_facebook];
        [requestPublish setAccount:self.facebookAccount];
        
        __weak GMSocialMediator *weakSelf = self;
        // REQUEST PUBLISH
        [requestPublish performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error)
            {
                NSDictionary *parsedResponse = [weakSelf p_parseJSONWithData:responseData];
                if (parsedResponse)
                {
                    STLog(@"FacebookResponse: %@", parsedResponse);
                    if (block)
                        block(nil);
                }
                else
                {
                    NSError *anError = [NSError errorWithDomain:NSStringFromClass([self class])
                                                           code:GMSocialMediatorErrorCouldNotParseData
                                                       userInfo:@{NSLocalizedDescriptionKey: [self localizedStringForKey:@"kCouldNotParseResponse"
                                                                                                             withDefault:@"Cannot fetch user info."]}];
                    if (block)
                        block(anError);
                }
                
            }
            else
            {
                NSLog(@"Error %ld", (long)[urlResponse statusCode]);
                NSError *anError = [NSError errorWithDomain:NSStringFromClass([self class])
                                                       code:GMSocialMediatorErrorUnkown
                                                   userInfo:@{NSLocalizedDescriptionKey: [self localizedStringForKey:@"kErrorCouldNotConnectWithFacebook"
                                                                                                         withDefault:@"Cannot connect with Facebook"]}];
                if (block)
                    block(anError);
            }
        }];

    }
    else
    {
        NSError *anError = [NSError errorWithDomain:NSStringFromClass([self class])
                                               code:GMSocialMediatorErrorNotGrantedPermissions
                                           userInfo:@{NSLocalizedDescriptionKey: [self localizedStringForKey:@"kErrorAccessNotGranted"
                                                                                                 withDefault:@"Need Publish Permissions to your Facebook account."]}];
        if (block)
            block(anError);
    }
}

#pragma mark --- Make requests
- (void)makeFriendRequestWithBlock:(void (^)(NSError *error))block
{
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:[GMSocialMediator defaultTextToShare]
     title:nil
     parameters:nil
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or sending the request.
             STLog(@"Error sending request.");
             if (block) {
                 block(error);
             }
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 STLog(@"User canceled request.");
                 NSError *error = [[NSError alloc] initWithDomain:NSStringFromClass([self class])
                                                             code:GMSocialMediatorErrorInviteFriends
                                                         userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"kErrorInviteFriendsRequestCanceled", nil)}];
                 if (block) {
                     block(error);
                 }
             } else {
                 // Handle the send request callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"request"]) {
                     // User clicked the Cancel button
                     STLog(@"User canceled request.");
                     NSError *error = [[NSError alloc] initWithDomain:NSStringFromClass([self class])
                                                                 code:GMSocialMediatorErrorInviteFriends
                                                             userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"kErrorInviteFriendsRequestCanceled", nil)}];
                     if (block) {
                         block(error);
                     }
                 } else {
                     // User clicked the Send button
                     NSString *requestID = [urlParams valueForKey:@"request"];
                     STLog(@"Sent Request with ID: %@", requestID);
                     if (block) {
                         block(nil);
                     }
                 }
             }
         }
     }];
}

/**
 * Helper method for parsing URL parameters.
 */
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

#pragma mark - Twitter methods
- (BOOL)hasTwitterReadAccess
{
    return _twitterReadAccess;
}

- (NSArray *)allTwitterAccounts
{
    if (!_allTwitterAccounts)
        _allTwitterAccounts = [NSArray array];
    return _allTwitterAccounts;
}

- (ACAccount *)twitterAccount
{
    return _twitterAccount;
}

#pragma mark --- Twitter requests
- (void)requestReadAccessToTwitterWithBlock:(void (^)(NSError *error))block
{
    if (![self hasTwitterReadAccess])
    {
        // Create an account type that ensures Twitter account are retrieved
        ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        if (!accountType.accessGranted)
        {
            _twitterReadAccess = NO;
        }
        
        // Request access from the user to use their Twitter accounts
        __weak GMSocialMediator *weakSelf = self;
        [self.accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
            if (granted && !error)
            {
                NSLog(@"Twitter read access granted.");
                
                _twitterReadAccess = YES;
                if (!_allTwitterAccounts)
                    _allTwitterAccounts = [NSArray array];
                _allTwitterAccounts = [self.accountStore accountsWithAccountType:accountType];
                weakSelf.twitterAccount = [_allTwitterAccounts lastObject];
                
                if (block)
                    block(nil);
            }
            else
            {
                NSError *anError = [NSError errorWithDomain:NSStringFromClass([self class])
                                                       code:GMSocialMediatorErrorNotGrantedPermissions
                                                   userInfo:@{NSLocalizedDescriptionKey: [self localizedStringForKey:@"kErrorAccessNotGranted"
                                                                                                         withDefault:@"Need Read Access permissions to your Facebook account."]}];
                if (block)
                    block(anError);
            }
        }];
    }
    
    else
    {
        if (block)
            block(nil);
    }

}

- (void)selectTwitterAccountWithSelectorInView:(UIView *)aView block:(void (^)(ACAccount *selectedTwitterAccount, NSError *error))block
{
    if ([[self allTwitterAccounts] count] > 0)
    {
        __weak GMSocialMediator *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIActionSheet showInView:aView
                            withTitle:[self localizedStringForKey:@"kTextSelectTwitterAccount" withDefault:@"Select a Twitter account"]
                    cancelButtonTitle:[self localizedStringForKey:@"kTextCancel" withDefault:@"Cancel"]
               destructiveButtonTitle:nil
                    otherButtonTitles:[[self allTwitterAccounts] valueForKey:@"username"]
                             tapBlock:^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                                 if (buttonIndex != [actionSheet cancelButtonIndex])
                                 {
                                     ACAccount *selectedAccount = [[self allTwitterAccounts] objectAtIndex:buttonIndex];
                                     weakSelf.twitterAccount = selectedAccount;
                                     if (block)
                                         block(selectedAccount, nil);
                                 }
                                 else
                                 {
                                     NSError *anError = [NSError errorWithDomain:NSStringFromClass([self class])
                                                                            code:GMSocialMediatorErrorNotSelectedTwitterAccount
                                                                        userInfo:@{NSLocalizedDescriptionKey: [self localizedStringForKey:@"kErrorTwitterAccountNotSelected" withDefault:@"Need to choose one Twitter account."]}];
                                     if (block)
                                         block(nil, anError);
                                 }
                             }];
        });
    }
    else
    {
        NSError *anError = [NSError errorWithDomain:NSStringFromClass([self class])
                                               code:GMSocialMediatorErrorNoLocalAccount
                                           userInfo:@{NSLocalizedDescriptionKey: [self localizedStringForKey:@"kErrorNoTwitterAccountsFound"
                                                                                                 withDefault:@"Cannot find a Twitter account."]}];
        if (block)
            block(nil, anError);
    }
}


- (void)requestTwitterUserDataForAccount:(ACAccount *)twitterAccount block:(void (^)(GMTwitterUser *twitterUser, NSError *error))block
{
    // Create the request
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
    
    NSDictionary *params = @{@"include_entities":@"false",
                             @"skip_status":@"true"};
    
    SLRequest *request =[SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
    ACAccountType *account_type_twitter = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    twitterAccount.accountType = account_type_twitter;
    [request setAccount:twitterAccount];
    
    __weak GMSocialMediator *weakSelf = self;
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (!error)
        {
            NSDictionary *parsedResponse = [weakSelf p_parseJSONWithData:responseData];
            if (parsedResponse)
            {
                GMTwitterUser *aTwUser = [[GMTwitterUser alloc] initTwitterUserWithAttributes:parsedResponse];
                if (block)
                    block(aTwUser, nil);
            }
            else
            {
                NSError *anError = [NSError errorWithDomain:NSStringFromClass([self class])
                                                       code:GMSocialMediatorErrorCouldNotParseData
                                                   userInfo:@{NSLocalizedDescriptionKey: [self localizedStringForKey:@"kCouldNotParseResponse"
                                                                                                         withDefault:@"Cannot fetch user info."]}];
                if (block)
                    block(nil, anError);
            }
        }
        else
        {
            if (block)
                block(nil, error);
        }
    }];
}

- (void)requestTwitterAllUserFriendsForAccount:(ACAccount *)twitterAccount
                                block:(void (^)(NSArray *friends, NSError *error))block
{
    __block NSNumber *nCursor = @-1;
    __block NSMutableArray *allFriends = [NSMutableArray array];
    
    __weak GMSocialMediator *weakSelf = self;
    do {
        [weakSelf p_fetchUserFriendsForAccount:twitterAccount nextCursor:nCursor
                                         block:^(NSArray *friends, NSNumber *cursor, NSError *error) {
                                             if (!error)
                                             {
                                                 nCursor = cursor;
                                                 [allFriends addObjectsFromArray:friends];
                                                 
                                                 if ([nCursor integerValue] == 0)
                                                 {
                                                     if (block)
                                                         block(allFriends, nil);
                                                 }
                                             }
                                             else
                                             {
                                                 nCursor = @0;
                                                 if (block)
                                                     block([NSArray array], error);
                                             }
                                         }];
    }
    while (![nCursor integerValue] != 0);
}

- (void)requestTwitterAllFollowersForAccount:(ACAccount *)twitterAccount block:(void (^)(NSArray *followers, NSError *error))block
{
    __block NSNumber *nCursor = @-1;
    __block NSMutableArray *allFollowers = [NSMutableArray array];
    
    __weak GMSocialMediator *weakSelf = self;
    do {
        [weakSelf p_fetchFollowersForAccount:twitterAccount nextCursor:nCursor
                                       block:^(NSArray *followers, NSNumber *cursor, NSError *error) {
                                           if (!error)
                                           {
                                               nCursor = cursor;
                                               [allFollowers addObjectsFromArray:followers];
                                               
                                               if ([nCursor integerValue] == 0)
                                               {
                                                   if (block)
                                                       block(allFollowers, nil);
                                               }
                                           }
                                           else
                                           {
                                               nCursor = @0;
                                               if (block)
                                                   block([NSArray array], error);
                                           }
                                       }];
    }
    while (![nCursor integerValue] != 0);
}

#pragma mark - Private methods
// Private method to fetch friends with a cursor
- (void)p_fetchUserFriendsForAccount:(ACAccount *)twitterAccount nextCursor:(NSNumber *)nextCursor
                               block:(void (^)(NSArray *friends, NSNumber *cursor, NSError *error))block
{
    // Create the request
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/ids.json"];
    
    NSMutableDictionary *params = [@{@"screen_name" : twitterAccount.username,
                                     } mutableCopy];
    
    // Trick to solve bug in iOS 6: if we sent the cursor the request fails unexpectdly
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
        [params setObject:nextCursor forKey:@"cursor"];
    
    SLRequest *request =[SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
    ACAccountType *account_type_twitter = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    twitterAccount.accountType = account_type_twitter;
    [request setAccount:twitterAccount];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (!error)
        {
            NSDictionary *userData = [self p_parseJSONWithData:responseData];
            
            NSArray *responseFriends = [NSArray array];
            if ([userData valueForKeyPath:@"ids"])
                responseFriends = [userData valueForKeyPath:@"ids"];
            
            NSNumber *responseCursor;
            if ([userData valueForKeyPath:@"next_cursor"])
                responseCursor = [userData valueForKeyPath:@"next_cursor"];
            
            if (block)
                block(responseFriends, responseCursor, nil);
        }
        else
        {
            NSLog(@"Error %ld. Trying to call account/friends/ids.json", (long)[urlResponse statusCode]);
            NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                                 code:[urlResponse statusCode]
                                             userInfo:[NSDictionary dictionaryWithObject:@"Called account/friends/ids.json"
                                                                                  forKey:NSLocalizedDescriptionKey]];
            if (block)
                block([NSArray array], nil, error);
            
        }
    }];
}

// Private method to fetch followers with a cursor
- (void)p_fetchFollowersForAccount:(ACAccount *)twitterAccount nextCursor:(NSNumber *)nextCursor
                             block:(void (^)(NSArray *followers, NSNumber *cursor, NSError *error))block
{
    // Create the request
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/followers/ids.json"];
    
    NSMutableDictionary *params = [@{@"screen_name" : twitterAccount.username,
                                     } mutableCopy];
    
    // Trick to solve bug in iOS 6: if we sent the cursor the request fails unexpectdly
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
        [params setObject:nextCursor forKey:@"cursor"];
    
    SLRequest *request =[SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
    ACAccountType *account_type_twitter = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    twitterAccount.accountType = account_type_twitter;
    [request setAccount:twitterAccount];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (!error)
        {
            NSDictionary *userData = [self p_parseJSONWithData:responseData];
            
            NSArray *responseFriends = [NSArray array];
            if ([userData valueForKeyPath:@"ids"])
                responseFriends = [userData valueForKeyPath:@"ids"];
            
            NSNumber *responseCursor;
            if ([userData valueForKeyPath:@"next_cursor"])
                responseCursor = [userData valueForKeyPath:@"next_cursor"];
            
            if (block)
                block(responseFriends, responseCursor, nil);
        }
        else
        {
            NSError *error = [NSError errorWithDomain:NSStringFromClass([self class])
                                                 code:[urlResponse statusCode]
                                             userInfo:[NSDictionary dictionaryWithObject:@"Called https://api.twitter.com/1.1/followers/ids.json"
                                                                                  forKey:NSLocalizedDescriptionKey]];
            if (block)
                block([NSArray array], nil, error);
        }
    }];
}


// Private method to parse the response data from SLRequests
- (NSDictionary *)p_parseJSONWithData:(NSData *)responseData
{
    NSError *jsonError;
    NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:NSJSONReadingAllowFragments
                                                               error:&jsonError];
    return userData;
}

@end

