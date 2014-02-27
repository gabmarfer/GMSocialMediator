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

static NSString * const GMSocialMediatorFacebookAppId = @"223394077853020";

@interface GMSocialMediator () <UIActionSheetDelegate>
@property (nonatomic, strong, readwrite) GMFacebookUser *facebookUser;
@property (nonatomic, strong, readwrite) GMTwitterUser *twitterUser;
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccount *facebookAccount;
@property (nonatomic, strong) NSArray *allTwitterAccounts;
@property (nonatomic, strong) ACAccount *twitterAccount;
@property (nonatomic, getter = hasFacebookReadAccess) __block BOOL facebookReadAccess;
@property (nonatomic, getter = hasTwitterReadAccess) __block BOOL twitterReadAccess;
@end

@implementation GMSocialMediator

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

#pragma mark - Facebook methods
- (BOOL)hasFacebookReadAccess
{
    return _facebookReadAccess;
}

- (ACAccount *)facebookAccount
{
    return _facebookAccount;
}

#pragma mark --- Request methods
/**
 * Request Read Access Permissions to Facebook
 *
 * @discussion Only make the request if we don't have requested the same 
 * permissions previously
 * @param block A Block with an error or nil
 * @return
 */
- (void)requestReadAccessToFacebookWithBlock:(void (^)(NSError *error))block
{
    if (![self hasFacebookReadAccess])
    {
        // Specify the permissions required
        NSArray *permissions = @[@"read_stream",
                                 @"email",
                                 ];
        
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
                
                NSError *anError = [NSError errorWithDomain:@"GMSocialMediator"
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

/**
 * Fetch user info from Facebook
 *
 * @discussion This method only makes the request if we have requested the Read permissions previously
 * @param block A block with a Dictionary containing the retrieved userInfo and an error or nil
 * @return
 */
- (void)fetchFacebookUserInfoWithBlock:(void (^)(GMFacebookUser *facebookUser, NSError *error))block
{
    if ([self hasFacebookReadAccess])
    {
        // Create the request
        NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me"];
        
        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook requestMethod:SLRequestMethodGET URL:url parameters:nil];
        ACAccountType *account_type_facebook = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        [self.facebookAccount setAccountType:account_type_facebook];
        [request setAccount:self.facebookAccount];
        
        __weak GMSocialMediator *weakSelf = self;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error)
            {
                NSDictionary *parsedResponse = [weakSelf p_parseJSONWithData:responseData];
                if (parsedResponse)
                {
                    self.facebookUser = [[GMFacebookUser alloc] initFacebookUserWithAttributes:parsedResponse];
                    if (block)
                    {
                        block([weakSelf facebookUser], nil);
                    }
                    else
                    {
                        NSError *anError = [NSError errorWithDomain:@"GMSocialMediator"
                                                               code:GMSocialMediatorErrorCouldNotParseData
                                                           userInfo:@{NSLocalizedDescriptionKey: @"Could not parse response data"}];
                        if (block)
                            block(nil, anError);
                    }
                }
            }
            else
            {
                NSLog(@"Error %ld", (long)[urlResponse statusCode]);
                NSError *anError = [NSError errorWithDomain:@"GMSocialMediator"
                                                       code:GMSocialMediatorErrorUnkown
                                                   userInfo:@{NSLocalizedDescriptionKey: @"Error requesting user info"}];
                if (block)
                    block(nil, anError);
            }
        }];
    }
    else
    {
        NSError *anError = [NSError errorWithDomain:@"GMSocialMediator"
                                               code:GMSocialMediatorErrorNotGrantedPermissions
                                           userInfo:@{NSLocalizedDescriptionKey: @"Hasn't got Facebook Read Access permissions"}];
        if (block)
            block(nil, anError);
    }
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
/**
 * Request Read Access Permissions to Twitter accounts
 *
 * @discussion Only make the request if we don't have requested the same
 * permissions previously
 * @param block A Block with an error or nil
 * @return
 */
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
                NSError *anError = [NSError errorWithDomain:@"GMSocialMediator"
                                                       code:GMSocialMediatorErrorNotGrantedPermissions
                                                   userInfo:@{NSLocalizedDescriptionKey: @"Hasn't got Facebook Read Access permissions"}];
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

/**
 * Present an ActionSheet to the user to select a Twitter Account
 *
 * @param aView The UIView in which to present the ActionSheet
 * @param block A Block with the selected Twitter account or an error
 * @return
 */
- (void)selectTwitterAccountWithSelectorInView:(UIView *)aView block:(void (^)(ACAccount *selectedTwitterAccount, NSError *error))block
{
    if ([[self allTwitterAccounts] count] > 0)
    {
        __weak GMSocialMediator *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIActionSheet showInView:aView
                            withTitle:@"Select a Twitter account"
                    cancelButtonTitle:@"Cancel"
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
                                     NSError *anError = [NSError errorWithDomain:@"GMSocialMediator"
                                                                            code:GMSocialMediatorErrorNotSelectedTwitterAccount
                                                                        userInfo:@{NSLocalizedDescriptionKey: @"Not selected twitter account."}];
                                     if (block)
                                         block(nil, anError);
                                 }
                             }];
        });
    }
    else
    {
        NSError *anError = [NSError errorWithDomain:@"GMSocialMediator"
                                               code:GMSocialMediatorErrorNoLocalAccount
                                           userInfo:@{NSLocalizedDescriptionKey: @"No local accounts."}];
        if (block)
            block(nil, anError);
    }
}

/**
 * Fetch Twitter user info
 *
 * @param twitterAccount The ACAccount from which to read user info
 * @param block A block with the GMTwitterUser or an error
 * @return
 */
- (void)fetchUserDataForAccount:(ACAccount *)twitterAccount block:(void (^)(GMTwitterUser *twitterUser, NSError *error))block
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
                weakSelf.twitterUser = [[GMTwitterUser alloc] initTwitterUserWithAttributes:parsedResponse];
                if (block)
                    block([weakSelf twitterUser], nil);
            }
            else
            {
                NSError *anError = [NSError errorWithDomain:@"GMSocialMediator"
                                                       code:GMSocialMediatorErrorCouldNotParseData
                                                   userInfo:@{NSLocalizedDescriptionKey: @"Could not parse response data"}];
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


/**
 * Fetch friends list (people that i am following)
 *
 * @param twitterAccount The Twitter account from which to fetch the friends
 * @param block A Block with the list of friends and an error or nil
 * @return
 */
- (void)fetchAllUserFriendsForAccount:(ACAccount *)twitterAccount
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

/**
 * Fetch followers list (people that are following me)
 *
 * @param twitterAccount The Twitter account to fetch the friends
 * @param block A Block with the list of followers and an error or nil
 * @return
 */
- (void)fetchAllFollowersForAccount:(ACAccount *)twitterAccount block:(void (^)(NSArray *followers, NSError *error))block
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
            NSLog(@"Error %d. Trying to call account/friends/ids.json", [urlResponse statusCode]);
            NSError *error = [NSError errorWithDomain:@"UserStore error"
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
            
            NSError *error = [NSError errorWithDomain:@"UserStore error"
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

