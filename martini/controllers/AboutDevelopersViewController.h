//
//  AboutDevelopersViewController.h
//  VogueBrides
//
//  Created by zlata samarskaya on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"


@interface AboutDevelopersViewController : BaseViewController {
	IBOutlet UILabel *titleLabel;
	IBOutlet UIScrollView *scroll;
	IBOutlet UIView *contactView;
	IBOutlet UILabel *contactLabel;
	IBOutlet UIImageView *contactImage;
	IBOutlet UILabel *mailLabel;
	IBOutlet UILabel *urlLabel;
}

@end
