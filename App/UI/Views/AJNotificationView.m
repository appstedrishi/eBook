//
//  AJNotificationView.m
//  AJNotificationViewDemo
//
//  Created by Alberto Jerez on 02/08/12.
//  Copyright (c) 2012 CodeApps. All rights reserved.
//
//Copyright © 2012 Alberto Jerez - CodeApps
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”),
//to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//IN THE SOFTWARE.


#import "AJNotificationView.h"
#import <QuartzCore/QuartzCore.h>

@interface AJNotificationView ()

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic) AJNotificationType notificationType;
@property (nonatomic) AJLinedBackgroundType backgroundType;
@property (nonatomic,weak) NSTimer* animationTimer;
@property (nonatomic, assign) float moveFactor;
@property(nonatomic,assign) BOOL linedBackground;

- (void)_drawBackgroundInRect:(CGRect)rect;

@end

@implementation AJNotificationView

@synthesize titleLabel = _titleLabel, notificationType = _notificationType, backgroundType = _backgroundType, animationTimer = _animationTimer, moveFactor = _moveFactor, linedBackground = _linedBackground;

////////////////////////////////////////////////////////////////////////
#pragma mark - View LifeCycle
////////////////////////////////////////////////////////////////////////

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0.0f;
        _notificationType = AJNotificationTypeDefault;
        _linedBackground = YES;
        self.animationTimer = nil;

        //Title Label
//        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(36, self.bounds.size.height-PANELHEIGHT, 620, PANELHEIGHT)];
                                                                //self.bounds.size.width - (36*2), PANELHEIGHT)];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - 620/2, self.bounds.size.height-PANELHEIGHT, 620, PANELHEIGHT)];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _titleLabel.textColor = [UIColor colorWithHue:0.620 saturation:0.228 brightness:0.310 alpha:1.000];
        _titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
//        _titleLabel.lineBreakMode = UILineBreakModeWordWrap;
//        _titleLabel.numberOfLines = 0;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.numberOfLines = 2;
        [self addSubview:_titleLabel];
        
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"textbook-background.png"]];
//        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
//        _titleLabel.textColor = [UIColor whiteColor];
//        self.layer.cornerRadius = 4;
        
        self.layer.shadowColor = [UIColor grayColor].CGColor; //[UIColor colorWithPatternImage:[UIImage imageNamed:@"textbook-background.png"]].CGColor;
        self.layer.shadowOpacity = 0.8f;
        self.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        self.layer.shadowRadius = 1.0f;
    }
    return self;
}

//- (void)drawRect:(CGRect)rect
//{
//    [super drawRect:rect];
//    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextSetLineWidth(ctx, 1.0);
//    CGContextSetRGBStrokeColor(ctx, 0.239, 0.259, 0.310, 1);
//    CGContextMoveToPoint(ctx, 0, self.bounds.size.height-1);
//    CGContextAddLineToPoint( ctx, self.bounds.size.width, self.bounds.size.height-1);
////    CGContextAddLineToPoint( ctx, self.bounds.size.width, 0);
//    CGContextStrokePath(ctx);
//    
////    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
////    [self _drawBackgroundInRect:(CGRect)rect];
//}

////////////////////////////////////////////////////////////////////////
#pragma mark - Show
////////////////////////////////////////////////////////////////////////


+ (AJNotificationView *)showNoticeInView:(UIView *)view title:(NSString *)title top:(CGFloat)top hideAfter:(NSTimeInterval)hideInterval{
    
//    AJNotificationView *noticeView = [[self alloc] initWithFrame:CGRectMake(4, top + 4, view.bounds.size.width - 4*2, PANELHEIGHT)];
    AJNotificationView *noticeView = [[self alloc] initWithFrame:CGRectMake(0, top - 500, view.bounds.size.width, PANELHEIGHT + 500)];
    noticeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    noticeView.notificationType = AJLinedBackgroundTypeStatic;
    noticeView.titleLabel.text = title;
    noticeView.linedBackground = NO;
    noticeView.alpha = 1.0;
    [view addSubview:noticeView];
    
    [noticeView setNeedsDisplay];
    if (hideInterval > 0) [noticeView performSelector:@selector(hide) withObject:view afterDelay:hideInterval];
    
    return noticeView;
}



+ (AJNotificationView *)showNoticeInView:(UIView *)view title:(NSString *)title{
    //Use default notification type (gray)
    return [self showNoticeInView:view type:AJNotificationTypeDefault title:title hideAfter:2.5f];
}

+ (AJNotificationView *)showNoticeInView:(UIView *)view title:(NSString *)title hideAfter:(NSTimeInterval)hideInterval{
    //Use default notification type (gray)
    return [self showNoticeInView:view type:AJNotificationTypeDefault title:title hideAfter:hideInterval];
}

+ (AJNotificationView *)showNoticeInView:(UIView *)view type:(AJNotificationType)type title:(NSString *)title hideAfter:(NSTimeInterval)hideInterval{
    return [self showNoticeInView:view type:type title:title linedBackground:AJLinedBackgroundTypeStatic hideAfter:hideInterval];
}

+ (AJNotificationView *)showNoticeInView:(UIView *)view type:(AJNotificationType)type title:(NSString *)title linedBackground:(AJLinedBackgroundType)backgroundType hideAfter:(NSTimeInterval)hideInterval{
    
    AJNotificationView *noticeView = [[self alloc] initWithFrame:CGRectMake(0, -60, view.bounds.size.width, PANELHEIGHT)];
    noticeView.notificationType = type;
    noticeView.titleLabel.text = title;
    noticeView.linedBackground = backgroundType == AJLinedBackgroundTypeDisabled ? NO : YES;
    [view addSubview:noticeView];
    
    [noticeView setNeedsDisplay];
    
    BOOL animated = backgroundType == AJLinedBackgroundTypeAnimated ? YES : NO;
    
    if (animated){
        if (nil == noticeView.animationTimer)
        {
            noticeView.animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30
                                                                   target:noticeView
                                                                 selector:@selector(setNeedsDisplay)
                                                                 userInfo:nil
                                                                  repeats:YES];
        }
    }
    else{
        if (noticeView.animationTimer && noticeView.animationTimer.isValid)
            [noticeView.animationTimer invalidate];
        
        noticeView.animationTimer = nil;
    }
    
    //if view is a UIWindow, check if the status bar is showing (and offset the view accordingly)
    float statusBarOffset = [view isKindOfClass:[UIWindow class]] && [[UIApplication sharedApplication] isStatusBarHidden] ? 0.0 : [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    if ([view isKindOfClass:[UIView class]] && ![view isKindOfClass:[UIWindow class]])
        statusBarOffset = 0.0;
    
    // hack
    noticeView.frame = CGRectMake(0.0,
                                  0.0 + statusBarOffset,
                                  noticeView.frame.size.width,
                                  noticeView.frame.size.height);
    noticeView.alpha = 1.0;
    
    //Animation
//    [UIView animateWithDuration:0.1f
//                          delay:0.0
//                        options:UIViewAnimationOptionCurveEaseOut
//                     animations:^{
//                         noticeView.alpha = 1.0;
//                         noticeView.frame = CGRectMake(0.0,
//                                                       0.0 + statusBarOffset,
//                                                       noticeView.frame.size.width,
//                                                       noticeView.frame.size.height);
//                     }
//                     completion:^(BOOL finished) {
//                         if (finished){
//                             //Hide
//                             if (hideInterval > 0)
//                                 [noticeView performSelector:@selector(hide) withObject:view afterDelay:hideInterval];
//                         }
//                     }];
    
    return noticeView;
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Hide
////////////////////////////////////////////////////////////////////////

- (void)hide{
    [UIView animateWithDuration:0.3f
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.alpha = 0.0;
                         self.layer.shadowOpacity = 0;
//                         self.frame = CGRectMake(0.0,
//                                                 -self.frame.size.height,
//                                                 self.frame.size.width,
//                                                 self.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished){
                             [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.1f];
                         }
                     }];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Touch events
////////////////////////////////////////////////////////////////////////

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self hide];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - Private
////////////////////////////////////////////////////////////////////////

- (void)_drawBackgroundInRect:(CGRect)rect{
    
    self.moveFactor = self.moveFactor > 14.0f ? 0.0f : ++self.moveFactor;

    UIColor *firstColor = nil;
    UIColor *secondColor = nil;
    UIColor *toplineColor = nil;
    
    switch (self.notificationType) {
        case AJNotificationTypeDefault: { //Gray
            firstColor = RGBA(210, 210, 210, 1.0);
            secondColor = RGBA(180, 180, 180, 1.0);
            toplineColor = RGBA(230, 230, 230, 1.0);
            break;
        }
        case AJNotificationTypeBlue: { //Blue
            firstColor = RGBA(0, 193, 254, 1.0);
            secondColor = RGBA(0, 129, 182, 1.0);
            toplineColor = RGBA(20, 230, 255, 1.0);
            self.titleLabel.textColor = [UIColor whiteColor];
            break;
        }
        case AJNotificationTypeGreen: { //Green
            firstColor = RGBA(147, 207, 11, 1.0);
            secondColor = RGBA(99, 168, 1, 1.0);
            toplineColor = RGBA(167, 227, 31, 1.0);
            self.titleLabel.textColor = [UIColor whiteColor];
            break;
        }
        case AJNotificationTypeRed: { //Red
            firstColor = RGBA(204, 53, 60, 1.0);
            secondColor = RGBA(149, 30, 42, 1.0);
            toplineColor = RGBA(224, 73, 80, 1.0);
            self.titleLabel.textColor = [UIColor whiteColor];
            break;
        }
        case AJNotificationTypeOrange: { //Orange
            firstColor = RGBA(246, 141, 0, 1.0);
            secondColor = RGBA(232, 90, 6, 1.0);
            toplineColor = RGBA(266, 161, 20, 1.0);
            self.titleLabel.textColor = [UIColor whiteColor];
            break;
        }
        default: { //Gray
            firstColor = RGBA(210, 210, 210, 1.0);
            secondColor = RGBA(180, 180, 180, 1.0);
            toplineColor = RGBA(230, 230, 230, 1.0);
            break;
        }
    }
    
    //gradient
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    NSArray *colors = [NSArray arrayWithObjects:(id)firstColor.CGColor, (id)secondColor.CGColor, nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
    CGPoint startPoint1 = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint1 = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGContextSaveGState(ctx);
    CGContextAddRect(ctx, rect);
    CGContextClip(ctx);
    CGContextDrawLinearGradient(ctx, gradient, startPoint1, endPoint1, 0);
    CGContextRestoreGState(ctx);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    //top line
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    if ([toplineColor respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [toplineColor getRed:&red green:&green blue:&blue alpha:&alpha];
    } else {
        const CGFloat *components = CGColorGetComponents(toplineColor.CGColor);
        red = components[0];
        green = components[1];
        blue = components[2];
        alpha = components[3];
    }    
    CGContextSaveGState(ctx);
    CGContextSetRGBFillColor(ctx, 0.9f, 0.9f, 0.9f, 1.0f);
    CGContextFillRect(ctx, CGRectMake(0, 0, self.bounds.size.width, 1));
    CGContextSetLineWidth(ctx, 1.5f);
    CGContextSetRGBStrokeColor(ctx, red, green, blue, alpha);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, rect.size.width, 0);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    //bottom line
    CGContextSaveGState(ctx);
    CGContextSetRGBFillColor(ctx, 0.1f, 0.1f, 0.1f, 1.0f);
    CGContextFillRect(ctx, CGRectMake(0, PANELHEIGHT, self.bounds.size.width, 1));
    CGContextSetLineWidth(ctx, 1.5f);
    CGContextSetRGBStrokeColor(ctx, 0.4f, 0.4f, 0.4f, 1.0f);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, 0, PANELHEIGHT);
    CGContextAddLineToPoint(ctx, rect.size.width, PANELHEIGHT);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    //shadow
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.5f;
    self.layer.shadowOffset = CGSizeMake(0.0, 2.0);
    self.layer.shadowRadius = 2.0f;
    
    
    if (self.linedBackground){
        //Lines
        CGContextSaveGState(ctx); 
        CGContextClipToRect(ctx, self.bounds);
        CGMutablePathRef path = CGPathCreateMutable();
        int lines = (self.bounds.size.width/16.0f + self.bounds.size.height);
        for(int i=1; i<=lines; i++) {
            CGPathMoveToPoint(path, NULL, 16.0f * i + -self.moveFactor, 1.0f);
            CGPathAddLineToPoint(path, NULL, 1.0f, 16.0f * i + -self.moveFactor);
        }
        CGContextAddPath(ctx, path);
        CGPathRelease(path);
        CGContextSetLineWidth(ctx, 6.0f);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:0.1].CGColor);
        CGContextDrawPath(ctx, kCGPathStroke);
        CGContextRestoreGState(ctx);
    }
    
}
/*
 
 */
@end
