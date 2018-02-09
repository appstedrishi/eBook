//
// WKVerticalScrollBar
// http://github.com/litl/WKVerticalScrollBar
//
// Copyright (C) 2012 litl, LLC
// Copyright (C) 2012 WKVerticalScrollBar authors
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
//

#import "WKVerticalScrollBarCustom.h"

#define CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))

@interface WKVerticalScrollBarCustom ()
- (void)commonInit;
@end

@implementation WKVerticalScrollBarCustom

@synthesize handleWidth = _handleWidth;
@synthesize handleHitWidth = _handleHitWidth;
@synthesize handleSelectedWidth = _handleSelectedWidth;

@synthesize handleMinimumHeight = _handleMinimumHeight;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _handleWidth = 3.0f; // 4
    _handleSelectedWidth = 6.0f;
    _handleHitWidth = 14.0f;//44.0f;
    _handleMinimumHeight = 44.0f;
    
    _handleCornerRadius = 0;//_handleWidth / 2;
    _handleSelectedCornerRadius = 0;// _handleSelectedWidth / 2;
    
    handleHitArea = CGRectZero;
    
    normalColor = [UIColor colorWithWhite:0.96f alpha:0.92f];
    selectedColor = [UIColor colorWithWhite:0.96f alpha:1];
        
    background = [[CALayer alloc] init];
    [background setCornerRadius:_handleCornerRadius];
    [background setAnchorPoint:CGPointMake(1.0f, 0.0f)];
    [background setFrame:CGRectMake(0, 0, _handleWidth, 0)];
    [background setBackgroundColor:[[UIColor colorWithWhite:0.4f alpha:0.72f] CGColor]];
    [[self layer] addSublayer:background];
    
    handle = [[CALayer alloc] init];
    [handle setCornerRadius:_handleCornerRadius];
    [handle setAnchorPoint:CGPointMake(1.0f, 0.0f)];
    [handle setFrame:CGRectMake(0, 0, _handleWidth, 0)];
    [handle setBackgroundColor:[normalColor CGColor]];
    [[self layer] addSublayer:handle];
}

- (void)dealloc
{
    
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [_scrollView removeObserver:self forKeyPath:@"contentSize"];
    
    

}

- (void)setEnabled:(BOOL)enabled {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = (enabled) ? 1 : 0;
    }];
    [_scrollView setShowsVerticalScrollIndicator:!enabled];
}

- (BOOL)enabled {
    return self.alpha;
}

- (UIScrollView *)scrollView
{
    return _scrollView;
}

- (void)setScrollView:(UIScrollView *)scrollView;
{
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [_scrollView removeObserver:self forKeyPath:@"contentSize"];

    _scrollView = scrollView;
    
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [_scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    
    [self setNeedsLayout];
}

- (UIView *)handleAccessoryView
{
    return _handleAccessoryView;
}

- (void)setHandleAccessoryView:(UIView *)handleAccessoryView
{
    [_handleAccessoryView removeFromSuperview];
    _handleAccessoryView = handleAccessoryView;
    
    [_handleAccessoryView setAlpha:0.0f];
    [self addSubview:_handleAccessoryView];
    [self setNeedsLayout];
}

- (void)setHandleColor:(UIColor *)color forState:(UIControlState)state
{
    if (state == UIControlStateNormal) {
        normalColor = color;
    } else if (state == UIControlStateSelected) {
        selectedColor = color;
    }
}

- (CGFloat)handleCornerRadius
{
    return _handleCornerRadius;
}

- (void)setHandleCornerRadius:(CGFloat)handleCornerRadius
{
    _handleCornerRadius = handleCornerRadius;
    
    if (!handleDragged) {
        [handle setCornerRadius:_handleCornerRadius];
    }
}

- (CGFloat)handleSelectedCornerRadius
{
    return _handleSelectedCornerRadius;
}

- (void)setHandleSelectedCornerRadius:(CGFloat)handleSelectedCornerRadius
{
    _handleSelectedCornerRadius = handleSelectedCornerRadius;
    
    if (handleDragged) {
        [handle setCornerRadius:_handleSelectedCornerRadius];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    CGFloat contentHeight = [_scrollView contentSize].height;
    CGFloat contentHeight = [_scrollView.superview sizeThatFits:CGSizeZero].height; // HACK to better support webview
    CGFloat frameHeight = [_scrollView frame].size.height;
    
    if (contentHeight - frameHeight == 0) {
        handle.opacity = 0;
        background.opacity = 0;
        return; // prevent divide by 0 below when we arrive here before _scrollView has geometry
    } else {
        handle.opacity = 1;
        background.opacity = 1;
    }

    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    CGRect bounds = [self bounds];
    
    // Calculate the current scroll value (0, 1) inclusive.
    // Note that contentOffset.y only goes from (0, contentHeight - frameHeight)
    CGFloat scrollValue = [_scrollView contentOffset].y / (contentHeight - frameHeight);
    
    // Set handleHeight proportionally to how much content is being currently viewed
    CGFloat handleHeight = CLAMP((frameHeight / contentHeight) * bounds.size.height,
                                 _handleMinimumHeight, bounds.size.height);
    
    [handle setOpacity:(handleHeight == bounds.size.height) ? 0.0f : 1.0f];
    
    // Not only move the handle, but also shift where the position maps on to the handle,
    // so that the handle doesn't go off screen when the scrollValue approaches 1.
//    CGFloat handleY = CLAMP((scrollValue * bounds.size.height) - (scrollValue * handleHeight),
//                            0, bounds.size.height - handleHeight);
    CGFloat handleY = CLAMP((scrollValue * bounds.size.height) - (scrollValue * handleHeight),
                            -handleHeight, bounds.size.height);

    CGFloat previousWidth = [handle bounds].size.width ?: _handleWidth;
    [handle setPosition:CGPointMake(bounds.size.width, handleY)];
    [handle setBounds:CGRectMake(0, 0, previousWidth, handleHeight)];
    
//    [background setFrame:CGRectMake(bounds.size.width, 0, previousWidth, bounds.size.height)];
    [background setPosition:CGPointMake(bounds.size.width, 0)];
    [background setBounds:CGRectMake(0, 0, previousWidth, bounds.size.height)];
    
    // Center the accessory view to the left of the handle
    CGRect accessoryFrame = [_handleAccessoryView frame];
    [_handleAccessoryView setCenter:CGPointMake(bounds.size.width - _handleHitWidth - (accessoryFrame.size.width / 2),
                                                handleY + (handleHeight / 2))];
    
    handleHitArea = CGRectMake(bounds.size.width - _handleHitWidth, handleY,
                               _handleHitWidth, handleHeight);
    
    [CATransaction commit];
}

- (BOOL)handleVisible
{
    return [handle opacity] == 1.0f;
}

- (void)growHandle
{
    if (![self handleVisible] || _handleSelectedWidth <= _handleWidth) {
        [handle setBackgroundColor:[selectedColor CGColor]];
        return;
    }
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.3f];

    [handle setCornerRadius:_handleSelectedCornerRadius];
    [handle setBounds:CGRectMake(0, 0, _handleSelectedWidth, [handle bounds].size.height)];
    [background setBounds:CGRectMake(0, 0, _handleSelectedWidth, [background bounds].size.height)];
    [handle setBackgroundColor:[selectedColor CGColor]];
    
    [CATransaction commit];
    
    [UIView animateWithDuration:0.3f animations:^{
        [_handleAccessoryView setAlpha:1.0f];
    }];
}

- (void)shrinkHandle
{
    if (![self handleVisible] || _handleSelectedWidth <= _handleWidth) {
        [handle setBackgroundColor:[normalColor CGColor]];
        return;
    }
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.3f];
    
    [handle setCornerRadius:_handleCornerRadius];
    [handle setBounds:CGRectMake(0, 0, _handleWidth, [handle bounds].size.height)];
    [background setBounds:CGRectMake(0, 0, _handleWidth, [background bounds].size.height)];
    [handle setBackgroundColor:[normalColor CGColor]];
    
    [CATransaction commit];
    
    [UIView animateWithDuration:0.3f animations:^{
        [_handleAccessoryView setAlpha:0.0f];
    }];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return CGRectContainsPoint(handleHitArea, point);
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (![self handleVisible]) {
        return NO;
    }
    
    CGPoint point = [touch locationInView:self];
    
//    if ([self pointInside:point] == false) {
//        [self scrollToPoint:point];
//    }
//    
    lastTouchPoint = point;

    // When the user initiates a drag, make the handle grow so it's easier to see
    handleDragged = YES;
    [self growHandle];

    [self setNeedsLayout];

    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{    
    CGPoint point = [touch locationInView:self];

    CGSize contentSize = [_scrollView contentSize];
    CGPoint contentOffset = [_scrollView contentOffset];
    CGFloat frameHeight = [_scrollView frame].size.height;
    CGFloat deltaY = ((point.y - lastTouchPoint.y) / [self bounds].size.height)
                     * [_scrollView contentSize].height;
    
    [_scrollView setContentOffset:CGPointMake(contentOffset.x,  CLAMP(contentOffset.y + deltaY,
                                                                      0, contentSize.height - frameHeight))
                         animated:NO];
    lastTouchPoint = point;

    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    lastTouchPoint = CGPointZero;
    
    // When user drag is finished, return handle to previous size
    handleDragged = NO;
    [self shrinkHandle];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object != _scrollView) {
        return;
    }

    [self setNeedsLayout];
}

//- (void)scrollToPoint:(CGPoint)point {
//    
//    CGFloat contentHeight = [_scrollView contentSize].height;
//    CGFloat frameHeight = [_scrollView frame].size.height;
//    CGPoint contentOffset = [_scrollView contentOffset];
//    CGRect bounds = [self bounds];
//    
//    // Calculate the current scroll value (0, 1) inclusive.
//    // Note that contentOffset.y only goes from (0, contentHeight - frameHeight)
//    CGFloat scrollValue = [_scrollView contentOffset].y / (contentHeight - frameHeight);
//    
//    // Set handleHeight proportionally to how much content is being currently viewed
//    CGFloat handleHeight = CLAMP((frameHeight / contentHeight) * bounds.size.height,
//                                 _handleMinimumHeight, bounds.size.height);
//    
//    [handle setOpacity:(handleHeight == bounds.size.height) ? 0.0f : 1.0f];
//    
//    // Not only move the handle, but also shift where the position maps on to the handle,
//    // so that the handle doesn't go off screen when the scrollValue approaches 1.
//    CGFloat handleY = CLAMP((scrollValue * bounds.size.height) - (scrollValue * handleHeight),
//                            0, bounds.size.height - handleHeight);
//    
//    CGFloat deltaY = ((point.y - handleY - handleHeight/2) / [self bounds].size.height)
//    * [_scrollView contentSize].height;
//    
//    [_scrollView setContentOffset:CGPointMake(contentOffset.x,  CLAMP(contentOffset.y + deltaY,
//                                                                      0, contentHeight - frameHeight))
//                         animated:NO];
//    
//}

@end
