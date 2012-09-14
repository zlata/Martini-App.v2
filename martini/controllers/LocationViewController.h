//
//  LocationViewController.h
//  martini
//
//  Created by zlata samarskaya on 27.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <MapKit/MapKit.h>

#import "BaseViewController.h"

@class MUser;
@class MEvent;
@class MFollowsResult;

@interface LocationViewController : BaseViewController <MKMapViewDelegate> {
    
    IBOutlet MKMapView *mapView;
    MUser *user_;
    MFollowsResult *result_;
    MEvent *event_;
    NSArray *events_;
}

@property (nonatomic, retain) MUser *user;
@property (nonatomic, retain) MFollowsResult *result;
@property (nonatomic, retain) MEvent *event;
@property (nonatomic, retain) NSArray *events;

@end
