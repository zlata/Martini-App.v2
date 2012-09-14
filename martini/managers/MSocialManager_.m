//
//  TFacebookManager.m
//  treveller
//
//  Created by Oleg Lobachev on 05.10.10.
//  Copyright 2010 aironik. All rights reserved.
//

#import "MSocialManager.h"
#import "MUtils.h"
#import "MModel.h"
#import "NSString+URLEncoding.h"
#import "JSON.h"
#import "DETweetComposeViewController.h"

@interface MSocialManager()

- (Facebook *)facebookEngine;
- (NSArray *)permissions;

@end

#pragma mark -

@implementation MSocialManager

@synthesize facebook = facebook_;
@synthesize delegate = delegate_;
@synthesize oAuth = oAuth_;
@synthesize vkWebView = vkWebView_;

static MSocialManager *sharedInstance = nil;

+ (MSocialManager *)sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedInstance] retain];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (oneway void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

#pragma mark -

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (void)dealloc {
    self.facebook = nil;
    self.delegate = nil;
    self.oAuth = nil;
    self.vkWebView = nil;
    
    [super dealloc];
}

- (Facebook *)facebookEngine {
    if (!self.facebook) {
        self.facebook = [[[Facebook alloc] initWithAppId:kFacebookAppID] autorelease];
        if ([self facebookToken] != nil) {
            self.facebook.accessToken = [self facebookToken];
            self.facebook.expirationDate = [self facebookExpire];
        } 
    }
    return self.facebook;
}
             
- (void)fbDidLogin {
    [self setFacebookToken:self.facebook.accessToken];
    [self setFacebookExpire:self.facebook.expirationDate];

    if ([self.delegate respondsToSelector:@selector(fbDidLogin)]) {
        [self.delegate fbDidLogin];
    }
}

- (void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"fail to connect facebook");
    if ([self.delegate respondsToSelector:@selector(fbDidNotLogin)]) {
        [self.delegate fbDidNotLogin];
    }
}

- (void)fbDidLogout {
    NSLog(@"FB logout");
    if ([self.delegate respondsToSelector:@selector(fbDidLogout)]) {
        [self.delegate fbDidLogout];
    }
}

- (void)loginFb {    
    Facebook *fb = [self facebookEngine];
    if ([fb isSessionValid]) {
        [self fbDidLogin];
    } else {
        [fb setSessionDelegate:self];
        [fb authorize:[self permissions] delegate:self];
    }
}

- (void)logout {
    Facebook *fb = [self facebookEngine];
    [fb logout:self];
}

- (void)getUserData {
    [self.facebook requestWithGraphPath:@"me" andDelegate:self];
}

- (void)postFb:(NSString*)imagePath title:(NSString*)title {
	Facebook *fb = [self facebookEngine];
    
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:kFacebookAppID forKey:@"client_id"];
	[params setObject:imagePath forKey:@"picture"];
	[params setObject:title forKey:@"name"];
	[params setObject:title forKey:@"caption"];
	[params setObject:title forKey:@"description"];
    [fb setSessionDelegate:self];
	[fb dialog:@"feed" andParams:params andDelegate:self];
}

#pragma mark - FBRequestDelegate protocol implementation

- (void)requestLoading:(FBRequest*)request {
    // Called just before the request is sent to the server.
}

- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response {
    // Called when the server responds and begins to send back data.
}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
    // Called when an error prevents the request from completing successfully.
    NSLog(@"error request from facebook");

}

- (void)request:(FBRequest*)request didLoad:(id)result {
    if ([result isKindOfClass:[NSArray class]]) {
        result = [result objectAtIndex:0];
    }
    if ([result isKindOfClass:[NSDictionary class]]){
         //[[NSNotificationCenter defaultCenter] postNotificationName:nFacebookDataLoaded object:result];
    }
}

- (void)request:(FBRequest*)request didLoadRawResponse:(NSData*)data {
    // Called when a request returns a response.
    // The result object is the raw response from the server of type NSData
}

- (NSArray*)permissions {
    NSArray *result = [NSArray arrayWithObjects:
                       @"email", @"read_stream", @"user_birthday", 
                       @"user_about_me", @"publish_stream", @"offline_access",
                       nil];
    return result;
}

#pragma mark - VKontakte

- (NSString*)stringBetweenString:(NSString*)start 
                       andString:(NSString*)end 
                     innerString:(NSString*)str {
    NSScanner* scanner = [NSScanner scannerWithString:str];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if ([scanner scanString:start intoString:NULL]) {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result]) {
            return result;
        }
    }
    return nil;
}

- (void)loginVk {
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:kVKAccessTokenDate];
    if (date != nil && [date timeIntervalSinceNow] > 0) {
        if ([self.delegate respondsToSelector:@selector(vkDidLogin)]) {
            [self.delegate vkDidLogin];
        }
        return;
    }
    if (self.vkWebView == nil) {
        CGRect rect = ((UIViewController*)self.delegate).view.bounds;
        self.vkWebView = [[[UIWebView alloc] initWithFrame:rect] autorelease];
        self.vkWebView.delegate = self;
        self.vkWebView.scalesPageToFit = YES;
    }
    [((UIViewController*)self.delegate).view addSubview:self.vkWebView];

    NSString *authLink = [NSString stringWithFormat:@"http://api.vk.com/oauth/authorize?client_id=%@&scope=wall,photos&redirect_uri=http://api.vk.com/blank.html&display=touch&response_type=token", kVkontakteAppID];
    NSURL *url = [NSURL URLWithString:authLink];
    [self.vkWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (BOOL)webView:(UIWebView *)aWbView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSURL *URL = [request URL];
    // Пользователь нажал Отмена в веб-форме
    if ([[URL absoluteString] isEqualToString:@"http://api.vk.com/blank.html#error=access_denied&error_reason=user_denied&error_description=User%20denied%20your%20request"]) {
        [self.vkWebView removeFromSuperview];
        return NO;
    }
	NSLog(@"Request: %@", [URL absoluteString]); 
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // Если есть токен сохраняем его
    if ([self.vkWebView.request.URL.absoluteString rangeOfString:@"access_token"].location != NSNotFound) {
        NSString *accessToken = [self stringBetweenString:@"access_token=" 
                                                andString:@"&" 
                                              innerString:[[[webView request] URL] absoluteString]];
        
        // Получаем id пользователя, пригодится нам позднее
        NSArray *userAr = [[[[webView request] URL] absoluteString] componentsSeparatedByString:@"&user_id="];
        NSString *user_id = [userAr lastObject];
        NSLog(@"User id: %@", user_id);
        if(user_id){
            [[NSUserDefaults standardUserDefaults] setObject:user_id forKey:kVKAccessUserId];
        }
        
        if(accessToken){
            [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:kVKAccessToken];
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kVKAccessTokenDate];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        NSLog(@"vkWebView response: %@",[[[webView request] URL] absoluteString]);
        if ([self.delegate respondsToSelector:@selector(vkDidLogin)]) {
            [self.delegate vkDidLogin];
        }
        [self.vkWebView removeFromSuperview];
    } else if ([self.vkWebView.request.URL.absoluteString rangeOfString:@"error"].location != NSNotFound) {
        NSLog(@"Error: %@", self.vkWebView.request.URL.absoluteString);
        [self.vkWebView removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(vkDidNotLogin)]) {
            [self.delegate vkDidLogin];
        }
    }    
}

- (void)postVk:(NSString*)message {
    NSString *user_id = [[NSUserDefaults standardUserDefaults] objectForKey:kVKAccessUserId];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kVKAccessToken];
    
    // Создаем запрос на размещение текста на стене
    NSString *sendTextMessage = [NSString stringWithFormat:@"https://api.vk.com/method/wall.post?owner_id=%@&access_token=%@&message=%@", user_id, accessToken, [message encodedURLString]];
    NSLog(@"sendTextMessage: %@", sendTextMessage);
    
    // Если запрос более сложный мы можем работать дальше с полученным ответом
    //NSDictionary *result = [self sendRequest:sendTextMessage withCaptcha:NO];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:sendTextMessage] 
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
                                                       timeoutInterval:60.0]; 
    
    // Для простоты используется обычный запрос NSURLConnection, ответ сервера сохраняем в NSData
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *response = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
    // Если ответ получен успешно, можем его посмотреть и заодно с помощью JSONKit получить NSDictionary
    if(responseData){
        NSDictionary *result = [response JSONValue];
        NSString *errorMsg = [[result objectForKey:@"error"] objectForKey:@"error_msg"];
        if(!errorMsg) {
            if ([self.delegate respondsToSelector:@selector(vkDidPost)]) {
                [self.delegate vkDidPost];
            }
        }
    }
}

#pragma mark - Twitter

- (void)loginTw {    
    if (oAuth_ == nil) {
        oAuth_ = [[OAuth alloc] initWithConsumerKey:OAUTH_CONSUMER_KEY 
                                  andConsumerSecret:OAUTH_CONSUMER_SECRET];
    }
    TwitterDialog *td = [[[TwitterDialog alloc] init] autorelease];
    td.twitterOAuth = self.oAuth;
    td.delegate = self;
    td.logindelegate = self;
    
    [td show];
}

- (void)twitterDidLogin {
   // [self setTwitterAccessToken:self.oAuth.oauth_token usrename:self.oAuth.screen_name];
    [self.oAuth saveOAuthContext];
    [self.oAuth saveOAuthTwitterContextToUserDefaults];
    
    if ([self.delegate respondsToSelector:@selector(twDidLogin)]) {
        [self.delegate twDidLogin];
    }
}

- (void)twitterDidNotLogin:(BOOL)cancelled {
    
}

- (void)postTw:(NSString*)imagePath title:(NSString*)title {
    if ([DETweetComposeViewController canSendTweet]) {
        DETweetComposeViewController *tcvc = [[[DETweetComposeViewController alloc] init] autorelease];
        if (imagePath) {
            [tcvc addImage:[UIImage imageWithContentsOfFile:imagePath]];
        }
        [tcvc setText:title];
        ((UIViewController*)self.delegate).modalPresentationStyle = UIModalPresentationCurrentContext;
        [(UIViewController*)self.delegate presentModalViewController:tcvc animated:YES];
    } else {
        if (self.oAuth == nil) {
            self.oAuth = [[[OAuth alloc] initWithConsumerKey:OAUTH_CONSUMER_KEY 
                                           andConsumerSecret:OAUTH_CONSUMER_SECRET] autorelease];
        }
        TwitterDialog *td = [[[TwitterDialog alloc] init] autorelease];
        td.twitterOAuth = self.oAuth;
        td.delegate = self;
        td.logindelegate = self;
        [td show];
    }
}

#pragma mark - TwitterEngineDelegate

- (void)requestSucceeded:(NSString *)requestIdentifier {
	if ([self.delegate respondsToSelector:@selector(twDidPost)]) {
        [self.delegate twDidPost];
    }
}

- (void)requestFailed:(NSString *)requestIdentifier withError:(NSError *)error {
    
}

#pragma mark - Settings

//FACEBOOK
- (NSString*)facebookToken {
	return [[NSUserDefaults standardUserDefaults] valueForKey:kFacebookTokenSettings];
}

- (void)setFacebookToken:(NSString*)token {
	[[NSUserDefaults standardUserDefaults] setValue:token forKey:kFacebookTokenSettings];
}

- (NSDate*)facebookExpire {
	return [[NSUserDefaults standardUserDefaults] valueForKey:kFacebookExpireSettings];
}

- (void)setFacebookExpire:(NSDate*)expire {
	[[NSUserDefaults standardUserDefaults] setValue:expire forKey:kFacebookExpireSettings];
}//FACEBOOK

//TWITTER
- (void)setTwitterAccessToken:(NSString*)data
					 usrename:(NSString*)username {
	[[NSUserDefaults standardUserDefaults] setValue:data forKey:kTwitterAuthTocken];
	[[NSUserDefaults standardUserDefaults] setValue:username forKey:kTwittwrUsername];
    
}

- (NSString*)twitterAccessToken {
	return [[NSUserDefaults standardUserDefaults] valueForKey:kTwitterAuthTocken];
}

- (NSString*)twitterUserName {
	return [[NSUserDefaults standardUserDefaults] valueForKey:kTwittwrUsername];    
}

@end
