#import <UIKit/UIKit.h>

@class Concept;

@protocol TOCNavigationDelegate

- (BOOL)conceptIsCurrentConcept:(Concept *)concept;
- (void)navigateToConcept:(Concept *)concept;

@end
