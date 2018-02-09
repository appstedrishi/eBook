#import "Concept.h"
#import "Chapter.h"
#import "Highlight.h"
#import "PCKXMLParser.h"
#import "PCKXMLParserDelegate.h"

@interface Concept ()

@property (nonatomic, strong, readwrite) NSString *number, *chapterNumber, *chapterTitle, *title, *path;
@property (nonatomic, strong, readwrite) NSArray *highlights;
@property (nonatomic, strong) PCKXMLParserDelegate *parserDelegate;

- (PCKXMLParserDelegate *)createParserDelegate;
- (BOOL)isPropertyElement:(const char *)elementName;

@end

@implementation Concept

@synthesize highlights = highlights_, number = number_, title = title_, path = path_, chapterNumber = chapterNumber_, chapterTitle = chapterTitle_, parserDelegate = parserDelegate_;

+ (Concept *)conceptWithTitle:(NSString *)title path:(NSString *)path {
    Concept *retval = [[Concept alloc] init];
    retval.title = title;
    retval.path = path;
    return retval;
}

- (NSString *)titleAndNumber {
    if (self.chapterTitle.length) {
        return [NSString stringWithFormat:@"%@: %@", self.chapterTitle, self.title];
//    if (self.number && self.number.length > 0) {
//        if (self.chapterNumber) {
//            return [NSString stringWithFormat:@"%@.%@ %@", self.chapterNumber, self.number, self.title];
//        } else {
//            return [NSString stringWithFormat:@"%@ %@", self.number, self.title];
//        }
    } else {
        return self.title;
    }
}

static NSString *NUMBER_KEY = @"number";
static NSString *TITLE_KEY = @"title";
static NSString *PATH_KEY = @"path";
static NSString *CHAPTER_KEY = @"chapterNumber";
static NSString *CHAPTER_TITLE_KEY = @"chapterTitle";
static NSString *HIGHLIGHTS_KEY = @"highlights";

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.number = [decoder decodeObjectForKey:NUMBER_KEY];
        self.title = [decoder decodeObjectForKey:TITLE_KEY];
        self.path = [decoder decodeObjectForKey:PATH_KEY];
        self.chapterNumber = [decoder decodeObjectForKey:CHAPTER_KEY];
        self.chapterTitle = [decoder decodeObjectForKey:CHAPTER_TITLE_KEY];
        self.highlights = [decoder decodeObjectForKey:HIGHLIGHTS_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.number forKey:NUMBER_KEY];
    [coder encodeObject:self.title forKey:TITLE_KEY];
    [coder encodeObject:self.path forKey:PATH_KEY];
    [coder encodeObject:self.chapterNumber forKey:CHAPTER_KEY];
    [coder encodeObject:self.chapterTitle forKey:CHAPTER_TITLE_KEY];
    [coder encodeObject:self.highlights forKey:HIGHLIGHTS_KEY];
}

#pragma mark init
- (id)init {
    if (self = [super init]) {
        self.highlights = [NSMutableArray array];
        self.parserDelegate = [self createParserDelegate];
        self.chapterNumber = nil;
        self.chapterTitle = nil;
    }
    return self;
}

- (id)initWithChapter:(Chapter *)chapter {
    if (self = [self init]) {
        self.chapterNumber = chapter.number;
        self.chapterTitle = chapter.title;
//        if (!self.number && [[chapter.concepts lastObject] isEqual:self]) {
//            self.number = @"ʀ";
//        }
    }
    return self;
}


- (void)insertHighlight:(Highlight *)highlight beforeHighlightWithIndex:(NSString *)previousHighlightIndex {
    if ([previousHighlightIndex intValue] < 0) {
        [highlights_ addObject:highlight];
    } else {
        NSInteger indexOfPreviousHighlight = -1;
        for (NSUInteger i = 0; i < [self.highlights count]; ++i) {
            Highlight *existingHighlight = [self.highlights objectAtIndex:i];
            if ([existingHighlight.index isEqualToString:previousHighlightIndex]) {
                indexOfPreviousHighlight = i;
            }
        }
        [highlights_ insertObject:highlight atIndex:indexOfPreviousHighlight];
    }
}

- (void)removeHighlight:(Highlight *)highlight {
    [highlights_ removeObject:highlight];
}

#pragma mark PCKXMLParserDelegate

- (void)parser:(PCKXMLParser *)parser didStartElement:(const char *)elementName attributeCount:(int)numAttributes attributeData:(const char**)attributes {
    self.parserDelegate.didStartElement(elementName);
}

- (void)parser:(PCKXMLParser *)parser didEndElement:(const char *)elementName {
    self.parserDelegate.didEndElement(elementName);
}

- (void)parser:(PCKXMLParser *)parser didFindCharacters:(const char *)characters {
    self.parserDelegate.didFindCharacters(characters);
}

- (void)parser:(id<PCKParser>)parser didEncounterError:(NSError *)error {
}

#pragma mark Private methods

static const char *NUMBER_ELEMENT_NAME = "number";
static const char *TITLE_ELEMENT_NAME = "title";
static const char *PATH_ELEMENT_NAME = "path";

- (PCKXMLParserDelegate *)createParserDelegate {
    PCKXMLParserDelegate *parserDelegate = [[PCKXMLParserDelegate alloc] init];

    __block NSMutableString *value = nil;

    parserDelegate.didStartElement = (PCKXMLParserDelegateBlock)^(const char *elementName) {
        if ([self isPropertyElement:elementName]) {
            value = [[NSMutableString alloc] init];
        }
    };

    parserDelegate.didEndElement = ^(const char *elementName) {
        if (value && [self isPropertyElement:elementName]) {
            NSString *actualValue = value;

            if (0 == strncmp(elementName, PATH_ELEMENT_NAME, strlen(PATH_ELEMENT_NAME))) {
                actualValue = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[@"textbook" stringByAppendingPathComponent:value]];
            }
            
            if (0 == strncmp(elementName, TITLE_ELEMENT_NAME, strlen(TITLE_ELEMENT_NAME))) {
                actualValue = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }

            [self setValue:actualValue forKey:[NSString stringWithCString:elementName encoding:NSUTF8StringEncoding]];
             value = nil;
        }
    };

    parserDelegate.didFindCharacters = ^(const char *characters) {
        if (value) {
            [value appendString:[NSString stringWithCString:characters encoding:NSUTF8StringEncoding]];
        }
    };

    return parserDelegate;
}

- (BOOL)isPropertyElement:(const char *)elementName {
    return 0 == strncmp(elementName, NUMBER_ELEMENT_NAME, strlen(elementName))
    || 0 == strncmp(elementName, TITLE_ELEMENT_NAME, strlen(elementName))
    || 0 == strncmp(elementName, PATH_ELEMENT_NAME, strlen(elementName));
}

@end
