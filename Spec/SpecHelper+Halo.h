#if TARGET_OS_IPHONE
#import "SpecHelper.h"
#import "PivotalSpecHelperKit.h"
#else
#import <Cedar/SpecHelper.h>
#import <PivotalSpecHelperKit/PivotalSpecHelperKit.h>
#endif

@class Book, History;

@interface SpecHelper (Halo)

- (Book *)createBook;
- (History *)createHistoryWithConcepts:(NSArray *)concepts andScrollOffsets:(NSArray *)scrollOffsets;

@end
