//
//  TFacebookManager.m
//  treveller
//
//  Created by Oleg Lobachev on 05.10.10.
//  Copyright 2010 aironik. All rights reserved.
//

#import "MSocialManager.h"
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
@synthesize vkData = vkData_;

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

- (void)logoutFb {
    [[self facebookEngine] logout:self];
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

- (void)getFbData {
    NSString *fbId = [self fbId];
    if (fbId != nil && [fbId length] > 0) {
        if ([self.delegate respondsToSelector:@selector(fbGotUserData)]) {
            [self.delegate fbGotUserData];
        }
        return;
    }
    [self.facebook requestWithGraphPath:@"me" andDelegate:self];
}

- (void)postFb:(NSString*)imagePath title:(NSString*)title {
	Facebook *fb = [self facebookEngine];
    
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:kFacebookAppID forKey:@"client_id"];
	[params setObject:imagePath forKey:@"picture"];
	[params setObject:@"Martini App" forKey:@"name"];
	[params setObject:title forKey:@"caption"];
	//[params setObject:@"" forKey:@"description"];
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
        NSString *name = [result valueForKey:@"name"];
        [self setFbUsername:name];
        name = [result valueForKey:@"id"];
        [self setFbId:name];
        NSString *photo = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", name];
        [self setFbPhoto:photo];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        if ([self.delegate respondsToSelector:@selector(fbGotUserData)]) {
            [self.delegate fbGotUserData];
        }
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

- (void)getVkData {
    NSString *name = [self vkUsername];
    if (name != nil && [name length] > 0) {
        if ([self.delegate respondsToSelector:@selector(vkGotUserData)]) {
            [self.delegate vkGotUserData];
        }
        return;
    }
    name = [self vkId];
    if (name == nil) {
        [self loginVk];
    }
    NSString *userUrl = [NSString stringWithFormat:@"https://api.vkontakte.ru/method/getProfiles?uid=%@&access_token=%@&fields=uid,first_name,last_name,photo_medium", name, [[NSUserDefaults standardUserDefaults] valueForKey:kVKAccessToken]];
    NSString *vkData = [NSString stringWithContentsOfURL:[NSURL URLWithString:userUrl] encoding:NSUTF8StringEncoding error:nil];
    NSArray *array = [[vkData JSONValue] valueForKey:@"response"];
    for (NSDictionary *dict in array) {
        NSNumber *uid = [dict valueForKey:@"uid"];
        if ([uid intValue] == [name intValue]) {
            NSString *name = [dict valueForKey:@"first_name"];
            NSString *lastName = [dict valueForKey:@"last_name"];
            NSString *photo = [dict valueForKey:@"photo_medium"];
            [self setVkUsername:[NSString stringWithFormat:@"%@ %@", name, lastName]];
            [self setVkPhoto:photo];
            break;
        }
    }
    if ([self.delegate respondsToSelector:@selector(vkGotUserData)]) {
        [self.delegate vkGotUserData];
    }
}

- (void)logoutVk {
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kVKAccessTokenDate];
}

- (void)loginVk {
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:kVKAccessTokenDate];
    int interval = [date timeIntervalSinceNow];
    if (date != nil &&  interval > 0) {
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
        NSString *responce = [[[webView request] URL] absoluteString];
        NSString *accessToken = [self stringBetweenString:@"access_token=" 
                                                andString:@"&" 
                                              innerString:responce];
        
        // Получаем id пользователя, пригодится нам позднее
        NSArray *userAr = [responce componentsSeparatedByString:@"&user_id="];
        NSString *user_id = [userAr lastObject];
        
        int expires = [[self stringBetweenString:@"expires_in=" 
                                      andString:@"&" 
                                    innerString:responce] intValue];
       
        if(user_id){
            [[NSUserDefaults standardUserDefaults] setObject:user_id forKey:kVKAccessUserId];
            [self setVkId:user_id];
        }
        
        if(accessToken){
            [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:kVKAccessToken];
            NSDate *expDate = [[NSDate date] dateByAddingTimeInterval:expires];
            [[NSUserDefaults standardUserDefaults] setObject:expDate forKey:kVKAccessTokenDate];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        if ([self.delegate respondsToSelector:@selector(vkDidLogin)]) {
            [self.delegate vkDidLogin];
        }
        [self.vkWebView removeFromSuperview];
    } else if ([self.vkWebView.request.URL.absoluteString rangeOfString:@"error"].location != NSNotFound) {
        NSLog(@"Error: %@", self.vkWebView.request.URL.absoluteString);
        [self.vkWebView removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(vkDidNotLogin)]) {
            [self.delegate vkDidNotLogin];
        }
    }    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"Failed load UIWebView error: %@", error);
    
}

- (void)showVkCaptcha {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Введите код:\n\n\n\n\n"
                                                          message:@"\n" delegate:self cancelButtonTitle:@"Отменить" otherButtonTitles:@"OK", nil];
    
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(77.0, 45.0, 130.0, 50.0)] autorelease];
    
    imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.vkData valueForKey:@"captcha_img"]]]];
    [alertView addSubview:imageView];
    
    UITextField *textField = [[[UITextField alloc] initWithFrame:CGRectMake(12.0, 110.0, 260.0, 25.0)] autorelease];
    [textField setBackgroundColor:[UIColor whiteColor]];
    
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.tag = 33;
    
    [alertView addSubview:textField];
    [alertView show];
    [alertView release];    
}

- (void)postVk:(NSString*)message withCaptcha:(BOOL)captcha {
    NSString *user_id = [[NSUserDefaults standardUserDefaults] objectForKey:kVKAccessUserId];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kVKAccessToken];
    
    // Создаем запрос на размещение текста на стене
    NSMutableString *sendTextMessage = [NSMutableString stringWithFormat:@"https://api.vk.com/method/wall.post?owner_id=%@&access_token=%@&message=%@", user_id, accessToken, [message encodedURLString]];
    if (captcha) {
        NSString *captchaSid = [self.vkData valueForKey:@"captcha_sid"];
        NSString *captchaKey = [self.vkData valueForKey:@"captcha_key"];
        
        [sendTextMessage appendFormat:@"&captcha_sid=%@&captcha_key=%@", captchaSid,
         [captchaKey encodedURLString]];
    }
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
        NSDictionary *result = [[response JSONValue] valueForKey:@"error"];
        NSString *errorMsg = [result objectForKey:@"error_msg"];
        if(!errorMsg) {
            if ([self.delegate respondsToSelector:@selector(vkDidPost)]) {
                [self.delegate vkDidPost];
            }
        } else {
            NSString *captcha = [result objectForKey:@"captcha_img"];
            if ([captcha length] > 0) {
             //   "captcha_sid":"197188261851","captcha_img":"http:\/\/api.vk.com\/captcha.php?sid=197188261851"
                self.vkData = [[result mutableCopy] autorelease];
                [self showVkCaptcha];
                return;
            }
            if ([self.delegate respondsToSelector:@selector(vkDidNotPost:)]) {
                [self.delegate vkDidNotPost:errorMsg];
            }            
        }
    }
}

- (void)alertView:(UIAlertView*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == actionSheet.cancelButtonIndex){
        if ([self.delegate respondsToSelector:@selector(vkDidNotPost:)]) {
            [self.delegate vkDidNotPost:nil];
        }            
        return;
    }
    UITextField *textField = (UITextField *)[actionSheet viewWithTag:33];
    [self.vkData setValue:textField.text forKey:@"captcha_key"];
    
    [self postVk:[self.vkData valueForKey:@"message"] withCaptcha:YES];
}

#pragma mark - Twitter

- (void)loginTw {    
    if (oAuth_ == nil) {
        oAuth_ = [[OAuth alloc] initWithConsumerKey:OAUTH_CONSUMER_KEY 
                                  andConsumerSecret:OAUTH_CONSUMER_SECRET];
       
    }
    if ([OAuth isTwitterAuthorized]) {
        if ([self.delegate respondsToSelector:@selector(twDidLogin)]) {
            [self.delegate twDidLogin];
        }
        return;
    }
    
    TwitterDialog *td = [[[TwitterDialog alloc] init] autorelease];
    
    td.twitterOAuth = self.oAuth;
    td.delegate = self;
    td.logindelegate = self;
    
    [td show];
}

- (void)logoutTw {
    [oAuth_ forget];   
    [OAuth clearCrendentialsFromUserDefaults];
}

- (void)twitterDidLogin {
   // [self setTwitterAccessToken:self.oAuth.oauth_token usrename:self.oAuth.screen_name];
    [self.oAuth saveOAuthContext];
    [self.oAuth saveOAuthTwitterContextToUserDefaults];
    [self setTwitterPhoto:[NSString stringWithFormat:@"http://api.twitter.com/1/users/profile_image?screen_name=%@&size=bigger", self.oAuth.screen_name]];
    if ([self.delegate respondsToSelector:@selector(twDidLogin)]) {
        [self.delegate twDidLogin];
    }
}

- (void)twitterDidNotLogin:(BOOL)cancelled {
    if ([self.delegate respondsToSelector:@selector(twDidNotLogin)]) {
        [self.delegate twDidNotLogin];
    }
}

- (void)postTw:(NSString*)imagePath title:(NSString*)title {
    if ([DETweetComposeViewController canSendTweet]) {
        DETweetComposeViewController *tcvc = [[[DETweetComposeViewController alloc] init] autorelease];
        tcvc.alwaysUseDETwitterCredentials = YES;
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
- (void)setFbUsername:(NSString*)username {
	[[NSUserDefaults standardUserDefaults] setValue:username forKey:kFacebookUsernameSettings];
}

- (NSString*)fbUsername {
	return [[NSUserDefaults standardUserDefaults] valueForKey:kFacebookUsernameSettings];
}

- (void)setFbPhoto:(NSString*)username {
	[[NSUserDefaults standardUserDefaults] setValue:username forKey:kFacebookPhotoSettings];
}

- (NSString*)fbPhoto {
	return [[NSUserDefaults standardUserDefaults] valueForKey:kFacebookPhotoSettings];
}

- (NSString*)fbId {
	return [[NSUserDefaults standardUserDefaults] valueForKey:kFacebookIdSettings];
}

- (void)setFbId:(NSString*)username {
	[[NSUserDefaults standardUserDefaults] setValue:username forKey:kFacebookIdSettings];
}

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
	return [[NSUserDefaults standardUserDefaults] valueForKey:@"screen_name"];    
}

- (NSString*)twitterPhoto {
	return [[NSUserDefaults standardUserDefaults] valueForKey:kTwPhotoSettings];
}

- (void)setTwitterPhoto:(NSString*)username {
	[[NSUserDefaults standardUserDefaults] setValue:username forKey:kTwPhotoSettings];
}//TWITTER

//VK
- (NSString*)vkUsername {
	return [[NSUserDefaults standardUserDefaults] valueForKey:kVKUsernameSettings];
}

- (void)setVkUsername:(NSString*)username {
	[[NSUserDefaults standardUserDefaults] setValue:username forKey:kVKUsernameSettings];
}

- (NSString*)vkId {
	return [[NSUserDefaults standardUserDefaults] valueForKey:kVKIdSettings];
}

- (void)setVkId:(NSString*)username {
	[[NSUserDefaults standardUserDefaults] setValue:username forKey:kVKIdSettings];
}//VK

- (NSString*)vkPhoto {
	return [[NSUserDefaults standardUserDefaults] valueForKey:kVKPhotoSettings];
}

- (void)setVkPhoto:(NSString*)username {
	[[NSUserDefaults standardUserDefaults] setValue:username forKey:kVKPhotoSettings];
}//VK

@end
