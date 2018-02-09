#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "HighlightPaintingView.h"
#import "HighlightPaintingViewDelegate.h"
#import "History.h"
#import "HistoryLocation.h"

@interface HighlightPaintingView ()

@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, weak) id <HighlightPaintingViewDelegate> delegate;
@property (nonatomic, strong) NSTimer *highlightChunkTimer;
@property (nonatomic, assign) CGPoint currentTouchPoint;

- (void)willDrawHighlightChunk;

@end

@implementation HighlightPaintingView

@synthesize points = points_, delegate = delegate_, highlightChunkTimer = highlightChunkTimer_,
currentTouchPoint = currentTouchPoint_;

- (id)initWithFrame:(CGRect)frame andDelegate:(id <HighlightPaintingViewDelegate>)delegate {
    if ((self = [super initWithFrame:frame])) {
        self.delegate = delegate;
        self.opaque = NO;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}


//- (void)drawRect:(CGRect)rect {
//    CGContextRef context = UIGraphicsGetCurrentContext();
//
//    if (0 == [self.points count]) {
//        return;
//    }
//
//    CGContextBeginPath(context);
//    CGContextSetLineWidth(context, 8);
//    CGContextSetAlpha(context, 0.50);
//
//    CGPoint point = [[self.points objectAtIndex:0] CGPointValue];
//    CGContextMoveToPoint(context, point.x, point.y);
//
//    for (unsigned int i = 1; i < [self.points count]; ++i) {
//        CGPoint pt = [[self.points objectAtIndex:i] CGPointValue];
//        CGContextAddLineToPoint(context, pt.x, pt.y);
//    }
//
//    [[UIColor yellowColor] setStroke];
//
//    CGContextDrawPath(context, kCGPathStroke);
//}

- (void)startHighlightAtPoint:(CGPoint)touch {
    self.currentTouchPoint = touch;
    
    [self.points addObject:[NSValue valueWithCGPoint:self.currentTouchPoint]];
    [self setNeedsDisplay];
    
    [self.delegate didBeginHighlightStrokeAtPoint:self.currentTouchPoint];
    
    self.highlightChunkTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(willDrawHighlightChunk) userInfo:nil repeats:YES];
}

- (void)continueHighlightAtPoint:(CGPoint)touch {
//    NSLog(@"continuing highlight!");
    self.currentTouchPoint = touch;
    [self.points addObject:[NSValue valueWithCGPoint:self.currentTouchPoint]];
    [self setNeedsDisplay];
}

- (void)endHighlightAtPoint:(CGPoint)touch {
    if (self.highlightChunkTimer) {
        self.points = nil;
        [self setNeedsDisplay];
        
        [self.delegate didEndHighlightStrokeAtPoint:touch];
        
        [self.highlightChunkTimer invalidate];
        //self.highlightChunkTimer = nil;
    }
}

#pragma mark touch events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.points = [NSMutableArray array];
    UITouch *touch = [[event touchesForView:self] anyObject];
    [self startHighlightAtPoint:[touch locationInView:self]];
//    self.currentTouchPoint = [touch locationInView:self];
//
//    [self.points addObject:[NSValue valueWithCGPoint:self.currentTouchPoint]];
//    [self setNeedsDisplay];
//
//    [self.delegate didBeginHighlightStrokeAtPoint:self.currentTouchPoint];
//
//    self.highlightChunkTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(willDrawHighlightChunk) userInfo:nil repeats:YES];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:self] anyObject];
    [self continueHighlightAtPoint:[touch locationInView:self]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event touchesForView:self] anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    [self endHighlightAtPoint:touchPoint];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

}

#pragma mark Private interface
- (void)willDrawHighlightChunk {
    [self.delegate updateHighlightStrokeAtPoint:self.currentTouchPoint];
}

@end
