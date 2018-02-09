#import <UIKit/UIKit.h>

@class Chapter, Unit;
@protocol TOCNavigationDelegate;

@interface TOCChaptersTableViewController : UITableViewController

@property (nonatomic, weak) id <TOCNavigationDelegate> delegate;
@property (nonatomic, weak) Unit *unit;
@property (nonatomic, weak) Chapter *chapter;

- (id)initWithDelegate:(id <TOCNavigationDelegate>)delegate andUnit:(Unit *)unit andChapter:(Chapter *)chapter;

@end
