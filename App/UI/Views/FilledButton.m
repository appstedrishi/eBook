//
//  FilledButton.m
//  Halo
//
//  Created by Adam Overholtzer on 4/24/14.
//
//

#import "FilledButton.h"

@interface FilledButton () {
    UIColor *_originalBackgroundColor;
}
@end

@implementation FilledButton

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    _originalBackgroundColor = backgroundColor;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (enabled) {
        [super setBackgroundColor:_originalBackgroundColor];
    } else {
        [super setBackgroundColor:[UIColor colorWithHue:0.568 saturation:0.000 brightness:0.862 alpha:1.000]];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        [super setBackgroundColor:[_originalBackgroundColor colorWithAlphaComponent:0.25]];
    } else {
        [UIView animateWithDuration:0.18 animations:^{
            [super setBackgroundColor:_originalBackgroundColor];
        }];
    }
}

@end
