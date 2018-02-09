#import "SpecHelper+Halo.h"
#import "Book.h"
#import "History.h"
#import "Concept.h"

@implementation SpecHelper (Halo)

- (void)beforeEach {
    [PSHKFixtures setDirectory:@FIXTURESDIR];
}

- (void)afterEach {
    [NSURLConnection resetAll];
}

- (Book *)createBook {
    NSData *indexData = [NSData dataWithContentsOfFile:[[PSHKFixtures directory] stringByAppendingPathComponent:@"bookIndex.xml"]];
    NSData *glossaryIndexData = [NSData dataWithContentsOfFile:[[PSHKFixtures directory] stringByAppendingPathComponent:@"glossaryIndex.xml"]];

    return [[[Book alloc] initWithIndexData:indexData andGlossaryIndexData:glossaryIndexData] autorelease];
}

- (History *)createHistoryWithConcepts:(NSArray *)concepts andScrollOffsets:(NSArray *)scrollOffsets {
    History *history = [[[History alloc] init] autorelease];

    for (int i = 0; i < [concepts count]; ++i) {
        Concept *concept = [concepts objectAtIndex:i];
        CGFloat offset = [scrollOffsets count] > i ? [[scrollOffsets objectAtIndex:i] floatValue] : 0;

        NSURL *url = [[[NSURL alloc] initFileURLWithPath:concept.path] autorelease];
        NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url] autorelease];

        [history push:request withScrollOffset:offset];
    }
    return history;
}

@end

