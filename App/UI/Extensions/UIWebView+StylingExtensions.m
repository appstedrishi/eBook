#import "UIWebView+StylingExtensions.h"

@implementation UIWebView (StylingExtensions)

- (void)removeBackgroundDropShadow {
    if ([self.subviews count]) {
        for (UIView *subview in [[self.subviews objectAtIndex:0] subviews]) {
            if ([subview isKindOfClass:[UIImageView class]])  {
                subview.hidden = YES;
            }
        }
    }
}

@end
