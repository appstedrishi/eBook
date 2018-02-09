#import <Foundation/Foundation.h>

@interface MockArgumentRecorder : NSObject {
    NSMutableArray *arguments_;
}

@property (nonatomic, retain, readonly) NSArray *arguments;

@end
