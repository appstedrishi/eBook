#import "SuggestedQuestionsView.h"
#import "Aura.h"
#import "Logger.h"
#import "ConceptViewController.h"
#import "Highlight.h"
#import "HighlightView.h"
#import <QuartzCore/QuartzCore.h>

@interface SuggestedQuestionsView ()

@property (nonatomic, strong) Highlight *highlight;
@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, assign) BOOL isShown, isActive, fetchWasSuccess;

- (void)setOriginForCurrentOrientation;
- (void)setVisibility;
- (void)setActiveAppearance;
- (void)styleQuestionLabel:(UILabel *)label;
- (void)showSuggestedQuestions;
- (void)showErrorMessage;

@end

extern const CGFloat HIGHLIGHT_FOCUSED_CARD_CONTENT_ORIGIN_X;
extern const CGFloat HIGHLIGHT_FOCUSED_CARD_CONTENT_ORIGIN_Y;
extern const CGFloat HIGHLIGHT_FOCUSED_CARD_FRAME_ORIGIN_Y_OFFSET;
extern const CGFloat HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_WIDTH;
extern const CGFloat HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_HEIGHT;
static const CGFloat UNFOCUSED_ORIGIN_X = 18;
static const CGFloat UNFOCUSED_ORIGIN_Y = -3;
static const CGFloat UNFOCUSED_SIZE_WIDTH = 292;
//static const CGFloat UNFOCUSED_SIZE_HEIGHT = 196;

@implementation SuggestedQuestionsView

@synthesize highlight = highlight_,
cardView = cardView_,
spinner = spinner_,
delegate = delegate_,
questionsTable = questionsTable_,
errorMessageView = errorMessageView_,
label = label_,
noQuestionsLabel = noQuestionsLabel_,
closeButton = closeButton_,
divider = divider_,
orientation = orientation_,
isShown = isShown_,
isActive = isActive_,
fetchWasSuccess = fetchWasSuccess_;

- (id)initWithOwner:(id)owner andHighlight:(Highlight *)highlight andOrientation:(UIInterfaceOrientation)orientation {
    if ((self = [[[NSBundle mainBundle] loadNibNamed:@"SuggestedQuestionsView" owner:owner options:nil] objectAtIndex:0])) {
        self.highlight = highlight;
        self.questionsTable.alwaysBounceVertical = YES;
        self.questionsTable.backgroundColor = [UIColor clearColor];
        self.orientation = orientation;
        self.isShown = NO;
		
		self.layer.shadowColor = [UIColor blackColor].CGColor;
		self.layer.shadowOffset = CGSizeMake(1, 1);
		self.layer.shadowOpacity = 0.7;
		self.layer.shadowRadius = 1.0;
		self.layer.masksToBounds = NO;
		
		self.noQuestionsLabel.hidden = YES;
		
        [self setOriginForCurrentOrientation];
        [self setVisibility];
    }
    return self;
}


- (IBAction)didTapCloseButton:(id)sender {
    [self close];
    [self.delegate suggestedQuestionsViewDidClose];
}

- (void)close {
    [self.highlight cancelPendingRequest];
    self.isShown = NO;
	//[UIView animateWithDuration:0.2 animations:^{
	[self setVisibility];
	//}];
}

- (void)show {
    [self.spinner startAnimating];
    self.errorMessageView.alpha = 0;
    self.questionsTable.alpha = 1;
    self.questionsTable.contentOffset = CGPointMake(0, 0);
   // [self.highlight fetchSuggestedQuestionsListWithDelegate:self];
    //[self.highlight fetchSuggestedQuestionNew];
   [self.highlight fetchSuggestedQuestionNew:YES completionHandler:^(BOOL var,NSMutableArray *arr)
    
    {
        if (var) {
            
        
        if ([arr count] !=0) {
            // [self showQuestionList:YES];
            
            [self performSelectorOnMainThread:@selector(showQuestionList:) withObject:nil waitUntilDone:YES];
        }
        else
        {
            [self performSelectorOnMainThread:@selector(showErrorMessage) withObject:nil waitUntilDone:YES];
           // [self showErrorMessage];
        }
        }
        else
        {
            [self performSelectorOnMainThread:@selector(showErrorMessage) withObject:nil waitUntilDone:YES];        }
       
    }
    ];
    self.isShown = YES;
	
	//[UIView animateWithDuration:0.2 animations:^{
	[self setVisibility];
	//}];
}

#pragma mark HighlightViewComponent
- (void)activate {
    [self setActiveAppearance];
    self.isActive = YES;
    [self close];
}

- (void)deactivate {
    self.isActive = NO;
    [self.highlight cancelPendingRequest];
    self.isShown = NO;
	[self setVisibility];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toOrientation {
    self.orientation = toOrientation;
    [self setOriginForCurrentOrientation];
    [self setVisibility];
}

- (BOOL)hasVisibleCard {
    return self.isActive && self.isShown;
}


-(void)showQuestionList:(BOOL)var
{
   
    [self.questionsTable reloadData];
    
    if (!var) {
         [self showSuggestedQuestions];
    }
    else
    {   [self showErrorMessage];
    }
    [self.spinner stopAnimating];
    
    
    
}







#pragma mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"SuggestedQuestionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		[self styleQuestionLabel:cell.textLabel];
		//cell.indentationLevel = 1;
		//cell.indentationWidth = 5;
        cell.backgroundColor = [UIColor clearColor];
    }
    NSLog(@"test question =%@",[self.highlight.suggestedQuestionsList objectAtIndex:indexPath.row]);
    cell.textLabel.text = [self.highlight.suggestedQuestionsList objectAtIndex:indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.highlight.suggestedQuestionsList count];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [(HighlightView *)self.superview showQuestionViewWithQuestion:[self.highlight.suggestedQuestionsList objectAtIndex:indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [Logger log:@"Asked question (blue SQ card):" withArguments:[self.highlight.suggestedQuestionsList objectAtIndex:indexPath.row] ];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *labelText = [self.highlight.suggestedQuestionsList objectAtIndex:indexPath.row];
    
    //
   
    NSAttributedString *attributedText =
    [[NSAttributedString alloc] initWithString:labelText
                                    attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){tableView.frame.size.width-20-10, 200}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
	return size.height + SUGGESTED_QUESTION_TABLE_ROW_SEPARATOR_HEIGHT;
}

#pragma mark Private interface
- (void)setOriginForCurrentOrientation {
    CGFloat y = UIInterfaceOrientationIsPortrait(self.orientation) ? self.highlight.height+HIGHLIGHT_FOCUSED_CARD_FRAME_ORIGIN_Y_OFFSET : 0;
    self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
}

- (void)setVisibility {
    self.alpha = self.hasVisibleCard ? 1 : 0;
}

- (void)setActiveAppearance {
   self.label.hidden = YES;
    self.closeButton.hidden = YES;
    self.divider.hidden = YES;
	self.layer.shadowOpacity = 0;

    self.cardView.frame = CGRectMake(HIGHLIGHT_FOCUSED_CARD_CONTENT_ORIGIN_X+1,
                                     HIGHLIGHT_FOCUSED_CARD_CONTENT_ORIGIN_Y,
                                     HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_WIDTH-1,
                                     HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_HEIGHT);
    self.questionsTable.frame = CGRectMake(0, cardView_.frame.origin.y+3, HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_WIDTH-1, cardView_.frame.size.height-20);//HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_HEIGHT 195X
    //0, 20, HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_WIDTH-1, cardView_.frame.size.height-20
}

- (void)styleQuestionLabel:(UILabel *)label {
   // label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 11;
    label.font = [UIFont systemFontOfSize:16];
	label.textColor = [UIColor colorWithHue:0.609 saturation:0.640 brightness:0.257 alpha:1.000];
}

- (void)showSuggestedQuestions {
  //  [self.questionsTable reloadData];
		if ([self.highlight.suggestedQuestionsList count] == 0) {
		self.noQuestionsLabel.hidden = NO;
	} else {
		self.noQuestionsLabel.hidden = YES;
	}
}

- (void)showErrorMessage {
    [self.spinner stopAnimating];
    self.errorMessageView.alpha = 1;
    self.questionsTable.alpha = 0;
    if (self.isActive) {
        self.cardView.frame = CGRectMake(HIGHLIGHT_FOCUSED_CARD_CONTENT_ORIGIN_X+1,
                                         HIGHLIGHT_FOCUSED_CARD_CONTENT_ORIGIN_Y,
                                         HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_WIDTH-1,
                                         HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_HEIGHT);
    } else {
        self.cardView.frame = CGRectMake(UNFOCUSED_ORIGIN_X, UNFOCUSED_ORIGIN_Y, UNFOCUSED_SIZE_WIDTH, self.errorMessageView.frame.size.height);
    }
}

@end

