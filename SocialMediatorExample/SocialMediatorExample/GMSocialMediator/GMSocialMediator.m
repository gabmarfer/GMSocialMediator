//
//  GMSocialMediator.m
//  iParticipa
//
//  Created by Gabi Martelo on 31/01/14.
//  Copyright (c) 2014 Startcapps. All rights reserved.
//

#import "GMSocialMediator.h"
@import Accounts;
@import Social;

static NSString * const GMSocialMediatorFacebookAppId = @"589020147853035";

// Facebook parameters for response data
NSString * const GMSocialMediatorFacebookResponseUserId = @"id";
NSString * const GMSocialMediatorFacebookResponseUsername = @"name";
NSString * const GMSocialMediatorFacebookResponseFirstName = @"first_name";
NSString * const GMSocialMediatorFacebookResponseLastName = @"last_name";
NSString * const GMSocialMediatorFacebookResponseEmail = @"email";


@implementation GMFacebookUser
- (id)initFacebookUserWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    if (self) {
        _userId = [[attributes valueForKeyPath:GMSocialMediatorFacebookResponseUserId] copy];
        _name = [[attributes valueForKeyPath:GMSocialMediatorFacebookResponseUsername] copy];
        _firstName = [[attributes valueForKeyPath:GMSocialMediatorFacebookResponseFirstName] copy];
        _lastName = [[attributes valueForKeyPath:GMSocialMediatorFacebookResponseLastName] copy];
        _email = [[attributes valueForKeyPath:GMSocialMediatorFacebookResponseEmail] copy];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@",@{GMSocialMediatorFacebookResponseUserId: self.userId,
                                              GMSocialMediatorFacebookResponseUsername: self.name,
                                              GMSocialMediatorFacebookResponseFirstName: self.firstName,
                                              GMSocialMediatorFacebookResponseLastName: self.lastName,
                                              GMSocialMediatorFacebookResponseEmail: self.email,
                                              }];
}
@end


@interface GMSocialMediator ()
@property (nonatomic, strong, readwrite) GMFacebookUser *facebookUser;
@property (nonatomic, strong) ACAccountStore *facebookAccountStore;
@property (nonatomic, strong) ACAccount *facebookAccount;
@property (nonatomic, getter = hasFacebookReadAccess) __block BOOL facebookReadAccess;
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

#pragma mark - Public facebook methods
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
        
        // Create an Account Store
        self.facebookAccountStore = [[ACAccountStore alloc] init];
        
        // Specify the Account Type
        ACAccountType *accountType = [self.facebookAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        if (!accountType.accessGranted)
        {
            self.facebookReadAccess = NO;
        }
        
        // Perform the permission request
        [self.facebookAccountStore requestAccessToAccountsWithType:accountType options:facebookOptions completion:^(BOOL granted, NSError *error) {
            if (granted)
            {
                self.facebookReadAccess = YES;
                NSLog(@"Read permissions granted.");
                NSArray *array = [self.facebookAccountStore accountsWithAccountType:accountType];
                self.facebookAccount = [array lastObject];
                
                if (block)
                    block(nil);
            }
            
            if (error)
            {
                NSUInteger statusCode = 0;
                
                if (error.code == 6)
                {
                    NSLog(@"Error: There is no Facebook account setup.");
                    statusCode = GMSocialMediatorFacebookErrorNoLocalAccount;
                }
                else
                {
                    NSLog(@"Error: %ld(%@)", (long)[error code], [error localizedDescription]);
                    statusCode = GMSocialMediatorFacebookErrorUnkown;
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
        ACAccountType *account_type_facebook = [self.facebookAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        [self.facebookAccount setAccountType:account_type_facebook];
        [request setAccount:self.facebookAccount];
        
        __weak GMSocialMediator *weakSelf = self;
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
            if (!error)
            {
                NSDictionary *parsedResponse = [weakSelf p_parseJSONWithData:responseData];
                if (parsedResponse)
                {
                    GMFacebookUser *aFbUser = [[GMFacebookUser alloc] initFacebookUserWithAttributes:parsedResponse];
                    if (block)
                    {
                        block(aFbUser, nil);
                    }
                    else
                    {
                        NSError *anError = [NSError errorWithDomain:@"GMSocialMediator"
                                                               code:GMSocialMediatorFacebookErrorCouldNotParseData
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
                                                       code:GMSocialMediatorFacebookErrorUnkown
                                                   userInfo:@{NSLocalizedDescriptionKey: @"Error requesting user info"}];
                if (block)
                    block(nil, anError);
            }
        }];
    }
    else
    {
        NSError *anError = [NSError errorWithDomain:@"GMSocialMediator"
                                               code:GMSocialMediatorFacebookErrorNotGrantedPermissions
                                           userInfo:@{NSLocalizedDescriptionKey: @"Hasn't got Facebook Read Access permissions"}];
        if (block)
            block(nil, anError);
    }
}

#pragma mark - Private method to parse the response data from SLRequests
- (NSDictionary *)p_parseJSONWithData:(NSData *)responseData
{
    NSError *jsonError;
    NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:NSJSONReadingAllowFragments
                                                               error:&jsonError];
    return userData;
}

@end

