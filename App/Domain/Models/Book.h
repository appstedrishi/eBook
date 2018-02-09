#import <Foundation/Foundation.h>

@class Unit, Chapter, Concept;

@interface Book : NSObject <NSCoding> {
    NSMutableArray *units_;
    NSMutableArray *glossaryConcepts_;
    NSMutableArray *answerConcepts_;
}

@property (nonatomic, strong, readonly) NSString *version;
@property (nonatomic, strong, readonly) NSArray *units;
@property (nonatomic, weak, readonly) Concept *initialConcept;
@property (nonatomic, weak) Concept *currentConcept;
@property (nonatomic, strong, readonly) NSMutableArray *glossaryConcepts;
@property (nonatomic, strong, readonly) NSMutableArray *answerConcepts;

- (id)initWithIndexData:(NSData *)indexData andGlossaryIndexData:(NSData *)glossaryIndexData;

- (BOOL)addConcept:(Concept *)newConcept;

- (BOOL)userHasNavigated;
- (BOOL)hasNextConcept;
- (BOOL)hasPreviousConcept;
- (BOOL)conceptIsInTextbook:(Concept *)concept;
- (BOOL)currentConceptIsInTextbook;
- (BOOL)conceptIsInGlossary:(Concept *)concept;
- (BOOL)currentConceptIsInGlossary;
- (BOOL)conceptIsAnswer:(Concept *)concept;
- (BOOL)currentConceptIsAnswer;
- (Chapter *)getChapterForConcept:(Concept *)concept;
- (Concept *)nextConcept;
- (Concept *)previousConcept;

- (Concept *)conceptForRequest:(NSURLRequest *)request;
- (Concept *)conceptForPath:(NSString *)path;
- (NSUInteger)indexOfFirstGlossaryConceptStartingWithLetter:(NSString *)letter;

@end
