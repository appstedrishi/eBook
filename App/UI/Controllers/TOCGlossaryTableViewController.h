#import <UIKit/UIKit.h>
#import "TOCNavigationDelegate.h"

@class Book, Concept;

@interface TOCGlossaryTableViewController : UITableViewController < UISearchBarDelegate,UISearchControllerDelegate,UISearchResultsUpdating>

- (id)initWithBook:(Book *)book andDelegate:(id<TOCNavigationDelegate>)delegate;

- (id)initWithBook:(Book *)book term:(Concept *)term andDelegate:(id<TOCNavigationDelegate>)delegate;

@end
