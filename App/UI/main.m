#import <UIKit/UIKit.h>
#import "HaloApplicationDelegate.h"
#import "QTouchposeApplication.h"

int main(int argc, char *argv[]) {
    @autoreleasepool {
    
//    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"UIUseLegacyUI"];
//    [[NSUserDefaults standardUserDefaults] synchronize];

        return UIApplicationMain(argc, argv, NSStringFromClass([QTouchposeApplication class]), NSStringFromClass([HaloApplicationDelegate class]));
    }
}
