//
//  UIPopoverController+removeInnerShadow.m
//  Halo
//
//  Created by Adam Overholtzer on 5/23/12.
//  Copyright (c) 2012 SRI International. All rights reserved.
//

#import "UIPopoverController+removeInnerShadow.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIPopoverController (removeInnerShadow)

- (void)presentPopoverWithoutInnerShadowFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)direction animated:(BOOL)animated 
{
    [self presentPopoverFromRect:rect inView:view permittedArrowDirections:direction animated:animated];
    [self removeInnerShadow];
}

- (void)presentPopoverWithoutInnerShadowFromBarButtonItem:(UIBarButtonItem *)item 
                                 permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections 
                                                 animated:(BOOL)animated
{
    [self presentPopoverFromBarButtonItem:item permittedArrowDirections:arrowDirections animated:animated];
    [self removeInnerShadow];
}

- (void)removeInnerShadow {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    for (UIView *windowSubView in window.subviews) {
        if ([NSStringFromClass([windowSubView class]) isEqualToString:@"UIDimmingView"]) {
            for (UIView *dimmingViewSubviews in windowSubView.subviews) {
                for (UIView *popoverSubview in dimmingViewSubviews.subviews) {
                    if([NSStringFromClass([popoverSubview class]) isEqualToString:@"UIView"]) {
                        for (UIView *subviewA in popoverSubview.subviews) {
                            if ([NSStringFromClass([subviewA class]) isEqualToString:@"UILayoutContainerView"]) {
                                subviewA.layer.cornerRadius = 0;
                                subviewA.layer.backgroundColor = [UIColor clearColor].CGColor;
                            }
                            for (UIView *subviewB in subviewA.subviews) {
                                if ([NSStringFromClass([subviewB class]) isEqualToString:@"UIImageView"] ) {
                                    [subviewB removeFromSuperview];
                                } else {
                                    for (UIView *subviewX in subviewB.subviews) {
                                        if ([NSStringFromClass([subviewX class]) isEqualToString:@"UIImageView"] ) {
                                            [subviewX removeFromSuperview];
                                        }
                                    }

                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
}

@end
