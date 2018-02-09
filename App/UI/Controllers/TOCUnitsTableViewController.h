#import <UIKit/UIKit.h>
#import "TOCNavigationDelegate.h"

@class Book, ConceptViewController;

@interface TOCUnitsTableViewController : UITableViewController <TOCNavigationDelegate>

@property (nonatomic, weak) Book *book;

- (id)initWithBook:(Book *)book andUnit:(Unit *)unit andDelegate:(id <TOCNavigationDelegate>)delegate;

@end
