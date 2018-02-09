#import "Book.h"
#import "Unit.h"
#import "Chapter.h"
#import "Concept.h"
#import "PCKXMLParser.h"
#import "PCKXMLParserDelegate.h"

typedef NS_ENUM(NSUInteger, ConceptType)  {
    ConceptTypeNormal = 0,
    ConceptTypeGlossary,
    ConceptTypeAnswer
};

@interface Book ()

@property (nonatomic, strong, readwrite) NSString *version;
@property (nonatomic, strong, readwrite) NSArray *units;
@property (nonatomic, strong, readwrite) NSMutableArray *glossaryConcepts;
@property (nonatomic, strong, readwrite) NSMutableArray *answerConcepts;
@property (nonatomic, strong) NSMutableArray *orderedConcepts;
@property (nonatomic, strong) NSMutableDictionary *conceptsByPath;
@property (nonatomic, assign) NSUInteger initialConceptIndex;
@property (nonatomic, assign) ConceptType initialConceptType;

- (void)encodeInitialConceptWithCoder:(NSCoder *)coder;

- (PCKXMLParserDelegate *)makeBookParserDelegate;
- (PCKXMLParserDelegate *)makeGlossaryParserDelegate;

- (void)parseGlossaryIndexData:(NSData *)indexData;
- (void)parseIndexData:(NSData *)indexData;
- (void)indexConcepts;

@end

@implementation Book

@synthesize version = version_;
@synthesize units = units_;
@synthesize currentConcept = currentConcept_;
@synthesize orderedConcepts = orderedConcepts_;
@synthesize glossaryConcepts = glossaryConcepts_;
@synthesize answerConcepts = answerConcepts_;
@synthesize conceptsByPath = conceptsByPath_;
@synthesize initialConceptIndex = initialConceptIndex_, initialConceptType = initialConceptType_;

#pragma mark NSCoding
static NSString	*VERSION_KEY = @"version";
static NSString *UNITS_KEY = @"units";
static NSString *GLOSSARY_CONCEPTS_KEY = @"glossaryConcepts";
static NSString *ANSWER_CONCEPTS_KEY = @"answerConcepts";
static NSString *INITIAL_CONCEPT_INDEX_KEY = @"initialConceptIndex";
static NSString *INITIAL_CONCEPT_TYPE_KEY = @"initialConceptType";

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
		self.version = [decoder decodeObjectForKey:VERSION_KEY];
        self.units = [decoder decodeObjectForKey:UNITS_KEY];
        self.glossaryConcepts = [decoder decodeObjectForKey:GLOSSARY_CONCEPTS_KEY];
        self.answerConcepts = [decoder decodeObjectForKey:ANSWER_CONCEPTS_KEY];
        self.orderedConcepts = [NSMutableArray array];
        self.conceptsByPath = [NSMutableDictionary dictionary];
        self.initialConceptType = [decoder decodeIntegerForKey:INITIAL_CONCEPT_TYPE_KEY];
        self.initialConceptIndex = [decoder decodeIntForKey:INITIAL_CONCEPT_INDEX_KEY];
		[self.glossaryConcepts sortUsingComparator:(NSComparator)^(id obj1, id obj2){
			NSString *title1 = [obj1 title];
			NSString *title2 = [obj2 title];
			return [title1 caseInsensitiveCompare:title2]; 
		}];
        [self indexConcepts];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.version forKey:VERSION_KEY];
    [coder encodeObject:self.units forKey:UNITS_KEY];
    [coder encodeObject:self.glossaryConcepts forKey:GLOSSARY_CONCEPTS_KEY];
    [coder encodeObject:self.answerConcepts forKey:ANSWER_CONCEPTS_KEY];
    [self encodeInitialConceptWithCoder:coder];
}

#pragma mark init
- (id)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithIndexData:(NSData *)indexData andGlossaryIndexData:(NSData *)glossaryIndexData {
    if (self = [super init]) {
		self.version = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
        self.units = [NSMutableArray array];
        self.orderedConcepts = [NSMutableArray array];
        self.glossaryConcepts = [NSMutableArray array];
        self.answerConcepts = [NSMutableArray array];
        self.conceptsByPath = [NSMutableDictionary dictionary];
        self.initialConceptIndex = 0;

        [self parseIndexData:indexData];
        [self parseGlossaryIndexData:glossaryIndexData];
		[self.glossaryConcepts sortUsingComparator:(NSComparator)^(id obj1, id obj2){
			NSString *title1 = [obj1 title];
			NSString *title2 = [obj2 title];
			return [title1 caseInsensitiveCompare:title2]; 
		}];
		[self indexConcepts];
    }
    return self;
}


- (BOOL)addConcept:(Concept *)newConcept {
    [self.answerConcepts addObject:newConcept];
    [self.conceptsByPath setObject:newConcept forKey:newConcept.path];
    return YES;
}

- (Concept *)initialConcept {
    if (self.currentConcept) {
        return self.currentConcept;
    } else {
        switch (self.initialConceptType) {
            case ConceptTypeGlossary:
                return [self.glossaryConcepts objectAtIndex:self.initialConceptIndex];
                break;
            case ConceptTypeAnswer:
                return [self.answerConcepts objectAtIndex:self.initialConceptIndex];
                break;
            default:
                return [self.orderedConcepts objectAtIndex:self.initialConceptIndex];
                break;
        }
    }
}

- (BOOL)userHasNavigated {
    return [self.orderedConcepts objectAtIndex:0] != self.currentConcept;
}

- (BOOL)hasNextConcept {
    return ([self.orderedConcepts lastObject] != self.currentConcept) && ([self.glossaryConcepts lastObject] != self.currentConcept);
}

- (BOOL)hasPreviousConcept {
    return ([self.orderedConcepts objectAtIndex:0] != self.currentConcept) && ([self.glossaryConcepts objectAtIndex:0] != self.currentConcept);
}

- (Concept *)nextConcept {
    if ([self currentConceptIsInGlossary]) {
        return [self.glossaryConcepts objectAtIndex:[self.glossaryConcepts indexOfObject:self.currentConcept] + 1];
    } else {
        return [self.orderedConcepts objectAtIndex:[self.orderedConcepts indexOfObject:self.currentConcept] + 1];
    }
}

- (Concept *)previousConcept {
    if ([self currentConceptIsInGlossary]) {
        return [self.glossaryConcepts objectAtIndex:[self.glossaryConcepts indexOfObject:self.currentConcept] - 1];
    } else {
        return [self.orderedConcepts objectAtIndex:[self.orderedConcepts indexOfObject:self.currentConcept] - 1];
    }
}

- (Concept *)conceptForPath:(NSString *)path {
    return [self.conceptsByPath objectForKey:path];
}

- (Concept *)conceptForRequest:(NSURLRequest *)request {
    return [self conceptForPath:request.URL.path];
}

- (NSUInteger)indexOfFirstGlossaryConceptStartingWithLetter:(NSString *)letter {
    letter = [letter substringToIndex:1];
    for (unsigned int i = 0; i < self.glossaryConcepts.count; ++i) {
        Concept *concept = [self.glossaryConcepts objectAtIndex:i];
        if (NSOrderedSame == [concept.title compare:letter options:NSCaseInsensitiveSearch range:NSMakeRange(0, 1)]) {
            return i;
        }
    }
    return NSNotFound;
}

- (Chapter *)getChapterForConcept:(Concept *)concept {
    for (Unit *u in self.units) {
        for (Chapter *ch in u.chapters) {
            if ([ch.concepts containsObject:concept]) {
                return ch;
            }
        }
    }
    return nil;
}

#pragma mark Private methods
- (void)encodeInitialConceptWithCoder:(NSCoder *)coder {
    self.initialConceptType = ConceptTypeNormal;
    self.initialConceptIndex = [self.orderedConcepts indexOfObject:self.initialConcept];

    if (NSNotFound == self.initialConceptIndex) {
        self.initialConceptType = ConceptTypeGlossary;
        self.initialConceptIndex = [self.glossaryConcepts indexOfObject:self.initialConcept];
        
        if (NSNotFound == self.initialConceptIndex) {
            self.initialConceptType = ConceptTypeAnswer;
            self.initialConceptIndex = [self.answerConcepts indexOfObject:self.initialConcept];
        }
    }

    [coder encodeInteger:self.initialConceptType forKey:INITIAL_CONCEPT_TYPE_KEY];
    [coder encodeInteger:self.initialConceptIndex forKey:INITIAL_CONCEPT_INDEX_KEY];
}

- (void)parseIndexData:(NSData *)indexData {
    PCKXMLParserDelegate *delegate = [self makeBookParserDelegate];
    PCKXMLParser *parser = [[PCKXMLParser alloc] initWithDelegate:delegate];
    [parser parseChunk:indexData];
}

- (void)parseGlossaryIndexData:(NSData *)indexData {
    PCKXMLParserDelegate *delegate = [self makeGlossaryParserDelegate];
    PCKXMLParser *parser = [[PCKXMLParser alloc] initWithDelegate:delegate];
    [parser parseChunk:indexData];
}

- (void)indexConcepts {
    for (Unit *unit in self.units) {
        for (Chapter *chapter in unit.chapters) {
            for (Concept *concept in chapter.concepts) {
                [self.orderedConcepts addObject:concept];
                [self.conceptsByPath setObject:concept forKey:concept.path];
            }
        }
    }
    for (Concept *concept in self.glossaryConcepts) {
        [self.conceptsByPath setObject:concept forKey:concept.path];
    }
    for (Concept *concept in self.answerConcepts) {
        [self.conceptsByPath setObject:concept forKey:concept.path];
    }
}


- (BOOL)conceptIsInTextbook:(Concept *)concept {
    return [self.orderedConcepts indexOfObject:concept] != NSNotFound;
}

- (BOOL)currentConceptIsInTextbook {
    return [self conceptIsInTextbook:self.currentConcept];
}

- (BOOL)conceptIsInGlossary:(Concept *)concept {
    return [self.glossaryConcepts indexOfObject:concept] != NSNotFound;
}

- (BOOL)currentConceptIsInGlossary {
	return [self conceptIsInGlossary:self.currentConcept];
}

- (BOOL)conceptIsAnswer:(Concept *)concept {
    return [self.answerConcepts indexOfObject:concept] != NSNotFound;
}

- (BOOL)currentConceptIsAnswer {
    return [self conceptIsAnswer:self.currentConcept];
}


static const char *UNIT_ELEMENT_NAME = "unit";

- (PCKXMLParserDelegate *)makeBookParserDelegate {
    PCKXMLParserDelegate *delegate = [[PCKXMLParserDelegate alloc] init];
    __block Unit *unit = nil;

    delegate.didStartElement = (PCKXMLParserDelegateBlock)^(const char *elementName) {
        if (unit) {
            [unit parser:nil didStartElement:elementName attributeCount:0 attributeData:nil];
        } else if (0 == strcmp(elementName, UNIT_ELEMENT_NAME)) {
            unit = [[Unit alloc] init];
        }
    };

    delegate.didEndElement = ^(const char *elementName) {
        if (0 == strcmp(elementName, UNIT_ELEMENT_NAME)) {
            [units_ addObject:unit];
             unit = nil;
        } else if (unit) {
            [unit parser:nil didEndElement:elementName];
        }
    };

    delegate.didFindCharacters = ^(const char *characters) {
        if (unit) {
            [unit parser:nil didFindCharacters:characters];
        }
    };

    return delegate;
}

static const char *CONCEPT_ELEMENT_NAME = "concept";

- (PCKXMLParserDelegate *)makeGlossaryParserDelegate {
    PCKXMLParserDelegate *delegate = [[PCKXMLParserDelegate alloc] init];
    __block Concept *concept = nil;

    delegate.didStartElement = (PCKXMLParserDelegateBlock)^(const char *elementName, int numAttributes, const char **attributes) {
        if (concept) {
            [concept parser:nil didStartElement:elementName attributeCount:numAttributes attributeData:attributes];
        } else if (0 == strcmp(elementName, CONCEPT_ELEMENT_NAME)) {
            concept = [[Concept alloc] init];
        }
    };

    delegate.didEndElement = ^(const char *elementName) {
        if (0 == strcmp(elementName, CONCEPT_ELEMENT_NAME)) {
            [glossaryConcepts_ addObject:concept];
             concept = nil;
        } else if (concept) {
            [concept parser:nil didEndElement:elementName];
        }
    };

    delegate.didFindCharacters = ^(const char *characters) {
        if (concept) {
            [concept parser:nil didFindCharacters:characters];
        }
    };

    return delegate;
}

@end
