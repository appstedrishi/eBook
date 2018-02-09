#import "HighlightToolbarView.h"
#import "HighlightView.h"
#import "Highlight.h"
#import "Logger.h"

const CGFloat HIGHLIGHT_TOOLBAR_HEIGHT = 23;

extern const CGFloat HIGHLIGHT_FOCUSED_CARD_FRAME_ORIGIN_Y_OFFSET;

@interface HighlightToolbarView ()

@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, assign) BOOL isActive;
@property (nonatomic, strong) Highlight *highlight;

- (void)setOriginForCurrentOrientation;
- (void)setVisibility;
- (void)cancelDeletion;

@end

@implementation HighlightToolbarView

@synthesize deleteButton = deleteButton_, questionsButton = questionsButton_, orientation = orientation_,
toolbarImageView = toolbarImageView_, isActive = isActive_, confirmDeleteButton = confirmDeleteButton_, notesButton = notesButton_,
cancelDeleteButton = cancelDeleteButton_, yellowButton = yellowButton_, blueButton = blueButton_, greenButton = greenButton_, 
highlight = highlight_, toolbarImageViewPortrait = toolbarImageViewPortrait_, deleteConfirmationView = deleteConfirmationView_, 
deleteConfirmationImage = deleteConfirmationImage_, creationDateLabel = creationDateLabel_;

- (id)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithFrame:(CGRect)frame {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithSuperview:(UIView *)superview highlight:(Highlight *)highlight orientation:(UIInterfaceOrientation)orientation {
    if ((self = [[[NSBundle mainBundle] loadNibNamed:@"HighlightToolbarView" owner:superview options:nil] objectAtIndex:0])) {
        self.orientation = orientation;
        self.highlight = highlight;
        
        // print the creation date
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"d MMMM" options:0 locale:[NSLocale systemLocale]]];
        NSString *dateString = [format stringFromDate:self.highlight.creationDate];
        [format setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"h:mm a" options:0 locale:[NSLocale systemLocale]]];
        NSString *timeString = [format stringFromDate:self.highlight.creationDate];
        self.creationDateLabel.text = [NSString stringWithFormat:@"Created %@, %@", dateString, timeString];
        
        // can't set these in IB, sadly
        [self.yellowButton setImage:[UIImage imageNamed:@"hl-colors-yellow-pushed.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
        [self.blueButton setImage:[UIImage imageNamed:@"hl-colors-blue-pushed.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
        [self.greenButton setImage:[UIImage imageNamed:@"hl-colors-green-pushed.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
		
		[self.deleteConfirmationImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapCancel)]];

        [self setOriginForCurrentOrientation];
        [self setVisibility];
    }
    return self;
}


- (void) updateTabsAndShowDeleteButton:(BOOL)showDelete {
	[self setVisibility];
	self.deleteButton.userInteractionEnabled = showDelete;
	self.deleteButton.alpha = showDelete ? 1 : 0.3;
}

#pragma mark Actions

- (IBAction)didTapCancel {
    [UIView animateWithDuration:0.2 animations:^{
        [self cancelDeletion];
	} completion:^(BOOL finished){ }];
    [self setVisibility];
}

- (IBAction)didTapHighlightButton:(UIButton *)button {
    if (!button.selected) {
        self.blueButton.selected = NO;
        self.yellowButton.selected = NO;
        self.greenButton.selected = NO;
        
        if (button == self.blueButton) {
            self.blueButton.selected = YES;
        } else if (button == self.greenButton) {
            self.greenButton.selected = YES;
        } else {
            self.yellowButton.selected = YES;
        }
    }
    
    // EASTER EGG
    if (button == self.yellowButton) {
        // do nothing
    } else {
        NSString *color = (button == self.blueButton) ? @"Blue" : @"Green";
        NSString *msg = [NSString stringWithFormat:@"Blue and green highlight colors are only available as in-app purchases. Do you want to buy the %@ Highlighter for $1.99?", color];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Highlight Colors" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy", nil];
//        [alert show];
        
        
        UIAlertController * alert=[UIAlertController
                                   
                                   alertControllerWithTitle:@"Purchase Highlight Colors" message:msg preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Buy"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                       
                                        [self alertBuy];
                                    
                                    }];
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action)
                                   {
                                      
                                  }];
        
        [alert addAction:yesButton];
        [alert addAction:noButton];
        
        [[self currentTopViewController] presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark UIAlertViewDelegate
- (UIViewController *)currentTopViewController
{
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController)
    {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}
-(void)alertBuy{

        [Logger log:@"User attempted to purchase additional highlight colors. $1.99 jackpot! :P"];
       // [[[UIAlertView alloc] initWithTitle:@"In-App Purchases Disabled" message:@"Sorry, you can't really buy access to the other colors. Only yellow has been implemented." delegate:nil cancelButtonTitle:@"Shucks" otherButtonTitles:nil] show];
    
    
    UIAlertController * alert=[UIAlertController
                               
                               alertControllerWithTitle:@"In-App Purchases Disabled" message:@"Sorry, you can't really buy access to the other colors. Only yellow has been implemented." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"Shucks"
                               style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction * action)
                               {
                                   
                               }];

     [alert addAction:noButton];
     [[self currentTopViewController] presentViewController:alert animated:YES completion:nil];
    
    self.blueButton.selected = NO;
    self.yellowButton.selected = YES;
    self.greenButton.selected = NO;

}
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    // EASTER EGG follow-up :P
//    if (buttonIndex) {
//        [Logger log:@"User attempted to purchase additional highlight colors. $1.99 jackpot! :P"];
//        [[[UIAlertView alloc] initWithTitle:@"In-App Purchases Disabled" message:@"Sorry, you can't really buy access to the other colors. Only yellow has been implemented." delegate:nil cancelButtonTitle:@"Shucks" otherButtonTitles:nil] show];
//    }
//    self.blueButton.selected = NO;
//    self.yellowButton.selected = YES;
//    self.greenButton.selected = NO;
//}

#pragma mark HighlightViewComponent
- (void)activate {
    self.isActive = YES;
    [self setVisibility];
}

- (void)deactivate {
    self.isActive = NO;
    self.questionsButton.selected = NO;
    [self setVisibility];
    [self cancelDeletion];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    self.orientation = orientation;
	
    [self setOriginForCurrentOrientation];
    [self setVisibility];
}

- (BOOL)hasVisibleCard {
    return NO;
}

#pragma mark Private interface
- (void)setOriginForCurrentOrientation {
    CGFloat y = UIInterfaceOrientationIsPortrait(self.orientation) ? self.highlight.height+HIGHLIGHT_FOCUSED_CARD_FRAME_ORIGIN_Y_OFFSET : 0;
    self.frame = CGRectMake(self.frame.origin.x, y, self.frame.size.width, self.frame.size.height);
}

- (void)setVisibility {
	if (UIInterfaceOrientationIsPortrait(self.orientation)) {
        [self.imgPaperPin setHidden:YES];
		self.toolbarImageViewPortrait.hidden = NO;
		self.toolbarImageView.hidden = YES;
	} else {
         [self.imgPaperPin setHidden:NO];
		self.toolbarImageViewPortrait.hidden = YES;
		self.toolbarImageView.hidden = NO;
	}        
    
    // set portrait top bar
    if (self.questionsButton.selected) {
		[self sendSubviewToBack:self.notesButton];
		[self insertSubview:self.questionsButton belowSubview:self.deleteConfirmationView];
		self.toolbarImageViewPortrait.image = [UIImage imageNamed:@"sticky-focused-blue-portrait.png"];
	} else {
		[self sendSubviewToBack:self.questionsButton];
		[self insertSubview:self.notesButton belowSubview:self.deleteConfirmationView];
		self.toolbarImageViewPortrait.image = [UIImage imageNamed:@"sticky-focused-portrait.png"];
	}
    if (self.deleteConfirmationView.alpha) {
        self.toolbarImageViewPortrait.image = [UIImage imageNamed:@"sticky-focused-gray-portrait.png"];
    }

    self.alpha = self.isActive ? 1 : 0;
}

- (void)confirmDeletion {
	self.deleteConfirmationView.alpha = 1;
    self.toolbarImageViewPortrait.image = [UIImage imageNamed:@"sticky-focused-gray-portrait.png"];
    [self setVisibility];
}

- (void)cancelDeletion {
	self.deleteConfirmationView.alpha = 0;
    [self setVisibility];
}

@end
