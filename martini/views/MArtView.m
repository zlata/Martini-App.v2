//
//  MArtView.m
//  martini
//
//  Created by zlata samarskaya on 24.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "MArtView.h"
#import "MModel.h"

#define kImageViewTag 0x8000
#define kIndicatorViewTag 0x9000

@implementation MArtView

@synthesize saveButton;
@synthesize photos = photos_;

+ (id)viewFromNib {
    NSArray *niblets = [[NSBundle mainBundle] loadNibNamed:@"MArtView"
                                                     owner:self
                                                   options:nil];
    
    for (id niblet in niblets) {
        if ([niblet isKindOfClass:[UIView class]]) {
            MArtView *photos = [[niblet retain] autorelease];
            
            return photos;
        }
    }
    
    return nil;
    
}

- (void)unloadView {
    for (MGalleryView *v in scroll.subviews) {
        if ([v isKindOfClass:[MGalleryView class]]) {
            [v unloadImage];
        }
    } 
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)loadPage:(int)index {
	if (index >= [self.photos count]) {
        return;
    }
	if (index < 0) {
        return;
    }
	MPhoto *photo = [self.photos objectAtIndex:index];	
	
	MGalleryView *containerView = (MGalleryView*)[scroll viewWithTag:(kImageViewTag + index + 1)];
    if (photo.imagePath != nil) {
        [containerView setImage:[UIImage imageWithContentsOfFile:photo.imagePath]];
    } else {
        [photo lazyLoad];
    }
}

- (void)unloadPage:(int)index {
	
	MGalleryView *containerView = (MGalleryView*)[scroll viewWithTag:(kImageViewTag + index + 1)];
	[containerView unloadImage];
}

- (void)load {
    NSInteger pageCount = [self.photos count];
    
    CGSize size = CGSizeMake(scroll.frame.size.width * pageCount, 
                             scroll.frame.size.height);
    [scroll setContentSize:size];
    for (MPhoto *photo in self.photos) {
        [photo addObserver:self forKeyPath:@"imagePath" options:NSKeyValueObservingOptionNew context:nil];
    }
	int index = pageCount - 1;
	//CGRect screen = [UIScreen mainScreen].bounds;
	int width = scroll.frame.size.width;
	
	MPhoto *photo = [self.photos objectAtIndex:index];
	UIImage *image = [UIImage imageWithContentsOfFile:photo.imagePath];
	
	CGRect frame = scroll.frame;
    frame.origin = CGPointZero;
	MGalleryView *container = [[MGalleryView alloc] initWithFrame:frame];
    
	container.tag = kImageViewTag;
	[container setImage:image];
	[scroll addSubview:container];
	
	[container release];
	if ([self.photos count] == 1) {
        scroll.scrollEnabled = NO;
        return;
    }
	index = 1;
	
	for(MPhoto *photo in self.photos) {
		float x = index * width;
		
		UIImage *image = [UIImage imageWithContentsOfFile:photo.imagePath];
		container = [[MGalleryView alloc] initWithFrame:CGRectMake(x, frame.origin.y, 
                                                                   width, frame.size.height) ];
		[container setImage:image];
        container.tag = kImageViewTag + index;
		
		[scroll addSubview:container];
		
		[container release];
		index++;
	}
	
	photo = [self.photos objectAtIndex:0];
	image = [UIImage imageWithContentsOfFile:photo.imagePath];
	container = [[MGalleryView alloc] initWithFrame:CGRectMake(index * width, 
                                                               frame.origin.y, width,frame.size.height)];
	container.tag = kImageViewTag + index;
	[container setImage:image];
	[scroll addSubview:container];
	
	[container release];
	scroll.contentSize = CGSizeMake(([self.photos count] + 2) * width, scroll.frame.size.height);
	if (scroll.contentOffset.x == 0) {
		[scroll scrollRectToVisible:CGRectMake((currentIndex_ + 1) * width, 0, width, scroll.frame.size.height) animated:NO];
	} 
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        return;
    }
    [self load];
    [self loadPage:0];
    [self loadPage:1];
    [self loadPage:2];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView {
	int width = (int)self.frame.size.width;
	int index = floor(scrollView.contentOffset.x / width);
    
	[self scrollToIndex:index];
}

- (void)scrollToIndex:(int)index {
	int width = (int)self.frame.size.width;
	if (index > 0 && index <= [self.photos count]) {
		currentIndex_ = index - 1;
		//[self loadPage:currentIndex_];
	}	
	if (index == 0) {
		currentIndex_ = [self.photos count] - 1;
		[scroll scrollRectToVisible:CGRectMake((currentIndex_ + 1) * width, 0, width, scroll.frame.size.height) animated:NO];
	}
	if (index > [self.photos count]) {
		currentIndex_ = 0;
		[scroll scrollRectToVisible:CGRectMake((currentIndex_ + 1) * width, 0, width, scroll.frame.size.height) animated:NO];
	}
    for (int i = 0; i < [self.photos count]; i++) {
        //       if (i < currentIndex_ - 1 || i > currentIndex_ + 1) {
        if (i < currentIndex_ || i > currentIndex_) {
            [self unloadPage:i];
        } else {
            [self loadPage:i];
        }
    }
    int tag = [photos_ count] > 1 ? kImageViewTag + currentIndex_ + 1 : kImageViewTag;
    MGalleryView *containerView = (MGalleryView*)[scroll viewWithTag:tag];
    saveButton.enabled = [containerView imageLoaded];
}

- (NSString*)currentImageUrl {
    MPhoto *photo = [self.photos objectAtIndex:currentIndex_];
    return photo.imageUrl;
}
                      
- (UIImage*)currentImage {
    int tag = [photos_ count] > 1 ? kImageViewTag + currentIndex_ + 1 : kImageViewTag;
    MGalleryView *containerView = (MGalleryView*)[scroll viewWithTag:tag];
    return [containerView image];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
                        change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"imagePath"]) {
        if ([object isKindOfClass:[MPhoto class]]) {
            //[self performSelectorOnMainThread:@selector(imageLoaded:) withObject:object waitUntilDone:NO];
            MPhoto *photo = (MPhoto*)object;	
            int index = [self.photos indexOfObject:photo];
             int tag = [photos_ count] > 1 ? kImageViewTag + index + 1 : kImageViewTag;
            MGalleryView *containerView = (MGalleryView*)[scroll viewWithTag:tag];
            if (photo.imagePath != nil) {
                UIImage *image = [UIImage imageWithContentsOfFile:photo.imagePath];
                [containerView setImage:image];
                if (index == currentIndex_) {
                    saveButton.enabled = YES;
                }
            } 
        }
    }
}

- (void)unload {
 }

- (void)dealloc {
    for (MPhoto *photo in self.photos) {
        [photo removeObserver:self forKeyPath:@"imagePath"];
    }  
    
    [photoViews_ release];
    [photos_ release];
    [scroll release];
     
    [saveButton release];
    [super dealloc];
}

@end

@interface MGalleryView ()

- (void)showActivityIndicator;
- (void)hideActivityIndicator;

@end

@implementation MGalleryView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        CGRect imageFrame = frame;
        imageFrame.origin = CGPointMake(20, 10);
        imageFrame.size.width -= 40;
        imageFrame.size.height -= 20;
        
        imageView = [[UIImageView alloc] initWithFrame:imageFrame];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
 		
        [self addSubview:imageView];
		[imageView release];
        
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.tag = kIndicatorViewTag;
        indicator.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        indicator.layer.shadowColor = [UIColor grayColor].CGColor;
        indicator.layer.shadowRadius = 1;
        indicator.layer.shadowOpacity = 0.5;
        indicator.layer.shadowOffset = CGSizeMake(0, 1);
        indicator.hidesWhenStopped = YES;
        
        [self addSubview:indicator];
        [self bringSubviewToFront:indicator];
        
    }
    return self;
}

- (void)setImage:(UIImage*)image {
	if (image == nil) {
		[self performSelector:@selector(showActivityIndicator)];
	} else {
		[self hideActivityIndicator];
		imageView.image = image;
 	}
}

- (UIImage*)image {
    return imageView.image;
}

- (void)unloadImage {
    imageView.image = nil;
}

- (BOOL)imageLoaded {
	return imageView.image != nil;
}

- (void)setImageFrame:(CGRect)rect {
	imageView.frame = imageView.frame;
}

- (void)showActivityIndicator {
	[indicator startAnimating];
	//NSLog(@"indicator %f %f", indicator.center.x, indicator.center.y);
}

- (void)hideActivityIndicator {
    [indicator stopAnimating];
}

- (void)dealloc {
    [indicator release];
    
    [super dealloc];
}

@end
