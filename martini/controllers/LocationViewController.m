//
//  LocationViewController.m
//  martini
//
//  Created by zlata samarskaya on 27.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationViewController.h"

#import "MLocationManager.h"

#import "MFontLabel.h"
#import "MUser.h"
#import "MModel.h"


@implementation LocationViewController

@synthesize user = user_;
@synthesize event = event_;
@synthesize result = result_;
@synthesize events = events_;

- (id)initWithNibName:(NSString *)nibNameOrNil 
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)setMapRegion {	
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(0, 0);
    MapAnnotation *annotation;
    if (self.user != nil) {
        coordinate = CLLocationCoordinate2DMake(self.user.lat, self.user.lon);
        annotation = [[MapAnnotation alloc] initWithUser:self.user];
        [mapView addAnnotation:annotation];
        [annotation release];    
    } 
    if (self.event != nil) {
        coordinate = CLLocationCoordinate2DMake(self.event.lat, self.event.lon);
        annotation = [[MapAnnotation alloc] initWithEvent:self.event];
        [mapView addAnnotation:annotation];
        [annotation release];    
    }
    
    if (self.result != nil) {
        NSArray *array = self.result.data;
        for (MUser *_user in array) {
            if (!_user.mutual) {
                continue;
            }
            if (_user.lat == 0 && _user.lon == 0) {
                continue;
            }
            coordinate = CLLocationCoordinate2DMake(_user.lat, _user.lon);
            annotation = [[MapAnnotation alloc] initWithUser:_user];

            [mapView addAnnotation:annotation];
            [annotation release];    
        }
    }
    if (self.events != nil) {
        for (MEvent *event in self.events) {
            if (!event.actual) {
                continue;
            }
            if (event.lat == 0 && event.lon == 0) {
                continue;
            }
            coordinate = CLLocationCoordinate2DMake(event.lat, event.lon);
            annotation = [[MapAnnotation alloc] initWithEvent:event];
           
            [mapView addAnnotation:annotation];
            [annotation release];    
        }
    }
    if (coordinate.latitude == 0 && coordinate.longitude == 0) {
        CLLocationCoordinate2D current = [MLocationManager sharedInstance].currentLocation.coordinate;
        if (current.latitude != 0 && current.longitude != 0) 
            coordinate = current;
        else
           coordinate = CLLocationCoordinate2DMake(55.7795658315, 37.5871896745);
    }
    MKCoordinateSpan span = MKCoordinateSpanMake(0.02, 0.02);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
	[mapView setRegion:region];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    mapView.showsUserLocation = YES;
    
    [self setMapRegion];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
    [mapView release];
    mapView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [mapView release];
    [user_ release];
    [event_ release];
    [result_ release];
    
    [super dealloc];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView_ viewForAnnotation:(id<MKAnnotation>)annotation {
    NSString *title = ((MapAnnotation*)annotation).title;
    MKPinAnnotationView *annView = [[[MKPinAnnotationView alloc]
                                     initWithAnnotation:annotation reuseIdentifier:title] autorelease];
    annView.canShowCallout = YES;
    if ( [annotation isKindOfClass:[ MKUserLocation class]] ) {
        annView.pinColor = MKPinAnnotationColorRed;
        return annView;
    }
    if (self.result != nil)
        annView.pinColor = MKPinAnnotationColorPurple;
    else
        annView.pinColor = MKPinAnnotationColorGreen;
    
    return annView;
}

@end

