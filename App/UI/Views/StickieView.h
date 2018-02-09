#import <UIKit/UIKit.h>
#import "ContainerView.h"
#import "HighlightViewComponent.h"

@class RepeatingBackgroundImageView;

@interface StickieView : ContainerView <HighlightViewComponent> {
    BOOL showDropShadow_;
}

@property (nonatomic, weak) IBOutlet UIButton *flagButton;
@property (nonatomic, weak) IBOutlet UIImageView *portraitModeFlag;
@property (nonatomic, strong) UIImage *flagImage;
@property (nonatomic, strong) RepeatingBackgroundImageView *marginView;
@property (nonatomic, assign) BOOL showDropShadow;
@property (nonatomic, assign) BOOL enabled;

- (id)initWithSuperview:(UIView *)superview orientation:(UIInterfaceOrientation)orientation highlightHeight:(CGFloat)height showDropShadow:(BOOL)showDropShadow;

@end
