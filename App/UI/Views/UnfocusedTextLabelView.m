#import "UnfocusedTextLabelView.h"
#import <QuartzCore/QuartzCore.h>

@implementation UnfocusedTextLabelView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // shadow gives us top border _outside_ our bounds
        UnfocusedTextLabelView *unfocusedTextLabel = (UnfocusedTextLabelView *)self;
        unfocusedTextLabel.layer.shadowColor = [UIColor colorWithWhite:0.67 alpha:1.000].CGColor;
        unfocusedTextLabel.layer.shadowOffset = CGSizeMake(0, -1);
        unfocusedTextLabel.layer.shadowOpacity = 1;
        unfocusedTextLabel.layer.shadowRadius = 0;
        unfocusedTextLabel.layer.masksToBounds = NO;
    }
    return self;
}


- (void)drawTextInRect:(CGRect)rect {
    [[UIImage imageNamed:@"card-lines.png"] drawAsPatternInRect:rect];

    // draw bottom border
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetGrayStrokeColor(ctx, 0.67, 1.0);
    CGContextMoveToPoint(ctx, 0, self.bounds.size.height-0.5f);
    CGContextAddLineToPoint( ctx, self.bounds.size.width, self.bounds.size.height-0.5f);
    CGContextStrokePath(ctx);
    
    CGRect indentedRect = CGRectOffset(CGRectInset(rect, TEXT_INDENT, 0), TEXT_INDENT, 0);
    [super drawTextInRect:indentedRect];
}


@end
