#import "StickieView.h"
#import "RepeatingBackgroundImageView.h"

@interface StickieView ()

@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, assign) BOOL active;

- (void)setVisibility;
- (void)setUpPortraitModeMarginView:(CGFloat)height;
- (void)updateFlagImage;

@end
//yellow-flag-portrait-row
NSString * const FLAG_REGULAR = @"yellow-flag-regular.png"; //@"yellow-flag-portrait-row";
NSString * const FLAG_DISABLED = @"yellow-flag-disabled.png";

@implementation StickieView

@synthesize flagButton = flagButton_, portraitModeFlag = portraitModeFlag_, orientation = orientation_, active = active_, showDropShadow = showDropShadow_,
flagImage = flagImage_, marginView = marginView_, enabled = enabled_;

#pragma mark init
- (id)initWithSuperview:(UIView *)superview orientation:(UIInterfaceOrientation)orientation highlightHeight:(CGFloat)height showDropShadow:(BOOL)showDropShadow {
    if ((self = [[[NSBundle mainBundle] loadNibNamed:@"StickieView" owner:superview options:nil] lastObject])) {
        self.orientation = orientation;

        self.flagImage = [UIImage imageNamed:FLAG_REGULAR];
        self.showDropShadow = showDropShadow;

        [self setUpPortraitModeMarginView:height];
        [self setVisibility];
    }
    return self;
}


- (void)setShowDropShadow:(BOOL)showDropShadow {
    showDropShadow_ = showDropShadow;
    [self refresh];
}

#pragma mark HighlightViewComponent
- (void)activate {
    self.active = YES;
    [self setVisibility];
}

- (void)deactivate {
    self.active = NO;
    [self setVisibility];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toOrientation {
    self.orientation = toOrientation;
    [self setVisibility];
}

- (BOOL)hasVisibleCard {
    return NO;
}

- (void)refresh {
    [self updateFlagImage];

//    UIImage *image = self.showDropShadow ? self.flagImageWithDropShadow : self.flagImageWithoutDropShadow;
//    [self.flagButton setImage:image forState:UIControlStateNormal];
    [self.flagButton setImage:self.flagImage forState:UIControlStateNormal];
}

#pragma mark Private interface
- (void)setVisibility {
   
    self.flagButton.alpha = !self.active && UIInterfaceOrientationIsLandscape(self.orientation) ? 1 : 1;
    self.portraitModeFlag.alpha = self.marginView.alpha = self.active && UIInterfaceOrientationIsPortrait(self.orientation) ? 1 : 0;
    if (self.portraitModeFlag.alpha==0) {
        [self.flagButton setHidden:NO];
    }
    else
    {
         [self.flagButton setHidden:YES];
    
    }
    [ self.flagButton setFrame:UIInterfaceOrientationIsPortrait(self.orientation) ? [self flagButtonSize:@"portrait"] :[self flagButtonSize:@"landscape"] ];
}

- (void)setUpPortraitModeMarginView:(CGFloat)height {
    CGFloat imgHeight = 0;
    
    if (height > self.portraitModeFlag.frame.size.height + 5) {
        imgHeight = height - self.portraitModeFlag.frame.size.height;
    }

    CGRect frame = CGRectMake(self.portraitModeFlag.frame.origin.x, self.portraitModeFlag.frame.origin.y + self.portraitModeFlag.frame.size.height, self.portraitModeFlag.frame.size.width, imgHeight);

    UIImage *img = [UIImage imageNamed:@"yellow-flag-portrait-row.png"];

    self.marginView = [[RepeatingBackgroundImageView alloc] initWithFrame:frame andBackgroundImage:img opaque:NO];
    [self addSubview:self.marginView];
}

- (void)setEnabled:(BOOL)enable {
	enabled_ = enable;
	self.flagButton.enabled = enable;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateFlagImage];
}

- (void)updateFlagImage {
    if (self.frame.origin.x != 0) {
		// used "stacked" image for stickies that aren't leftmost
        self.flagImage = [UIImage imageNamed:FLAG_REGULAR];
		[self.flagButton setImage:[UIImage imageNamed:FLAG_DISABLED] forState:UIControlStateDisabled];
//		[self.flagButton setImage:[UIImage imageNamed:@"yellow-flag-stacked-pushed.png"] forState:UIControlStateHighlighted];
    } else {
		// otherwise use default images
        self.flagImage = [UIImage imageNamed:FLAG_REGULAR];
		[self.flagButton setImage:[UIImage imageNamed:FLAG_DISABLED] forState:UIControlStateDisabled];
//		[self.flagButton setImage:[UIImage imageNamed:@"yellow-flag-pushed.png"] forState:UIControlStateHighlighted];
    }
}
-(CGRect)flagButtonSize:(NSString *)strVal
{
    if ([strVal isEqualToString:@"portrait"]) {
        CGRect frame = CGRectMake(self.portraitModeFlag.frame.origin.x-10, self.portraitModeFlag.frame.origin.y+1, self.portraitModeFlag.frame.size.width, self.portraitModeFlag.frame.size.height);
        return frame;
    }
    else{
        CGRect frame = CGRectMake(0, 0, self.flagButton.frame.size.width, self.flagButton.frame.size.height);
        return frame;
        
    }
    
}
@end
