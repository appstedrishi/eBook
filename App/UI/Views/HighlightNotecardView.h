#import <UIKit/UIKit.h>

#import "ContainerView.h"
#import "KTTextView.h"
#import "HighlightViewComponent.h"

@class Highlight, UnfocusedTextLabelView;
@protocol HighlightNotecardViewDelegate;

@interface HighlightNotecardView : ContainerView <HighlightViewComponent, UITextViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) KTTextView *textView;
@property (nonatomic, strong) UIButton *noteIconImageView;
@property (nonatomic, strong) UnfocusedTextLabelView *unfocusedTextLabel;
@property (nonatomic, assign) BOOL isActive;

- (id)initWithHighlight:(Highlight *)highlight
         andOrientation:(UIInterfaceOrientation)orientation
            andDelegate:(id<HighlightNotecardViewDelegate>)delegate;

- (void)didTapUnfocusedTextLabel;
- (void)close;
- (void)show;

@end
