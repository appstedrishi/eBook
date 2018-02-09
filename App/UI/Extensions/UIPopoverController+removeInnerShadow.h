//
//  UIPopoverController+removeInnerShadow.h
//  Halo
//
//  Created by Adam Overholtzer on 5/23/12.
//  Copyright (c) 2012 SRI International. All rights reserved.
//

#import <UIKit/UIKit.h>

//Remove the inner shadow that UIPopoverController creates
@interface UIPopoverController(removeInnerShadow)

- (void)removeInnerShadow;
- (void)presentPopoverWithoutInnerShadowFromRect:(CGRect)rect 
                                          inView:(UIView *)view 
                        permittedArrowDirections:(UIPopoverArrowDirection)direction 
                                        animated:(BOOL)animated;

- (void)presentPopoverWithoutInnerShadowFromBarButtonItem:(UIBarButtonItem *)item 
                                 permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections 
                                                 animated:(BOOL)animated;

@end
