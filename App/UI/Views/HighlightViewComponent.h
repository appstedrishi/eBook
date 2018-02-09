#import <Foundation/Foundation.h>

@protocol HighlightViewComponent

@required
- (void)activate;
- (void)deactivate;
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toOrientation;
- (BOOL)hasVisibleCard;

@optional
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toOrientation;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromOrientation;
- (void)refresh;

@end
