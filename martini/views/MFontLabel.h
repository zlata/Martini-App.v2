//
//  MFontLabel.h
//  martini
//
//  Created by zlata samarskaya on 07.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@interface MFontLabel : UILabel

@end

@interface MBoldFontLabel : UILabel

@end

@interface MFontButton : UIButton

@end

@interface MBorderedTextField : UITextField 

@end

@interface MBorderedTextView : UITextView 

@end

@interface MRedView : UIView 

@end

@class MModel;

@interface MBaseCell : UITableViewCell {
    MModel *model_;
    IBOutlet MFontLabel *subtitle;
    IBOutlet MBoldFontLabel *title;
    IBOutlet UIImageView *imgView;
}

@property(nonatomic, retain) MModel *model;

+ (id)viewFromNib;
+ (NSString*)nibName;
- (void)loadModel:(MModel*)model;

@end

@class MUser;
@class MEvent;

@interface MapAnnotation : NSObject<MKAnnotation> {
	
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
    MUser *user_;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, retain) MUser *user;
@property (nonatomic, readonly, copy) NSString *title;

-(id)initWithUser:(MUser*)user;
- (id)initWithEvent:(MEvent *)event;

@end

@interface WarningView : UIView {
    
}
@property (retain, nonatomic) IBOutlet UILabel *warning;

+ (id)viewFromNib;

@end
