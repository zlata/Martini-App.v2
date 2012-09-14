//
//  User.m
//  Martini
//
//  Created by User on 21.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MUser.h"
#import "MNetworkManager.h"
#import "MAppDelegate.h"
#import "MSocialManager.h"
#import "MLocationManager.h"

@implementation MUser

@synthesize name = name_;
@synthesize surname = surname_;
@synthesize interests = interests_;
@synthesize status = status_;
@synthesize email = email_;
@synthesize login = login_;

@synthesize vkId = vkId_;
@synthesize fbId = fbId_;
@synthesize twId = twId_;

@synthesize lat = lat_;
@synthesize lon = lon_;
@synthesize isPrivate = isPrivate_;
@synthesize mutual = mutual_;
@synthesize following = following_;
@synthesize followMe = followMe_;

- (void)detailsFromDictionary:(NSDictionary *)dictionary {
    self.databaseId = [[dictionary valueForKey:@"id"] intValue];
    self.lon = [[dictionary valueForKey:@"lon"] floatValue];
    self.lat = [[dictionary valueForKey:@"lat"] floatValue];
    NSString *str =[dictionary valueForKey:@"vk_id"]; 
    if ([str length] > 1) {
        self.vkId = str;
    }
    str =[dictionary valueForKey:@"fb_id"]; 
    if ([str length] > 1) {
        self.fbId = str;
    }
    str =[dictionary valueForKey:@"tw_id"]; 
    if ([str length] > 1) {
        self.twId = str;
    }

    self.isPrivate = [[dictionary valueForKey:@"private"] boolValue];
    self.mutual = [[dictionary valueForKey:@"is_mutual"] boolValue];
    self.following = [[dictionary valueForKey:@"is_follwing"] boolValue];
    id followMe = [dictionary valueForKey:@"follow_me"];
    if (![followMe isKindOfClass:[NSNull class]]) {
        self.followMe = [followMe boolValue];
    }
    if (self.followMe && self.following) {
        self.mutual = YES;
    }
    
    self.login = [dictionary valueForKey:@"login"];
    NSString *name = [dictionary valueForKey:@"name"];
    if ([name length] > 0) {
        self.name = name;
    }
    self.email = [dictionary valueForKey:@"email"];
    self.imageUrl = [dictionary valueForKey:@"picurl"];
    self.status = [dictionary valueForKey:@"status_msg"];

    if ([self.name length] == 0) {
        self.name = self.login;
    }
 //   [self performSelectorInBackground:@selector(loadAvatar) withObject:nil];
}

+ (id)objectFromDictionary:(NSDictionary *)dictionary {
    MUser *user = [[[MUser alloc] init] autorelease];
    user.databaseId = [[dictionary valueForKey:@"user_id"] intValue];
    if (user.databaseId == 0) {
        user.databaseId = [[dictionary valueForKey:@"id"] intValue];
    }
    user.vkId = [dictionary valueForKey:@"vk_id"];
    user.fbId = [dictionary valueForKey:@"fb_id"];
    user.twId = [dictionary valueForKey:@"tw_id"];
    user.isPrivate = [[dictionary valueForKey:@"private"] boolValue];

    user.name = [dictionary valueForKey:@"name"];
    user.imageUrl = [dictionary valueForKey:@"picurl"];
    user.status = [dictionary valueForKey:@"status_msg"];
    user.email = [dictionary valueForKey:@"email"];
    user.mutual = [[dictionary valueForKey:@"is_mutual"] boolValue];
    user.following = [[dictionary valueForKey:@"is_follwing"] boolValue];
    id followMe = [dictionary valueForKey:@"follow_me"];
    if (![followMe isKindOfClass:[NSNull class]]) {
        user.followMe = [followMe boolValue];
    }
     if (user.followMe && user.following) {
        user.mutual = YES;
    }
    if ([user.name length] == 0) {
        user.name = user.login;
    }
//"vk_id":"0","fb_id":"0","tw_id":"0","private":"0"
    //SELECT * FROM m2_follows mf JOIN  `m2_users` mu ON mu.id = mf.follow_id WHERE mf.user_id = 24
    //SELECT mf.follow_id FROM m2_follows mf WHERE mf.user_id = 24 - я добавила
    //SELECT mf1.user_id FROM m2_follows mf1 WHERE mf1.follow_id=24 - меня добавили
    //SELECT mf.`follow_id`, mf2.user_id  AS follow_me FROM m2_follows mf LEFT JOIN (SELECT mf1.user_id FROM m2_follows mf1 WHERE mf1.follow_id=24) mf2 ON mf2.user_id=mf.`follow_id`
    //WHERE mf.user_id=24
    return user;
}

- (NSString*)fullname {
    if ([self.surname length] == 0) {
        return self.name;
    }
    return [self.surname stringByAppendingFormat:@"\n%@", self.name];
}

- (NSComparisonResult)compare:(MUser*)otherObject {
    return [self.name compare:otherObject.name options:NSCaseInsensitiveSearch];
}

- (void)dealloc {
    [name_ release];
    [surname_ release];
    [interests_ release];
    [status_ release];
    [email_ release];
    [login_ release];
    [vkId_ release];
    [fbId_ release];
    [twId_ release];
	
    [super dealloc];
}

@end

static MCurrentUser *sharedInstance = nil;

@interface MCurrentUser (PrivateMethods)
- (void)loadUserData;
@end


@implementation MCurrentUser

@synthesize user = user_;
@synthesize sid = sid_;
@synthesize image = image_;
@synthesize password = password_;
@synthesize event = event_;
@synthesize hidden = hidden_;

+ (MCurrentUser*)sharedInstance {
	@synchronized (self) {
		if (sharedInstance == nil) {
			sharedInstance = [[self alloc] init];
            [sharedInstance loadUserData];
		}
	}
	return sharedInstance;
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

- (id)init { 
    if ((self = [super init])) {
        [self loadUserData];
    }
    return self;
}

- (void)dealloc {
    [sid_ release];
    [user_ release];
    [image_ release];
    [password_ release];
    [event_ release];
	
    [super dealloc];
}

- (void)loadUserData {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    self.user = [[[MUser alloc] init] autorelease];
    
    self.user.name = [settings valueForKey:@"name"];
    self.user.login = [settings valueForKey:@"login"];
    self.password = [settings valueForKey:@"password"]; 
    int eventId = [[settings valueForKey:@"eventId"] intValue];
    if (eventId) {
        self.event = [[[MEvent alloc] init] autorelease];
        self.event.databaseId = eventId;
    }
    self.hidden = [settings boolForKey:@"hideLocation"];  
}

- (void)saveUserData {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setValue:self.user.name forKey:@"name"];    
    [settings setValue:self.user.login forKey:@"login"];    
    [settings setValue:self.password forKey:@"password"];    
}

- (void)saveNetworkData:(int)network userId:(NSString*)userId {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *ntw = [[MNetworkManager sharedInstance] stringForNetwork:network];
    [settings setValue:ntw forKey:@"network"];    
    [settings setValue:userId forKey:@"userId"];        
}

- (BOOL)authorizedLocal {
    BOOL local = (self.user.login != nil && [self.user.login length] > 0) &&
    (self.password != nil && [self.password length]) > 0;
    return local;
}

- (BOOL)authorizedNetwork {//return NO;//26
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *network = [settings valueForKey:@"network"];    
    BOOL autorized = [network length] > 1;
    return autorized;
}

- (NSString*)network {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return [settings valueForKey:@"network"];    
}

- (void)logout {
        
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    self.user.name = nil;
    self.user.databaseId = 0;
    self.user.login = nil;
    self.password = nil;
    self.sid = nil;
    self.event = nil;
    self.user.imagePath = nil;
    self.user.vkId = nil;
    self.user.fbId = nil;
    self.user.twId = nil;
    
    [self saveUserData];  
    [self saveNetworkData:-1 userId:0];
    
    MAppDelegate *delegate = appDelegate;
    [delegate popToNews];
    
    [[MSocialManager sharedInstance] logoutFb];
    [[MSocialManager sharedInstance] logoutTw];
    [[MSocialManager sharedInstance] logoutVk];
}


- (void)updateUserLocation {
    if (self.event != nil) {
        CLLocation *currentLocation = [MLocationManager sharedInstance].currentLocation;
        CLLocation *location = [[[CLLocation alloc] initWithLatitude:self.event.lat
                                                          longitude:self.event.lon] autorelease];  
        float distanceMeters = [location distanceFromLocation:currentLocation];
        self.event.distance = distanceMeters;
        if (![self.event actual]) {
            [[MNetworkManager sharedInstance] checkout:self.event];
            self.event = nil;
        }
    }
    [[MNetworkManager sharedInstance] updateUserLocation];
}

- (void)hideLocation:(BOOL)hide {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setValue:[NSNumber numberWithBool:hide] forKey:@"hideLocation"];  
    self.hidden = hide;
}

- (BOOL)hideLocation {
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    return [settings boolForKey:@"hideLocation"];    
}

- (UIImage*)image {
    if (image_ == nil) {
        if (user_.imagePath == nil) {
            return nil;
        }
        return [UIImage imageWithContentsOfFile:user_.imagePath];
    }
    return image_;
}

@end













