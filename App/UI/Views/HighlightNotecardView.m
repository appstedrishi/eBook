#import "HighlightNotecardView.h"
#import "HighlightNotecardViewDelegate.h"
#import "Highlight.h"
#import "HighlightView.h"
#import "RepeatingBackgroundImageView.h"
#import "UnfocusedTextLabelView.h"
#import <QuartzCore/QuartzCore.h>

extern const CGFloat HIGHLIGHT_TOOLBAR_HEIGHT;

const CGFloat TEXT_VIEW_TOP_MARGIN = 4;

extern const CGFloat HIGHLIGHT_FOCUSED_CARD_FRAME_ORIGIN_X;
extern const CGFloat HIGHLIGHT_FOCUSED_CARD_CONTENT_ORIGIN_X;
extern const CGFloat HIGHLIGHT_FOCUSED_CARD_CONTENT_ORIGIN_Y;
extern const CGFloat HIGHLIGHT_FOCUSED_CARD_FRAME_ORIGIN_Y_OFFSET;
extern const CGFloat HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_WIDTH;
extern const CGFloat HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_HEIGHT;

static const CGFloat TEXT_VIEW_UNFOCUSED_ORIGIN_X = 28;
static const CGFloat TEXT_VIEW_UNFOCUSED_ORIGIN_Y = -2;
static const CGFloat TEXT_VIEW_UNFOCUSED_SIZE_WIDTH = 288;
static const CGFloat TEXT_VIEW_UNFOCUSED_MAX_HEIGHT = 203;

static const CGFloat NOTE_ICON_ORIGIN_X = 284 - 5;
static const CGFloat NOTE_ICON_ORIGIN_Y = 1;
static const CGFloat NOTE_ICON_SIZE = 22;

@interface HighlightNotecardView ()

@property (nonatomic, weak) id<HighlightNotecardViewDelegate> delegate;
@property (nonatomic, strong) Highlight *highlight;
@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, assign) BOOL isShown;
@property (nonatomic, strong) UIImageView *backgroundShadowView;
@property (nonatomic, strong) UIImageView *topFadeImage, *bottomFadeImage;
@property (nonatomic, strong) UIImage *lineImage;
@property (nonatomic, strong) RepeatingBackgroundImageView *linedView;

- (void)setOriginForCurrentOrientation;
- (void)setNoteIconOriginForCurrentOrientation;
- (void)addNoteIconImageView;
- (void)addUnfocusedTextLabel;
- (void)addTextView;
- (void)addLinedViewToTextView;
- (CGRect)linedViewFrame;
- (CGRect)unfocusedTextLabelFrame;
- (CGRect)textViewFrame;
- (void)setVisibility;
- (void)updateUnfocusedTextLabel;

@end


@implementation HighlightNotecardView

@synthesize
delegate = delegate_,
highlight = highlight_,
isShown = isShown_,
isActive = isActive_,
noteIconImageView = noteIconImageView_,
orientation = orientation_,
textView = textView_,
lineImage = lineImage_,
linedView = linedView_,
topFadeImage = topFadeImage_,
bottomFadeImage = bottomFadeImage_,
backgroundShadowView = backgroundShadowView_,
unfocusedTextLabel = unfocusedTextLabel_;

#pragma mark init

- (id)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithFrame:(CGRect)frame {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithHighlight:(Highlight *)highlight
         andOrientation:(UIInterfaceOrientation)orientation
            andDelegate:(id<HighlightNotecardViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        self.highlight = highlight;
        self.delegate = delegate;

        self.orientation = orientation;
        self.isActive = NO;
		
		self.backgroundShadowView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"note-card-focused-shadow.png"]];
		self.backgroundShadowView.frame = CGRectMake(-2, HIGHLIGHT_FOCUSED_CARD_CONTENT_ORIGIN_Y-2, 336, 260);
		if (UIInterfaceOrientationIsPortrait(self.orientation)) {
			self.backgroundShadowView.image = [UIImage imageNamed:@"note-card-BIG-focused-shadow.png"];
		}
		self.backgroundShadowView.contentMode = UIViewContentModeTopLeft;
		[self addSubview: self.backgroundShadowView];
		
        [self.highlight addObserver:self forKeyPath:@"notecardText" options:0 context:NULL];
        [self setOriginForCurrentOrientation];
        [self addUnfocusedTextLabel];
        [self addNoteIconImageView];
        [self addTextView];
        [self setVisibility];
    }
    return self;
}

- (void)dealloc {
    [self.highlight removeObserver:self forKeyPath:@"notecardText"];
	self.backgroundShadowView = nil;
	self.topFadeImage = nil;
	self.bottomFadeImage = nil;
}

- (void)didTapUnfocusedTextLabel {
    [self.delegate activateHighlight];
}

- (void)close {
    self.isShown = NO;
    [self.textView resignFirstResponder];
    [self setVisibility];
	[self.textView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void)show {
    self.isShown = YES;
    [self setVisibility];
}

- (BOOL)canBecomeFirstResponder {
    return [self.textView canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder {
    return [self.textView becomeFirstResponder];
}

- (BOOL)canResignFirstResponder {
    return [self.textView canResignFirstResponder];
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    return [self.textView resignFirstResponder];
}

#pragma mark HighlightViewComponent
- (void)activate {
    self.isActive = YES;
    [self setVisibility];
}

- (void)deactivate {
    self.isActive = NO;
    [self close];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toOrientation {
    self.orientation = toOrientation;
    [self setOriginForCurrentOrientation];
	[self setNoteIconOriginForCurrentOrientation];
	
	if (UIInterfaceOrientationIsLandscape(self.orientation)) {
		self.backgroundShadowView.image = [UIImage imageNamed:@"note-card-focused-shadow.png"];
	} else {
		self.backgroundShadowView.image = [UIImage imageNamed:@"note-card-BIG-focused-shadow.png"];
	}
	
    [self setVisibility];
}

- (BOOL)hasVisibleCard {
    return self.isActive || (UIInterfaceOrientationIsLandscape(self.orientation) && self.highlight.notecardText.length && ![self.delegate hasSiblingHighlights]);
}

- (void)refresh {
	[self setOriginForCurrentOrientation];
	[self setNoteIconOriginForCurrentOrientation];
    [self setVisibility];
}

#pragma mark UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self.delegate textViewDidBeginEditing:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self.delegate textViewDidEndEditing:textView];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.linedView.frame = [self linedViewFrame];
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([@"notecardText" isEqualToString:keyPath]) {
        self.textView.text = self.highlight.notecardText;
        [self updateUnfocusedTextLabel];
    }
}

#pragma mark Private
- (void)setOriginForCurrentOrientation {
    CGFloat y = UIInterfaceOrientationIsPortrait(self.orientation) ? self.highlight.height+HIGHLIGHT_FOCUSED_CARD_FRAME_ORIGIN_Y_OFFSET : 0;
    self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
}

- (void)setNoteIconOriginForCurrentOrientation {
	if (UIInterfaceOrientationIsPortrait(self.orientation)) {
		self.noteIconImageView.frame = CGRectMake(NOTE_ICON_ORIGIN_X + [self.delegate stickieViewHorizontalOffsetWithIncrement:7 andOnlyCountNotes:YES], 
												  -self.highlight.height + NOTE_ICON_ORIGIN_Y - HIGHLIGHT_FOCUSED_CARD_FRAME_ORIGIN_Y_OFFSET, 
												  self.noteIconImageView.frame.size.width, self.noteIconImageView.frame.size.height);
	} else {
		self.noteIconImageView.frame = CGRectMake(TEXT_VIEW_UNFOCUSED_ORIGIN_X + [self.delegate stickieViewHorizontalOffsetWithIncrement:STACK_INCREMENT andOnlyCountNotes:NO] - 9,
												  NOTE_ICON_ORIGIN_Y+1, 
												  self.noteIconImageView.frame.size.width, self.noteIconImageView.frame.size.height);
	}	
}	

- (void)addNoteIconImageView {
	self.noteIconImageView = [UIButton buttonWithType:UIButtonTypeCustom];
	self.noteIconImageView.frame = CGRectMake(0, 0, NOTE_ICON_SIZE, NOTE_ICON_SIZE);
	[self.noteIconImageView setImage:[UIImage imageNamed:@"note-icon.png"] forState:UIControlStateNormal];
	[self.noteIconImageView addTarget:self action:@selector(didTapUnfocusedTextLabel) forControlEvents:UIControlEventTouchUpInside];
    [self.noteIconImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapUnfocusedTextLabel)]];
    [self addSubview:self.noteIconImageView];
}

- (void)addTextView {
    self.textView = [[KTTextView alloc] initWithFrame:CGRectZero];
    self.textView.delegate = self;
    self.textView.font = [UIFont fontWithName:@"Helvetica" size:17];
    self.textView.text = self.highlight.notecardText;
	self.textView.placeholderText = @"Tap here to write a note.";
    self.textView.frame = [self textViewFrame];
//	self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, -2);
    self.textView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.textView];
	
	self.textView.contentInset = UIEdgeInsetsZero;
	self.textView.placeholderInset = CGPointMake(10.0, -TEXT_VIEW_TOP_MARGIN);
	((UIView *)[self.textView.subviews objectAtIndex:0]).frame = CGRectMake(8, -TEXT_VIEW_TOP_MARGIN,
																			HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_WIDTH - 12.0,
																			HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_HEIGHT+TEXT_VIEW_TOP_MARGIN);

    [self addLinedViewToTextView];
}

- (void)addLinedViewToTextView {
    self.lineImage = [UIImage imageNamed:@"card-lines.png"];
    self.linedView = [[RepeatingBackgroundImageView alloc] initWithFrame:[self linedViewFrame] andBackgroundImage:self.lineImage opaque:YES];
    self.linedView.userInteractionEnabled = NO;
    [self.textView insertSubview:self.linedView atIndex:0];
	
	self.topFadeImage = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"sticky-notecard-fade-top.png"]];
	self.topFadeImage.frame = CGRectMake(HIGHLIGHT_FOCUSED_CARD_CONTENT_ORIGIN_X+1, HIGHLIGHT_FOCUSED_CARD_CONTENT_ORIGIN_Y, HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_WIDTH, 5);
	[self addSubview:self.topFadeImage];
	self.bottomFadeImage = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"sticky-notecard-fade-bottom.png"]];
	self.bottomFadeImage.frame = CGRectMake(HIGHLIGHT_FOCUSED_CARD_CONTENT_ORIGIN_X+1, HIGHLIGHT_FOCUSED_CARD_CONTENT_ORIGIN_Y+HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_HEIGHT-4, HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_WIDTH, 4);
	[self addSubview:self.bottomFadeImage];
}

- (void)addUnfocusedTextLabel {
    self.unfocusedTextLabel = [[UnfocusedTextLabelView alloc] initWithFrame:[self unfocusedTextLabelFrame]];
    [self.unfocusedTextLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapUnfocusedTextLabel)]];
    self.unfocusedTextLabel.userInteractionEnabled = YES;
    self.unfocusedTextLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    self.unfocusedTextLabel.numberOfLines = 10;
    self.unfocusedTextLabel.lineBreakMode = NSLineBreakByWordWrapping;

    [self updateUnfocusedTextLabel];
    [self addSubview:self.unfocusedTextLabel];
}

- (void)updateUnfocusedTextLabel {
    self.unfocusedTextLabel.text = self.highlight.notecardText;
    self.unfocusedTextLabel.frame = [self unfocusedTextLabelFrame];
}

- (CGRect)textViewFrame {
	return CGRectMake(HIGHLIGHT_FOCUSED_CARD_CONTENT_ORIGIN_X+1,
					  HIGHLIGHT_FOCUSED_CARD_CONTENT_ORIGIN_Y,
					  HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_WIDTH-3 -1,
					  HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_HEIGHT);
}

- (CGRect)unfocusedTextLabelFrame {
    
    
 //CGFloat height = [self.highlight.notecardText sizeWithFont:self.unfocusedTextLabel.font constrainedToSize:CGSizeMake(TEXT_VIEW_UNFOCUSED_SIZE_WIDTH-3-TEXT_INDENT*2, TEXT_VIEW_UNFOCUSED_MAX_HEIGHT) lineBreakMode:NSLineBreakByWordWrapping].height;
    
    
   
    
    CGRect textRect = [self.highlight.notecardText boundingRectWithSize:CGSizeMake(TEXT_VIEW_UNFOCUSED_SIZE_WIDTH-3-TEXT_INDENT*2, TEXT_VIEW_UNFOCUSED_MAX_HEIGHT)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}
                                         context:nil];
    
    CGSize size = textRect.size;

    
    
    return CGRectMake(TEXT_VIEW_UNFOCUSED_ORIGIN_X+1, TEXT_VIEW_UNFOCUSED_ORIGIN_Y, TEXT_VIEW_UNFOCUSED_SIZE_WIDTH-3, size.height + TEXT_VIEW_TOP_MARGIN * 2);
}

- (CGRect)linedViewFrame {
    NSInteger lineHeight = round(self.lineImage.size.height);
	if (lineHeight == 0) lineHeight = 1;
    CGFloat top = self.textView.contentOffset.y - ((NSInteger)round(self.textView.contentOffset.y) % lineHeight);
    return CGRectMake(0, top, HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_WIDTH, self.textView.bounds.size.height);
}

- (void)setVisibility {
    self.unfocusedTextLabel.alpha = (UIInterfaceOrientationIsLandscape(self.orientation) && self.highlight.notecardText.length > 0
                                     && !self.isActive && ![self.delegate hasSiblingHighlights]) ? 1 : 0;
	if (self.highlight.notecardText.length > 0 && !self.isActive) {
		self.noteIconImageView.alpha = (UIInterfaceOrientationIsPortrait(self.orientation) || [self.delegate hasSiblingHighlights]) ? 1 : 0;
	} else {
		self.noteIconImageView.alpha = 0;
	}
    self.textView.alpha = self.isActive ? 1 : 0;
	self.topFadeImage.alpha = self.isActive || self.unfocusedTextLabel.alpha > 0 ? 1 : 0;
	self.backgroundShadowView.alpha = self.bottomFadeImage.alpha = self.isActive ? 1 : 0;
}

@end
