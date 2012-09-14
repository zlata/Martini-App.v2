//
//  TLocationManager.h
//  treveller
//
//  Created by zlata samarskaya on 05.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class MPopulatedAddress;

@interface MLocationManager : NSObject <CLLocationManagerDelegate> {
    CLLocation* currentLocation; 
    CLHeading *currentHeading;
    CLLocationManager *locationManager;
    CLLocationManager *headingManager;
    BOOL enabled;
} 

@property (nonatomic,assign) BOOL enabled; 
@property (nonatomic,retain) CLLocation* currentLocation; 
@property (nonatomic,retain) CLHeading* currentHeading; 
@property (nonatomic,retain) CLLocationManager *locationManager; 
@property (nonatomic,retain) CLLocationManager *headingManager; 

+ (MLocationManager*)sharedInstance;
- (void)startUpdatingHeading;
- (void)stopUpdatingHeading;

@end

@interface MPopulatedAddress : NSObject {
    NSString *city;
    NSString *state;
    NSString *country;
    NSString *address;
}

@property (nonatomic,retain) NSString* city; 
@property (nonatomic,retain) NSString* state; 
@property (nonatomic,retain) NSString* country; 
@property (nonatomic,retain) NSString* address; 

@end