
#import "RepeatingBackgroundImageView.h"

@interface RepeatingBackgroundImageView ()

@property (nonatomic, strong) UIImage *backgroundImage;

@end

@implementation RepeatingBackgroundImageView

@synthesize backgroundImage = backgroundImage_;

- (id)initWithFrame:(CGRect)frame andBackgroundImage:(UIImage *)backgroundImage opaque:(BOOL)opaque {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundImage = backgroundImage;
        self.opaque = opaque;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    [self.backgroundImage drawAsPatternInRect:self.bounds];
    [super drawRect:rect];
}

@end
