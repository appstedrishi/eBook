#import "HCEmptyContainer.h"

#if TARGET_OS_IPHONE
#import "HCDescription.h"
#else
#import <OCHamcrest/HCDescription.h>
#endif

@implementation HCEmptyContainer

+ (id)emptyContainer {
    return [[[HCEmptyContainer alloc] init] autorelease];
}

- (BOOL)matches:(id)item {
    if (!item) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Checking if nil is an empty container" userInfo:nil];
    }
    return item && 0 == [item count];
}

- (void)describeTo:(id<HCDescription>)description {
    [description appendText:@"empty"];
}

@end

id<HCMatcher> HC_emptyContainer() {
    return [HCEmptyContainer emptyContainer];
}
