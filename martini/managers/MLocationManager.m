//
//  TLocationManager.m
//  treveller
//
//  Created by zlata samarskaya on 05.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MLocationManager.h"
#import "MResponceManager.h"
#import "MNetworkManager.h"
#import "MUser.h"

static MLocationManager *sharedInstance = nil;

@implementation MLocationManager

@synthesize currentLocation; 
@synthesize currentHeading;
@synthesize locationManager;
@synthesize headingManager;
@synthesize enabled;

- (void)dealloc {
    [locationManager release];
    [currentLocation release];
    [currentHeading release];
    
    [super dealloc];
}

+ (MLocationManager*)sharedInstance {
	@synchronized (self) {
		if (sharedInstance == nil) {
			sharedInstance = [[self alloc] init];
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

-(id)init{ 
	if((self =[super init])) { 
        CLLocationManager *locationManager_ = [[CLLocationManager alloc] init];  
		locationManager_.delegate = self; 
		locationManager_.distanceFilter = 10;  		
        locationManager_.desiredAccuracy = kCLLocationAccuracyBest; 
		[locationManager_ startUpdatingLocation];
        self.enabled = YES;
        self.currentLocation = nil;
//		if(useTestLocation || TARGET_IPHONE_SIMULATOR)
//			[self performSelector:@selector(setTestLocation) withObject:nil afterDelay:0.5];
        self.locationManager = locationManager_;
        [locationManager_ release];
	} 
	return self; 
} 

- (void)setTestLocation {
	self.currentLocation = [[[CLLocation alloc] initWithLatitude:-34.60842 longitude:-58.37316] autorelease];//51.543453 ,0//44.5765633.52124
	//[currentLocation release];
	[self performSelector:@selector(setTestLocation) withObject:nil afterDelay:5];
}

#pragma mark -
#pragma mark Location

- (void)locationManager:(CLLocationManager *)manager 
    didUpdateToLocation:(CLLocation *)newLocation 
		   fromLocation:(CLLocation *)oldLocation { 
    if (!self.enabled) {
        self.enabled = YES;
    }
    self.currentLocation = newLocation; 
    [[MCurrentUser sharedInstance] updateUserLocation];
} 

- (void) locationManager:(CLLocationManager *) manager 
		didUpdateHeading:(CLHeading *) newHeading {
    
	self.currentHeading = newHeading;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"locationManager failed %@", [error localizedDescription]);
    if (error.code == kCLErrorDenied) {
        self.enabled = NO;
    }
}

- (void)startUpdatingHeading {
    if([CLLocationManager headingAvailable] == NO) {
       NSLog(@"locationManager heading not available");
         return;
    }
	CLLocationManager *manager = [[CLLocationManager alloc] init];
	manager.delegate = self;
    manager.desiredAccuracy = kCLLocationAccuracyBest;
	manager.headingFilter = 5.0;
	
	[manager startUpdatingHeading];    
	self.headingManager = manager;
	[manager release];
}

- (void)stopUpdatingHeading {
	[self.headingManager stopUpdatingHeading];
    self.headingManager = nil;
    [headingManager release];
}

@end

@implementation MPopulatedAddress

@synthesize city;
@synthesize country;
@synthesize state;
@synthesize address;

- (void)dealloc {
    [city release];
    [state release];
    [country release];
    [address release];
    
    [super dealloc];
}

@end