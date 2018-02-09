#import <UIKit/UIKit.h>
#import "ContainerView.h"
#import "HighlightViewComponent.h"

@class Highlight;

@interface HighlightToolbarView : ContainerView <HighlightViewComponent, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *toolbarImageView, *toolbarImageViewPortrait, *deleteConfirmationImage;
@property (nonatomic, weak) IBOutlet UIView *deleteConfirmationView;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton, *questionsButton, *confirmDeleteButton, *cancelDeleteButton, *notesButton, *yellowButton, *greenButton, *blueButton;
@property (nonatomic, weak) IBOutlet UILabel *creationDateLabel;

- (id)initWithSuperview:(UIView *)superview highlight:(Highlight *)highlight orientation:(UIInterfaceOrientation)orientation;
- (void)updateTabsAndShowDeleteButton:(BOOL)showDelete;
- (void)confirmDeletion;
@property (weak, nonatomic) IBOutlet UIImageView *imgPaperPin;

- (IBAction)didTapCancel;
- (IBAction)didTapHighlightButton:(UIButton *)button;

@end
