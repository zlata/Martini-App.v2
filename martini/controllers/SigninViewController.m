//
//  RootViewController.m
//  martini
//
//  Created by zlata samarskaya on 02.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SigninViewController.h"
#import "SignupViewController.h"
#import "ProfileViewController.h"

#import "MNetworkManager.h"
#import "MLocationManager.h"
#import "MSocialManager.h"

#import "MFontLabel.h"
#import "MUser.h"
#import "MUtils.h"
#import "NSString+SBJSON.h"

#define TEST_SOCIAL_SIGNIN 0

@implementation SigninViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"welcome";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = @"welcome";
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    
    [MSocialManager sharedInstance].delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [MSocialManager sharedInstance].delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(signupFinished:) 
                                                 name:nSignupFinished 
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(registerFinished:) 
                                                 name:nRegisterFinished 
                                               object:nil];
 //   tipLabel.text = @"Получите доступ\n к дополнительным возможностям!";
    [loginButton.titleLabel setFont:[UIFont fontWithName:@"MartiniPro-Bold" size:15]];
    UIImage *img = stretchImage([UIImage imageNamed:@"button.png"]);
    [loginButton setBackgroundImage:img forState:UIControlStateNormal];
}

- (void)viewDidUnload {
    [tipLabel release];
    tipLabel = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:nSignupFinished object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nRegisterFinished object:nil];

    [loginButton release];
    loginButton = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    [tipLabel release];
//    [vkAuthWebView release];

    [loginButton release];
    [super dealloc];
}


#pragma mark - Actions

- (IBAction)login:(id)sender {
    [self showAuthView];
}

- (IBAction)registration:(id)sender {
    SignupViewController *controller = [[[SignupViewController alloc] init] autorelease];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Facebook

- (IBAction)facebook:(id)sender {
    [[MSocialManager sharedInstance] loginFb];    
}

- (void)fbDidLogin {
    [[MSocialManager sharedInstance] getFbData];
}

- (void)fbGotUserData {
    NSString *str = [[MSocialManager sharedInstance] fbId];
    MUser *user = [MCurrentUser sharedInstance].user;
    user.name = [[MSocialManager sharedInstance] fbUsername];
    user.login = user.login;
    user.fbId = str;
  
    [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
    NSString *photo = [[MSocialManager sharedInstance] fbPhoto];
    [[MNetworkManager sharedInstance] registerWithNetwork:kFacebookNetwork 
                                                   userId:user.fbId 
                                                 userName:user.name
                                                userPhoto:photo];
}

#pragma mark - twitter

- (void)twDidLogin {
	
    MUser *user = [MCurrentUser sharedInstance].user;
    OAuth *oAuth = [MSocialManager sharedInstance].oAuth;
    user.name = oAuth.screen_name;
    user.login = oAuth.screen_name;
    user.twId = oAuth.user_id;
    
    [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
    [[MNetworkManager sharedInstance] registerWithNetwork:kTwitterNetwork 
                                                   userId:user.twId 
                                                 userName:user.name
                                                userPhoto:[[MSocialManager sharedInstance] twitterPhoto]];
}

- (void)twDidNotLogin:(BOOL)cancelled {
    if (cancelled) {
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:@"There was a unknown error authenticating with Twitter." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (IBAction)twitter:(id)sender {
    [[MSocialManager sharedInstance] loginTw];
}

#pragma mark - vkontakte

- (void)vkDidLogin {
    [[MSocialManager sharedInstance] getVkData];
}

- (void)vkGotUserData {
    MUser *user = [MCurrentUser sharedInstance].user;
    user.name = [[MSocialManager sharedInstance] vkUsername];
    user.login = [[MSocialManager sharedInstance] vkUsername];
    user.vkId = [[MSocialManager sharedInstance] vkId];

    [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
    [[MNetworkManager sharedInstance] registerWithNetwork:kVKontakteNetwork 
                                                   userId:user.vkId 
                                                 userName:user.name
                                               userPhoto:[[MSocialManager sharedInstance] vkPhoto]];
}

- (IBAction)vkontakte:(id)sender {
    [[MSocialManager sharedInstance] loginVk];    

//	NSURL *vkURL =[NSURL URLWithString:[NSString stringWithFormat:@"http://api.vkontakte.ru/oauth/authorize?client_id=%@&scope=wall,offline&redirect_uri=http://api.vkontakte.ru/blank.html&display=touch&response_type=token", @"2645358"]];
//	
////	[self.navigationController setNavigationBarHidden:NO];
//    if (vkAuthWebView == nil) {
//        vkAuthWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
//        vkAuthWebView.delegate = self;
//        vkAuthWebView.backgroundColor = [UIColor whiteColor];
//    }
//	[self.view addSubview:vkAuthWebView];
//	[vkAuthWebView loadRequest:[NSURLRequest requestWithURL:vkURL]];
}

//- (void)closeWebView {
////	[self.navigationController setNavigationBarHidden:YES];
//	[vkAuthWebView removeFromSuperview];
//}
//
//- (void)webViewDidStartLoad:(UIWebView *)webView {
//    [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
//}
//
//- (void)hideWebview {
//    [vkAuthWebView removeFromSuperview];
//    [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
//}
//
//- (void)webViewDidFinishLoad:(UIWebView*)webView {
//    [self performSelector:@selector(hideActivityIndicator) withObject:nil afterDelay:0];
//}
//
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
// navigationType:(UIWebViewNavigationType)navigationType {
// //   NSLog(@"Start load %@", request.URL.absoluteString);
//	if ([request.URL.path isEqualToString:@"/blank.html"]) {
//      //  [self performSelector:@selector(hideWebview) withObject:nil afterDelay:0];
//        NSArray *arr = [request.URL.absoluteString componentsSeparatedByString:@"#"];
//        NSDictionary *dict = [MUtils dictionaryFromQueryComponents:[arr objectAtIndex:([arr count] - 1)]];
//        NSString *idParam = [dict valueForKey:@"user_id"];
//        //  NSLog(@"id %@", idParam);
//        if (idParam) {
//            NSString *userUrl = [NSString stringWithFormat:@"https://api.vkontakte.ru/method/getProfiles?uid=%@&access_token=%@", idParam, [dict valueForKey:@"access_token"]];
//            NSString *vkData = [NSString stringWithContentsOfURL:[NSURL URLWithString:userUrl] encoding:NSUTF8StringEncoding error:nil];
//            NSArray *array = [[vkData JSONValue] valueForKey:@"response"];
//            for (NSDictionary *dict in array) {
//                NSNumber *uid = [dict valueForKey:@"uid"];
//                if ([uid intValue] == [idParam intValue]) {
//                    NSString *name = [dict valueForKey:@"first_name"];
//                    NSString *lastName = [dict valueForKey:@"last_name"];
//                    [MCurrentUser sharedInstance].user.name = [name stringByAppendingFormat:@" %@", lastName];
//                    [MCurrentUser sharedInstance].user.login = [MCurrentUser sharedInstance].user.name;
//                    break;
//                }
//            }
//            if(TEST_SOCIAL_SIGNIN)
//                [self showAlertWithTitle:@"Авторизация ВК" andMessage:@"регистрирую на сервере"];
//           [[MNetworkManager sharedInstance] registerWithNetwork:kVKontakteNetwork userId:idParam];
//        }
//        return NO;        
//    }
//    return YES;
//}

#pragma mark - SignIn

- (void)showAuthView {
    UIAlertView *authAlertView = [[[UIAlertView alloc] 
                                   initWithTitle:@"Авторизация" message:@"\n\n\n" 
                                   delegate:self 
                                   cancelButtonTitle:@"отмена" 
                                   otherButtonTitles:@"ок", nil] autorelease];
	UITextField *loginFld = [[UITextField alloc] initWithFrame:CGRectMake(40, 45, 200, 30)];
	loginFld.borderStyle = UITextBorderStyleLine;
	loginFld.backgroundColor = [UIColor whiteColor];
	loginFld.placeholder = @"логин";
    loginFld.autocorrectionType = UITextAutocorrectionTypeNo;
    loginFld.autocapitalizationType = UITextAutocapitalizationTypeNone;
    loginFld.tag = 111;
	loginFld.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	[authAlertView addSubview:loginFld];
	[loginFld release];
    
	UITextField *passwordFld = [[UITextField alloc] initWithFrame:CGRectMake(40, 85, 200, 30)];
	passwordFld.borderStyle = UITextBorderStyleLine;
	passwordFld.backgroundColor = [UIColor whiteColor];
    passwordFld.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordFld.autocapitalizationType = UITextAutocapitalizationTypeNone;
	passwordFld.placeholder = @"пароль";
    passwordFld.tag = 222;
    //	passwordFld.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"userPasswd"];
	passwordFld.secureTextEntry = YES;
	passwordFld.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	[authAlertView addSubview:passwordFld];
	[passwordFld release];
    
    [authAlertView show];
}

- (void)alertView:(UIAlertView *)alertView 
willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSString *login = ((UITextField*)[alertView viewWithTag:111]).text;
        NSString *pass = ((UITextField*)[alertView viewWithTag:222]).text;
        if ([login length] == 0) {
            [self showAlertWithTitle:@"" andMessage:@"введите логин"];
            return;
        }
        if ([pass length] == 0) {
            [self showAlertWithTitle:@"" andMessage:@"введите пароль"];
            return;
        }
        
        [self showActivityIndicator];
        [MCurrentUser sharedInstance].user.login = login;
        [MCurrentUser sharedInstance].password = pass;
        [[MNetworkManager sharedInstance] signIn:login password:pass];
    }
}
- (void)signin {
    [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];

    [[MNetworkManager sharedInstance] signIn:[MCurrentUser sharedInstance].user.login 
                                    password:[MCurrentUser sharedInstance].password];
}

- (void)signinComplete {
//    ProfileViewController *controller = [[[ProfileViewController alloc] init] autorelease];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark Notifications

- (void)signupFinished:(NSNotification*)notification {
    if ([self handleError:notification]) {
        return;
    }
    [self performSelector:@selector(signin) withObject:nil afterDelay:0.3];
}

- (void)signinFinished:(NSNotification*)notification {
    if(TEST_SOCIAL_SIGNIN)
        [self showAlertWithTitle:@"" andMessage:@"Авторизован"];
    if ([self handleError:notification]) {
        [MCurrentUser sharedInstance].user.login = nil;
        [MCurrentUser sharedInstance].password = nil;
        [[MCurrentUser sharedInstance] saveUserData];
       return;
    }
    NSString *n = [[MCurrentUser sharedInstance] network];
    if ([n length] == 0) {
        [[MCurrentUser sharedInstance] saveUserData];
    }
    [self signinComplete];
}

- (void)registerFinished:(NSNotification*)notification {
    [self performSelector:@selector(registerWithDelay:) withObject:notification afterDelay:1];
}

- (void)registerWithDelay:(NSNotification*)notification {
    NSDictionary *dictionary = [notification object];
    int network = [[dictionary valueForKey:@"network"] intValue];
    if(TEST_SOCIAL_SIGNIN)
        [self showAlertWithTitle:[NSString stringWithFormat:@"Зарегистирован через %@",
                                  [[MNetworkManager sharedInstance] stringForNetwork:network]]
                      andMessage:@"Авторизация"];
    NSString *userId = [dictionary valueForKey:@"userId"];

    [[MCurrentUser sharedInstance] saveNetworkData:network userId:userId];
    
    [[MNetworkManager sharedInstance] signInWithNetwork:network userId:userId];
}

#pragma mark - FBRequestDelegate

//- (IBAction)facebook:(id)sender {
//    if (facebook == nil) {
//        facebook = [[Facebook alloc] initWithAppId:@"175810705813249"];
//    }
//	
//	NSMutableDictionary *params = [NSMutableDictionary dictionary];
//	[params setObject:@"175810705813249" forKey:@"client_id"];
//	[facebook setSessionDelegate:self];
//	[facebook dialog:@"oauth" andParams:params andDelegate:self];
//}
//- (void) fbDidLogin {
//    [self performSelector:@selector(showActivityIndicator) withObject:nil afterDelay:0];
//    [[MSocialManager sharedInstance] setFacebookToken:facebook.accessToken];
//    [[MSocialManager sharedInstance] setFacebookExpire:facebook.expirationDate];
//	[facebook requestWithGraphPath:@"me" andDelegate:self];
//}
//
//- (void)requestLoading:(FBRequest*)request {
//    // Called just before the request is sent to the server.
//}
//
//- (void)request:(FBRequest*)request didReceiveResponse:(NSURLResponse*)response {
//    // Called when the server responds and begins to send back data.
//}
//
//- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
//    // Called when an error prevents the request from completing successfully.
//    NSLog(@"error request from facebook");    
//}
//
//- (void)request:(FBRequest*)request didLoad:(id)result {
//    if ([result isKindOfClass:[NSArray class]]) {
//        result = [result objectAtIndex:0];
//    }
//    if ([result isKindOfClass:[NSDictionary class]]){
//        MUser *user = [MCurrentUser sharedInstance].user;
//        user.name = [result valueForKey:@"name"];
//        user.login = user.login;
//        user.email = [result valueForKey:@"email"];
//        user.fbId = [result valueForKey:@"id"];
//        
//       [[MNetworkManager sharedInstance] registerWithNetwork:kFacebookNetwork userId:user.fbId];
//        if(TEST_SOCIAL_SIGNIN)
//            [self showAlertWithTitle:@"Авторизация Facebook" andMessage:@"регистрирую на сервере"];
//    }
//}
//- (IBAction)twitter:(id)sender {
//    oAuth = [[OAuth alloc] initWithConsumerKey:OAUTH_CONSUMER_KEY andConsumerSecret:OAUTH_CONSUMER_SECRET];
//    if (![DETweetComposeViewController canSendTweet]) {
//         
//        TwitterDialog *td = [[[TwitterDialog alloc] init] autorelease];
//        td.twitterOAuth = oAuth;
//        td.delegate = self;
//        td.logindelegate = self;
//        
//        [td show];
//    } else {
//        [oAuth loadOAuthTwitterContextFromUserDefaults]; 
//        [self twitterDidLogin];
//    }
//}

- (void)requestFailed:(NSNotification*)notification {
    [self performSelector:@selector(hideActivityIndicator)];
    if (shown_) {
        shown_ = NO;
        return;
    }
    shown_ = YES;
    NSError *error = [[notification userInfo] valueForKey:@"error"];
    if (error != nil) {
        
        [self showAlertWithTitle:@"Не удалось загрузить данные"
                      andMessage:@"Проверьте интернет-соединение"];
    } 
}


@end
