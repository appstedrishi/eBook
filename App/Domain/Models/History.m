#import "History.h"
#import "HistoryLocation.h"

@interface History ()

@property (nonatomic, strong, readwrite) HistoryLocation *current;
@property (nonatomic, strong, readwrite) NSMutableArray *backStack, *forwardStack, *questionStack;

@end

@implementation History

@synthesize current = current_, backStack = backStack_, forwardStack = forwardStack_,
			questionStack = questionStack_, lastNavigatedLocation = lastNavigatedLocation_;

int const MAX_HISTORY = 50;

- (id)init {
    if (self = [super init]) {
        self.backStack = [NSMutableArray arrayWithCapacity:MAX_HISTORY+1];
        self.forwardStack = [NSMutableArray arrayWithCapacity:MAX_HISTORY+1];
		self.questionStack = [NSMutableArray arrayWithCapacity:MAX_HISTORY*2];
    }
    return self;
}


#pragma mark NSCoding
static NSString *CURRENT_KEY = @"current";
static NSString *LAST_NAVIGATED_KEY = @"lastnav";
static NSString *BACK_STACK_KEY = @"backstack";
static NSString *FORWARD_STACK_KEY = @"forwardstack";
static NSString *QUESTION_STACK_KEY = @"questionstack";

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {		
        self.current = [decoder decodeObjectForKey:CURRENT_KEY];
        self.lastNavigatedLocation = [decoder decodeObjectForKey:LAST_NAVIGATED_KEY];
        self.backStack = [decoder decodeObjectForKey:BACK_STACK_KEY];
        self.forwardStack = [decoder decodeObjectForKey:FORWARD_STACK_KEY];
		self.questionStack = [decoder decodeObjectForKey:QUESTION_STACK_KEY];
		
		if (!self.backStack) self.backStack = [NSMutableArray arrayWithCapacity:MAX_HISTORY+1];
		if (!self.forwardStack) self.forwardStack = [NSMutableArray arrayWithCapacity:MAX_HISTORY+1];
		if (!self.questionStack) self.questionStack = [NSMutableArray arrayWithCapacity:MAX_HISTORY+1];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.current forKey:CURRENT_KEY];
    [coder encodeObject:self.lastNavigatedLocation forKey:LAST_NAVIGATED_KEY];
    [coder encodeObject:self.backStack forKey:BACK_STACK_KEY];
    [coder encodeObject:self.forwardStack forKey:FORWARD_STACK_KEY];
	[coder encodeObject:self.questionStack forKey:QUESTION_STACK_KEY];
}

#pragma mark History
- (void)push:(NSURLRequest *)request {
    if (self.current && [request.URL.path isEqualToString:self.current.request.URL.path]) {
        return;
    }
    [self push:request withScrollOffset:0];
}

- (void)push:(NSURLRequest *)request withScrollOffset:(CGFloat)scrollOffset {
//    if (self.canGoForward) {
//        [self.backStack addObjectsFromArray:self.forwardStack];
//        [self.forwardStack removeAllObjects];
//    }
    if (self.current && ![request.URL.path isEqualToString:self.current.request.URL.path]) {
        [self.backStack addObject:self.current];
//        [self.backStack addObject:[HistoryLocation locationForRequest:self.current.request andScrollOffset:self.current.scrollOffset]];
    }
    
    self.current = [HistoryLocation locationForRequest:request andScrollOffset:scrollOffset];
    [self.forwardStack removeAllObjects];
    
    while ([self.backStack count] > MAX_HISTORY) { // todo: do something less lazy looking :P
        [self.backStack removeObjectAtIndex:0];
    }
}

- (void)pushQuestion:(Question *)question {
	question.text = [question.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([self.questionStack containsObject:question]) {
		[self.questionStack removeObject:question];
	}
	[self.questionStack insertObject:question atIndex:0];
	if ([self.questionStack count] > MAX_HISTORY) {
		[self.questionStack removeLastObject];
	}
}

- (BOOL)canGoBack {
    return !![self.backStack count];
}

- (BOOL)canGoForward {
    return !![self.forwardStack count];
}

- (void)goBack {
    if ([self canGoBack]) {
        [self.forwardStack addObject:self.current];
        self.current = [self.backStack lastObject];
        [self.backStack removeLastObject];
    }
};

- (void)goForward {
    if ([self canGoForward]) {
        [self.backStack addObject:self.current];
        self.current = [self.forwardStack lastObject];
        [self.forwardStack removeLastObject];
    }
}

@end
