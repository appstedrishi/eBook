#import <Foundation/Foundation.h>

#import "PCKXMLParserDelegate.h"

@class Highlight, Chapter;

@interface Concept : NSObject <NSCoding, PCKXMLParserDelegate> {
    NSMutableArray *highlights_;
}

@property (nonatomic, strong, readonly) NSArray *highlights;
@property (nonatomic, strong, readonly) NSString *number, *chapterNumber, *chapterTitle, *title, *path;

+ (Concept *)conceptWithTitle:(NSString *)title path:(NSString *)path;

- (id)initWithChapter:(Chapter *)chapter;

- (void)insertHighlight:(Highlight *)highlight beforeHighlightWithIndex:(NSString *)previousHighlightIndex;
- (void)removeHighlight:(Highlight *)highlight;

- (NSString *)titleAndNumber;

@end
