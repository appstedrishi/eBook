#import <Foundation/Foundation.h>
#import "Question.h"

@class HistoryLocation;

@interface History : NSObject <NSCoding>

@property (nonatomic, strong, readonly) HistoryLocation *current;
@property (nonatomic, strong) HistoryLocation *lastNavigatedLocation;
@property (nonatomic, strong, readonly) NSMutableArray *backStack, *forwardStack, *questionStack;

extern int const MAX_HISTORY;

- (void)push:(NSURLRequest *)request;
- (void)push:(NSURLRequest *)request withScrollOffset:(CGFloat)scrollOffset;
- (void)pushQuestion:(Question *)question;
- (BOOL)canGoBack;
- (BOOL)canGoForward;
- (void)goBack;
- (void)goForward;

@end
