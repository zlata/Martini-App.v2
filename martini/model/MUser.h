//
//  User.h
//  Martini
//
//  Created by User on 21.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MModel.h"

@interface MUser : MImagedModel {
    NSString *name_;
    NSString *surname_;
    NSString *login_;
    NSString *email_;
    NSString *interests_;
    NSString *status_;

    NSString *vkId_;
    NSString *fbId_;
    NSString *twId_;

    float lat_;
    float lon_;
    
    BOOL isPrivate_;
    BOOL mutual_;
    BOOL following_;
    BOOL followMe_;
}

@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *surname;
@property(nonatomic, retain) NSString *login;
@property(nonatomic, retain) NSString *email;
@property(nonatomic, retain) NSString *interests;
@property(nonatomic, retain) NSString *status;

@property(nonatomic, retain) NSString *vkId;
@property(nonatomic, retain) NSString *fbId;
@property(nonatomic, retain) NSString *twId;

@property(nonatomic, assign) float lat;
@property(nonatomic, assign) float lon;

@property(nonatomic, assign) BOOL isPrivate;
@property(nonatomic, assign) BOOL mutual;
@property(nonatomic, assign) BOOL following;
@property(nonatomic, assign) BOOL followMe;

- (void)detailsFromDictionary:(NSDictionary*)dictionary;
+ (id)objectFromDictionary:(NSDictionary*)dictionary;
- (NSString*)fullname;

@end

@interface MCurrentUser : NSObject {
    MUser *user_;
    MEvent *event_;
    NSString *password_;
    NSString *sid_;
    UIImage *image_;
    
    BOOL hidden_;
}

@property(nonatomic, retain) MUser *user;
@property(nonatomic, retain) MEvent *event;
@property(nonatomic, retain) NSString *password;
@property(nonatomic, retain) NSString *sid;
@property(nonatomic, retain) UIImage *image;
@property(nonatomic, assign) BOOL hidden;

+ (MCurrentUser*)sharedInstance;
//    
- (void)updateUserLocation;
- (void)saveUserData;
- (BOOL)authorizedLocal;
- (BOOL)authorizedNetwork;
- (void)saveNetworkData:(int)network userId:(NSString*)userId;
- (void)hideLocation:(BOOL)hide;
- (BOOL)hideLocation;
- (void)logout;
- (NSString*)network;
@end

