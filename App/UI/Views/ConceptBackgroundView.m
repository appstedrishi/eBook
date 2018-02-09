#import "ConceptBackgroundView.h"
#import "ConceptViewController.h"
#import "HighlightViewComponent.h"

@implementation ConceptBackgroundView

@synthesize delegate = delegate_;

- (id)init {
    if (self = [super init]) {
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if ([touches count] == 1 && ![[(UITouch *)[touches anyObject] view] conformsToProtocol:@protocol(HighlightViewComponent)]) {
        [self.delegate didTapBackground];
    }
}

//- (void)drawRect:(CGRect)rect
//{
//    [super drawRect:rect];
//    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextSetLineWidth(ctx, 1.0);
//    CGContextSetGrayStrokeColor(ctx, 0.663, 1.0);
//    CGContextMoveToPoint(ctx, 692.5, 0);
//    CGContextAddLineToPoint( ctx, 692.5, 1024.0);
//    CGContextStrokePath(ctx);
//}

@end
