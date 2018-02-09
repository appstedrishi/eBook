#import <UIKit/UIKit.h>
#import "TOCNavigationDelegate.h"

@class Book, ConceptViewController;

@interface TOCMainTableViewController : UITableViewController <TOCNavigationDelegate>

@property (nonatomic, weak) Book *book;
//@property (nonatomic, weak) UIPopoverController *popover;

- (id)initWithBook:(Book *)book andDelegate:(ConceptViewController *)delegate;

- (void)navigateListToConcept:(Concept *)concept;

@end
