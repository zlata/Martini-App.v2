//
//  MFontLabel.m
//  martini
//
//  Created by zlata samarskaya on 07.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "MFontLabel.h"
#import "MModel.h"

#import "MUser.h"

@implementation MFontLabel

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder: aDecoder])) {
        float s = self.font.pointSize;
        [self setFont:[UIFont fontWithName:@"MartiniPro-Regular" size:s]];
    }
    return self;

}

@end

@implementation MBoldFontLabel

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder: aDecoder])) {
        float s = self.font.pointSize;
        [self setFont:[UIFont fontWithName:@"MartiniPro-Bold" size:s]];
    }
    return self;
    
}

@end

@implementation MFontButton

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder: aDecoder])) {
        float s = self.titleLabel.font.pointSize;
        [self.titleLabel setFont:[UIFont fontWithName:@"MartiniPro-Regular" size:s]];
    }
    return self;    
}

@end

@implementation MBorderedTextField

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder: aDecoder])) {
        float s = self.font.pointSize;
        [self setFont:[UIFont fontWithName:@"MartiniPro-Regular" size:s]];
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 1;
        UIView *l = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, self.frame.size.height)];
        self.leftView = l;
        [l release];
    }
    return self;    
}

@end

@implementation MBorderedTextView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder: aDecoder])) {
        float s = self.font.pointSize;
        [self setFont:[UIFont fontWithName:@"MartiniPro-Regular" size:s]];
        self.layer.borderColor = redTextColor.CGColor;
        self.layer.borderWidth = 1;
    }
    return self;    
}

@end

@implementation MRedView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder: aDecoder])) {
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1;
        self.backgroundColor = redTextColor;
    }
    return self;    
}

@end

@implementation MBaseCell

@synthesize model = model_;

+ (id)viewFromNib {
    NSArray *niblets = [[NSBundle mainBundle] loadNibNamed:[self nibName]
                                                     owner:self
                                                   options:nil];
    
    for (id niblet in niblets) {
        if ([niblet isKindOfClass:[UITableViewCell class]]) {
            UITableViewCell *cell = [[niblet retain] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            return cell;
        }
    }
    
    return nil;
    
}

+ (NSString*)nibName {
    return nil;
}

- (void)loadModel:(MModel*)model {
    NSString *str = subtitle.text;
    CGSize size = CGSizeMake(subtitle.frame.size.width, 1000);
    CGSize s = [str sizeWithFont:subtitle.font constrainedToSize:size 
                   lineBreakMode:UILineBreakModeWordWrap];
    
    if (s.height < subtitle.frame.size.height) {
        CGRect rect = subtitle.frame;
        rect.size.height = s.height;
        subtitle.frame = rect;
    }
    self.model = model;
    if ([self.model isKindOfClass:[MImagedModel class]]) {
        if(((MImagedModel*)model).imagePath == nil) {
            imgView.image = [UIImage imageNamed:@"icon.png"];
        }
        [self.model addObserver:self forKeyPath:@"imagePath" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)dealloc {
    if ([self.model isKindOfClass:[MImagedModel class]]) {
        [self.model removeObserver:self forKeyPath:@"imagePath"];
    }
    [imgView release];
    [title release];
    [subtitle release];
    [model_ release];
    
    [super dealloc];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    if ([self.model isKindOfClass:[MImagedModel class]]) {
        [self.model removeObserver:self forKeyPath:@"imagePath"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
                      ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"imagePath"]) {
        UIImage *img = [UIImage imageWithContentsOfFile:((MImagedModel*)self.model).imagePath];
        if (img != nil) {
            imgView.image = img;
        }
    }
}

@end

@implementation MapAnnotation

@synthesize coordinate;
@synthesize subtitle;
@synthesize title;
@synthesize user = user_;

- (id)initWithUser:(MUser *)user {
	if ((self = [super init])) {
        self.user = user;
		title = [user.name retain];
		subtitle = [user.surname retain];
		self.coordinate = CLLocationCoordinate2DMake(user.lat, user.lon);
	}
	return self;
}

- (id)initWithEvent:(MEvent *)event {
	if ((self = [super init])) {
     //   self.user = user;
		title = [event.title retain];
		subtitle = [event.desc retain];
		self.coordinate = CLLocationCoordinate2DMake(event.lat, event.lon);
	}
	return self;
}

- (void) dealloc {
	[subtitle release];
	[title release];
	
	[super dealloc];
}

@end

@implementation WarningView
@synthesize warning;

+ (NSString*)nibName {
    return @"WarningView";
}

- (void)dealloc {
    [warning release];
    [super dealloc];
}

+ (id)viewFromNib {
    NSArray *niblets = [[NSBundle mainBundle] loadNibNamed:[self nibName]
                                                     owner:self
                                                   options:nil];
    
    for (id niblet in niblets) {
        if ([niblet isKindOfClass:[UIView class]]) {
            
            return [[niblet retain] autorelease];
        }
    }
    
    return nil;
    
}

@end
