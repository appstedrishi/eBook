#import <Foundation/Foundation.h>

@interface HistoryLocation : NSObject <NSCoding>

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, assign) CGFloat scrollOffset;

+ (id)locationForRequest:(NSURLRequest *)request andScrollOffset:(CGFloat)scrollOffset;

@end
