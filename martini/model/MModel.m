//
//  MModel.m
//  martini
//
//  Created by zlata samarskaya on 12.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "MUser.h"
#import "MModel.h"
#import "MUtils.h"

#import "MLocationManager.h"

@implementation MModel

@synthesize databaseId = databaseId_;

+ (id)objectFromDictionary:(NSDictionary*)dictionary {
    return nil;
}

@end

@implementation MImagedModel

@synthesize imagePath = imagePath_;
@synthesize imageUrl = imageUrl_;

- (void)dealloc {
    [imagePath_ release];
    [imageUrl_ release];
    
    [super dealloc];
}

- (void)loadImage {
    if ([self.imageUrl length] == 0) {
        return;
    }
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    self.imagePath = [MUtils saveImageFromPath:self.imageUrl folder:NSStringFromClass([self class])];
    [pool drain];
}

- (void)setImageUrl:(NSString *)imageUrl {
    if ([imageUrl_ isEqualToString:imageUrl]) {
        return;
    }
//    if ([imageUrl length] == 0) {
//        return;
//    }
    [imageUrl_ autorelease];
    imageUrl_ = [imageUrl retain];
    
    [self performSelectorInBackground:@selector(loadImage) withObject:nil];
}

@end

@implementation MPhoto

- (void)setImageUrl:(NSString *)imageUrl {
    if ([imageUrl_ isEqualToString:imageUrl]) {
        return;
    }
    if ([imageUrl length] == 0) {
        return;
    }
    [imageUrl_ autorelease];
    imageUrl_ = [imageUrl retain];
}

- (void)lazyLoad {
    
    [self performSelectorInBackground:@selector(loadImage) withObject:nil];
}

@end

@implementation MMessageThread

@synthesize recipient = recipient_;
@synthesize lastUpdate = lastUpdate_;
@synthesize lastMessage = lastMessage_;
@synthesize status = status_;

@synthesize messagesCount = messagesCount_;
@synthesize newMessages = newMessages_;

- (void)dealloc {
    [recipient_ release];
    [lastUpdate_ release];
    [lastMessage_ release];
    [status_ release];
    
    [super dealloc];
}

+ (id)objectFromDictionary:(NSDictionary *)dictionary {
    //"last_update":"1320842402","":"read","":"0","":"2","last_msg_text":"msgtex"
    
    MMessageThread *th = [[[MMessageThread alloc] init] autorelease];
    th.databaseId = [[dictionary valueForKey:@"thread_id"] intValue];
    th.newMessages = [[dictionary valueForKey:@"new_messages"] intValue];
    th.messagesCount = [[dictionary valueForKey:@"total_msgs"] intValue];
    
    th.recipient = [[[MUser alloc] init] autorelease];
    th.recipient.databaseId = [[dictionary valueForKey:@"user_id"] intValue];
    th.recipient.name = [dictionary valueForKey:@"user_name"];
    
    th.status = [dictionary valueForKey:@"status"];
    int time = [[dictionary valueForKey:@"last_update"] intValue];
    th.lastUpdate = [NSDate dateWithTimeIntervalSince1970:time];
    
    return th;
}

@end

@implementation MMessage

@synthesize thread = thread_;
@synthesize date = date_;
@synthesize message = message_;
@synthesize status = status_;
@synthesize title = title_;
@synthesize user = user_;

- (void)dealloc {
    [thread_ release];
    [date_ release];
    [message_ release];
    [status_ release];
    [title_ release];
    [user_ release];
    
    [super dealloc];
}

+ (id)objectFromDictionary:(NSDictionary *)dictionary {
    //{"id":"9","text":"test message","date":"1317301236","status":"new"}
    
    MMessage *msg = [[[MMessage alloc] init] autorelease];
    msg.databaseId = [[dictionary valueForKey:@"id"] intValue];
     
    msg.message = [dictionary valueForKey:@"text"];
    msg.status = [dictionary valueForKey:@"status"];
    msg.imageUrl = [dictionary valueForKey:@"picurl"];
    int time = [[dictionary valueForKey:@"date"] intValue];
    msg.date = [NSDate dateWithTimeIntervalSince1970:time];
    
    msg.user = [[[MUser alloc] init] autorelease];
    msg.user.databaseId = [[dictionary valueForKey:@"user_id"] intValue];//
    msg.user.name = [dictionary valueForKey:@"user_name"];
    msg.imageUrl = [dictionary valueForKey:@"user_picurl"];
    
    msg.thread = [[[MMessageThread alloc] init] autorelease];
    msg.thread.databaseId = [[dictionary valueForKey:@"thread_id"] intValue];
    
    return msg;
}

@end

@implementation MNewsCategory


@synthesize title = title_;
@synthesize key = key_;
@synthesize count = count_;
@synthesize hasNew = hasNew_;

- (void)dealloc {
    [title_ release];
    [key_ release];
    
    [super dealloc];
}

+ (id)objectFromDictionary:(NSDictionary *)dictionary {
    
    MNewsCategory *news = [[[MNewsCategory alloc] init] autorelease];
    
    news.title = [dictionary valueForKey:@"cat_name"];
    news.key = [dictionary valueForKey:@"cat_key"];
    //int c = arc4random() % 23;
    news.count = [[dictionary valueForKey:@"count"] intValue];
    int n = [[dictionary valueForKey:@"hasNew"] intValue];
    news.hasNew = n  > 0; //c / 2 > 0;//
    if ([MCurrentUser sharedInstance].sid == nil) {
        news.hasNew = YES;
    }
    return news;
}

@end

@implementation MNews

@synthesize title = title_;
@synthesize date = date_;
@synthesize text = text_;
@synthesize category = category_;
@synthesize fullImageUrl = fullImageUrl_;
@synthesize fullImagePath = fullImagePath_;
@synthesize isNew = isNew_;

- (void)dealloc {
    [title_ release];
    [date_ release];
    [text_ release];
    [category_ release];
    [fullImageUrl_ release];
    [fullImagePath_ release];
    
    [super dealloc];
}

+ (id)objectFromDictionary:(NSDictionary *)dictionary {
    
    MNews *news = [[[MNews alloc] init] autorelease];
    news.databaseId = [[dictionary valueForKey:@"id"] intValue];
    news.text = [dictionary valueForKey:@"text"];
    news.category = [dictionary valueForKey:@"category"];
    
    news.title = [dictionary valueForKey:@"title"];
    news.imageUrl = [dictionary valueForKey:@"pic_thumb"];
    if ([news.imageUrl length] == 0) {
        news.imageUrl = [dictionary valueForKey:@"picurl"];
    }
    int time = [[dictionary valueForKey:@"date"] intValue];
    news.date = [NSDate dateWithTimeIntervalSince1970:time];
    news.isNew = [[dictionary valueForKey:@"new"] boolValue];
    if ([MCurrentUser sharedInstance].sid == nil) {
        news.isNew = YES;
    }

    return news;
}

- (void)detailsFromDictionary:(NSDictionary *)dictionary {
    self.text = [dictionary valueForKey:@"text"];
    self.fullImageUrl = [dictionary valueForKey:@"picurl"];
    [self performSelectorInBackground:@selector(loadFullImage) withObject:nil];
}

- (void)loadFullImage {
    if ([self.fullImageUrl length] == 0) {
        return;
    }
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    self.fullImagePath = [MUtils saveImageFromPath:self.fullImageUrl folder:@"MNews"];
    [pool drain];
}

@end

@implementation MEvent

@synthesize title = title_;
@synthesize date = date_;
@synthesize desc = desc_;
@synthesize lat = lat_;
@synthesize lon = lon_;
@synthesize distance = distance_;

- (void)dealloc {
    [title_ release];
    [date_ release];
    [desc_ release];

    [super dealloc];
}

+ (id)objectFromDictionary:(NSDictionary *)dictionary {
    
    MEvent *event = [[[MEvent alloc] init] autorelease];
    event.databaseId = [[dictionary valueForKey:@"id"] intValue];
    
    event.title = [dictionary valueForKey:@"title"];
    event.desc = [dictionary valueForKey:@"description"];
    event.imageUrl = [dictionary valueForKey:@"picurl"];
   
    int time = [[dictionary valueForKey:@"date"] intValue];
    event.date = [NSDate dateWithTimeIntervalSince1970:time];
    
    event.lat = [[dictionary valueForKey:@"lat"] floatValue];
    event.lon = [[dictionary valueForKey:@"lon"] floatValue];
    
    if ([MLocationManager sharedInstance].enabled) {
        CLLocation *currentLocation = [MLocationManager sharedInstance].currentLocation;
        CLLocation *location = [[[CLLocation alloc] initWithLatitude:event.lat
                                                          longitude:event.lon] autorelease];  
        float distanceMeters = [location distanceFromLocation:currentLocation];
        event.distance = distanceMeters;
    }

    return event;// 
}

- (void)detailsFromDictionary:(NSDictionary *)dictionary {
    self.title = [dictionary valueForKey:@"title"];
    self.desc = [dictionary valueForKey:@"description"];
    self.imageUrl = [dictionary valueForKey:@"picurl"];
    
    int time = [[dictionary valueForKey:@"date"] intValue];
    self.date = [NSDate dateWithTimeIntervalSince1970:time];
    
    self.lat = [[dictionary valueForKey:@"lat"] floatValue];
    self.lon = [[dictionary valueForKey:@"lon"] floatValue];  
}

- (BOOL)actual { 
    if (DEBUG_EVENTS) {
        return YES;
    }
    return self.distance < maxDistance && [MUtils date:self.date equal:[NSDate date]];
}

- (BOOL)past {
    if (DEBUG_EVENTS) {
        return NO;
    }
  return [self.date timeIntervalSinceNow] < -(5 * 3600);
}

- (NSComparisonResult)compare:(MEvent*)otherObject {
    
    return [[NSNumber numberWithFloat:self.distance] compare:[NSNumber numberWithFloat:otherObject.distance]];
}

@end

@implementation MInvite

@synthesize date = date_;
@synthesize status = status_;
@synthesize recieved = recieved_;
@synthesize user = user_;
@synthesize coctail = coctail_;

- (void)dealloc {
    [date_ release];
    [status_ release];
    [user_ release];
    [coctail_ release];
    
    [super dealloc];
}

+ (id)objectFromDictionary:(NSDictionary *)dictionary {
    //  {"id":"4","user_id":"17","name":"testname","picurl":"","date":"1323446561","status":"declined","read":"0"},
    MInvite *invite = [[[MInvite alloc] init] autorelease];
    invite.databaseId = [[dictionary valueForKey:@"id"] intValue];
    
    invite.user = [[[MUser alloc] init] autorelease];
    invite.user.databaseId = [[dictionary valueForKey:@"user_id"] intValue];
    invite.user.name = [dictionary valueForKey:@"name"];
    invite.imageUrl = [dictionary valueForKey:@"picurl"];

    invite.status = [dictionary valueForKey:@"status"];
    invite.recieved = [[dictionary valueForKey:@"read"] boolValue];

    int time = [[dictionary valueForKey:@"date"] intValue];
    invite.date = [NSDate dateWithTimeIntervalSince1970:time];
    
    return invite;
}

@end

@implementation MCoctail 
 
@synthesize name = name_;
@synthesize desc = desc_;
@synthesize fullImageUrl = fullImageUrl_;
@synthesize fullImagePath = fullImagePath_;

- (void)dealloc {
    [name_ release];
    [desc_ release];
    [fullImagePath_ release];
    [fullImageUrl_ release];
    
    [super dealloc];
}

+ (id)objectFromDictionary:(NSDictionary *)dictionary {
    //{"id":"1","name":"bianco on ice lime","description":"desc","picurl":"/v2/cocktails_images/1.png"}
    MCoctail *coctail = [[[MCoctail alloc] init] autorelease];
    coctail.databaseId = [[dictionary valueForKey:@"id"] intValue];
    coctail.name = [dictionary valueForKey:@"name"];
    coctail.desc = [dictionary valueForKey:@"description"];
   // coctail.imageUrl = [dictionary valueForKey:@"picurl"];
    coctail.imageUrl = [dictionary valueForKey:@"pic_thumb"];
    coctail.fullImageUrl = [dictionary valueForKey:@"picurl"];
    [coctail performSelectorInBackground:@selector(loadFullImage) withObject:nil];
    
    return coctail;
}

- (void)loadFullImage {
    if ([self.fullImageUrl length] == 0) {
        return;
    }
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    self.fullImagePath = [MUtils saveImageFromPath:self.fullImageUrl folder:@"MCoctail"];
    [pool drain];
}


@end

@implementation MResult

@synthesize data = data_;
@synthesize page = page_;
@synthesize pages = pages_;

- (void)dealloc {
    [data_ release];
    
    [super dealloc];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.pages = [[dictionary valueForKey:@"pagesCount"] intValue];
    self.page = [[dictionary valueForKey:@"page"] intValue];
    NSMutableArray *result = [NSMutableArray array];
    NSArray *arr = [dictionary valueForKey:@"follows"];
    for (NSDictionary *data in arr) {
        MUser *user = [MUser objectFromDictionary:data];
        user.following = YES;
        [result addObject:user];
    }
    self.data = result;
}

@end

@implementation MFollowsResult

@synthesize count = count_;

- (void)dealloc {
    
    [super dealloc];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.pages = [[dictionary valueForKey:@"pagesCount"] intValue];
    self.page = [[dictionary valueForKey:@"page"] intValue];
    self.count = [[dictionary valueForKey:@"followsCount"] intValue];
    NSMutableArray *result = [NSMutableArray array];
    NSArray *arr = [dictionary valueForKey:@"follows"];
    for (NSDictionary *data in arr) {
        MUser *user = [MUser objectFromDictionary:data];
        user.following = YES;
        if (user.followMe && user.following) {
            user.mutual = YES;
        }
        [result addObject:user];
    }
    self.data = result;
}

@end


@implementation MSearchResult

@synthesize searchString = searchString_;

- (void)dealloc {
    [searchString_ release];
    
    [super dealloc];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.pages = [[dictionary valueForKey:@"pagesCount"] intValue];
    self.page = [[dictionary valueForKey:@"page"] intValue];
    NSMutableArray *result = [NSMutableArray array];
    NSArray *arr = [dictionary valueForKey:@"results"];
    for (NSDictionary *data in arr) {
        [result addObject:[MUser objectFromDictionary:data]];
    }
    self.data = result;
}

@end

@implementation MThreadResult

@synthesize from = from_;
@synthesize to = to_;

- (void)dealloc {
    [from_ release];
    [to_ release];
    
    [super dealloc];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.pages = [[dictionary valueForKey:@"pagesCount"] intValue];
    self.page = [[dictionary valueForKey:@"page"] intValue];
    NSMutableArray *result = [NSMutableArray array];
    NSArray *arr = [dictionary valueForKey:@"threads"];
    for (NSDictionary *data in arr) {
        [result addObject:[MMessageThread objectFromDictionary:data]];
    }
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"last_update" ascending:NO];
    [result sortUsingDescriptors:[NSArray arrayWithObject:sorter]]; 
    [sorter release];    
    self.data = result;
}

@end

@implementation MMessagesResult

@synthesize thread = thread_;
@synthesize user = user_;
@synthesize event = event_;

- (void)dealloc {
    [user_ release];
    [thread_ release];
    [event_ release];
    
    [super dealloc];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.pages = [[dictionary valueForKey:@"pagesCount"] intValue];
    self.page = [[dictionary valueForKey:@"page"] intValue];
    NSMutableArray *result = [NSMutableArray array];
    NSArray *arr = [dictionary valueForKey:@"messages"];
    for (NSDictionary *data in arr) {
        MMessage *message = [MMessage objectFromDictionary:data];
        message.imageUrl = [dictionary valueForKey:@"userPic"];
        [result addObject:message];
    }
    self.data = result;
}

@end

@implementation MGuestsResult

@synthesize event = event_;

- (void)dealloc {
    [event_ release];
    
    [super dealloc];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.pages = [[dictionary valueForKey:@"pagesCount"] intValue];
    self.page = [[dictionary valueForKey:@"page"] intValue];
    
    NSMutableArray *result = [NSMutableArray array];
    NSArray *arr = [dictionary valueForKey:@"guests"];
    for (NSDictionary *data in arr) {
        [result addObject:[MUser objectFromDictionary:data]];
    }
    self.data = result;
}

@end

@implementation MInvitesResult

@synthesize replies = replies_;
@synthesize repliesPages = repliesPages_;
@synthesize event = event_;

@synthesize read = read_;
@synthesize onlyInvites = onlyInvites_;
@synthesize onlyReplies = onlyReplies_;

- (void)dealloc {
    [replies_ release];
    [event_ release];
    
    [super dealloc];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.pages = [[dictionary valueForKey:@"invitesPages"] intValue];
    self.repliesPages = [[dictionary valueForKey:@"repliesPages"] intValue];
    self.page = [[dictionary valueForKey:@"page"] intValue];

    NSMutableArray *result = [NSMutableArray array];
    NSArray *arr = [dictionary valueForKey:@"invites"];
    for (NSDictionary *data in arr) {
        MInvite *invite = [MInvite objectFromDictionary:data];
        if ([invite.status isEqualToString:@"accepted"]) {
            continue;
        }
        [result addObject:invite];
    }
    self.data = result;

    result = [NSMutableArray array];
    arr = [dictionary valueForKey:@"replies"];
    for (NSDictionary *data in arr) {
        MInvite *invite = [MInvite objectFromDictionary:data];
//        if ([invite.status isEqualToString:@"accepted"]) {
//            continue;
//        }
//        if (![invite.status isEqualToString:@"new"]) {
//            continue;
//        }
       [result addObject:invite];
    }
    self.replies = result;
}

@end

@implementation MNewsResult

@synthesize category = category_;

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.pages = [[dictionary valueForKey:@"pagesCount"] intValue];
    self.page = [[dictionary valueForKey:@"page"] intValue];
    
 //   NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSMutableArray *result = [NSMutableArray array];
    NSArray *arr = [dictionary valueForKey:@"news"];
    for (NSDictionary *data in arr) {
        MNews *news = [MNews objectFromDictionary:data];
//        NSString *key = [news.category length] ? news.category : @"news";
//        NSMutableArray *array = [result valueForKey:key];
//        if (array == nil) {
//            array = [NSMutableArray array];
//            [result setValue:array forKey:key]; 
//        }
        [result addObject:news];
    }
    self.data = result;
}

@end

@implementation MEventsResult

- (void)updateFromDictionary:(NSDictionary *)dictionary {
    self.pages = [[dictionary valueForKey:@"pagesCount"] intValue];
    self.page = [[dictionary valueForKey:@"page"] intValue];
    
    NSMutableArray *result = [NSMutableArray array];
    NSArray *arr = [dictionary valueForKey:@"events"];
    for (NSDictionary *data in arr) {
        [result addObject:[MEvent objectFromDictionary:data]];
    }
    if ([MLocationManager sharedInstance].enabled) {
        self.data = [result sortedArrayUsingSelector:@selector(compare:)];
        return;
    }
    self.data = result;

}

@end
