#import <UIKit/UITextView.h>

@implementation UITextView (EdgeInsetsZero)

- (UIEdgeInsets)contentInset {
    return UIEdgeInsetsZero;
}

@end
