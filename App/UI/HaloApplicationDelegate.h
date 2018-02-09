#import <UIKit/UIKit.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
@class ConceptViewController, Book;

@interface HaloApplicationDelegate : NSObject <UIApplicationDelegate>

+ (id)app;

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet ConceptViewController *conceptViewController;

- (void)saveStateToArchive;

@end
