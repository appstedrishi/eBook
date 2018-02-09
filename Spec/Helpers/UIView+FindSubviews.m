#import "UIView+FindSubviews.h"

@implementation UIView (FindSubviews)

- (NSArray *)findSubviewsByClass:(Class)klass {
    NSMutableArray *results = [NSMutableArray array];

    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:klass]) {
            [results addObject:subview];
        }
    }
    return (NSArray *)results;
}

@end
