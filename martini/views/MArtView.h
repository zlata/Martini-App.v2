//
//  MArtView.h
//  martini
//
//  Created by zlata samarskaya on 24.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MFontLabel.h"

@interface MArtView : UIView <UIScrollViewDelegate>{
    
    IBOutlet UIScrollView *scroll;
    NSArray *photos_;
    int currentIndex_;
    NSMutableArray *photoViews_;
}

@property (retain, nonatomic) IBOutlet UIButton *saveButton;
@property(nonatomic, retain)NSArray *photos;

- (void)scrollToIndex:(int)index;
- (void)unloadView;
- (void)unload;
+ (id)viewFromNib;
- (void)load;
- (NSString*)currentImageUrl;
- (UIImage*)currentImage;
@end

@interface MGalleryView : UIView {
	UIImageView *imageView;
    UIActivityIndicatorView *indicator;
}

- (void)setImageFrame:(CGRect)rect;
- (void)setImage:(UIImage*)image;
- (void)unloadImage;
- (BOOL)imageLoaded;
- (UIImage*)image;
@end
