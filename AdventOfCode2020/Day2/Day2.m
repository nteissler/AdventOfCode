#import "Day.h"


typedef struct Policy {
    NSInteger minOccurences;
    NSInteger maxOccurences;
    unichar codeUnit;
    NSString *pwd;
} Policy;

@implementation NSString (CharacterCounter)

/// Convenience method for counting how many times a character occurs in a string.
/// - Returns: the number of occurences
-(NSInteger)countOfCharacter:(unichar)character {
    unichar buffer[self.length]; 
    [self getCharacters: buffer range: NSMakeRange(0, self.length)];
    int count = 0;

    for (int i=0; i < self.length; i++) {
        if (buffer[i] == character) count++;
    }
    return count;
}

@end

#pragma mark - Day2
@interface Day2: Day

@end

@interface Day2 ()

/// The regular expression used for interpreting the day's input (single line)
@property (readonly, retain) NSRegularExpression *regex;

/// Used for parsing numbers from `NSString`s
@property (readonly, retain) NSNumberFormatter *numFormatter;

- (Policy)parsePolicyFromCheckingResult:(NSTextCheckingResult *)regexResult input:(NSString*)input;

@end

@implementation Day2 {
    NSRegularExpression *_regex;
}

@synthesize numFormatter = _numFormatter;

/// This regex property implicitly encodes the policy of Day2
- (NSRegularExpression *)regex {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _regex = [[NSRegularExpression alloc] initWithPattern: @"^(\\d+)-(\\d+)\\s+([A-z]):\\s+(.*)$" options:0 error: nil];
    });

    return _regex;
}

- (NSNumberFormatter *)numFormatter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _numFormatter = [NSNumberFormatter new];
    });

    return _numFormatter;
}

- (void)dealloc {
    [_regex release];
    [_numFormatter release];
    [super dealloc];
}

- (NSString *)stringFromPolicy:(Policy)p {
    return [[NSString alloc] initWithFormat: @"Policy:\n\tMinimum Occurence Required: %ld\n\tMaximum Occurenece Required: %ld\n\tCharacter: %C\n\tPassword: %@",
           p.minOccurences, p.maxOccurences, p.codeUnit, p.pwd];
}

- (Policy)parsePolicyFromCheckingResult:(NSTextCheckingResult *)regexResult input:(nonnull NSString *)input {
    assert(regexResult.resultType == NSTextCheckingTypeRegularExpression && "This must be used on a regex match");

    Policy p = {};
    // 0. Whole match 1. Min 2. Max 3. Code unit 4. Password
    if (regexResult.numberOfRanges != 5) {
        return p;
    }

    // For this parsing, it'd probably be better to use the NSString API -[substringWithRange:];

    // Min
    NSRange minRange = [regexResult rangeAtIndex: 1];
    unichar *minBuffer = calloc(minRange.length, sizeof(unichar));
    [input getCharacters:minBuffer range:minRange];

    NSString *minSubstring = [NSString stringWithCharacters:minBuffer length:minRange.length];
    free(minBuffer);
    NSNumber *parsed = [self.numFormatter numberFromString:minSubstring];
    

    // Max
    NSRange maxRange = [regexResult rangeAtIndex: 2];
    unichar *maxBuffer = calloc(maxRange.length, sizeof(unichar));
    [input getCharacters:maxBuffer range:maxRange];

    NSString *maxSubstring = [NSString stringWithCharacters:maxBuffer length:maxRange.length];
    free(maxBuffer);
    NSNumber *parsedMax = [self.numFormatter numberFromString:maxSubstring];

    
    // Unichar
    NSRange charRange = [regexResult rangeAtIndex: 3];
    unichar policyCharacter = '\0';
    // Assume just a single character. Actually per our regex, this should only be one and only one character
    [input getCharacters:&policyCharacter range:charRange];

    // Password
    NSRange pwdRange = [regexResult rangeAtIndex: 4];
    NSString *pwd = [input substringWithRange: pwdRange];
    [pwd retain]; // we'll say the struct owns the pwd pointers

    p.pwd = pwd;
    p.minOccurences = [parsed intValue];
    p.maxOccurences = [parsedMax intValue];
    p.codeUnit = policyCharacter;

    NSLog(@"policy %@", [self stringFromPolicy:p]);

    return p;
}


- (BOOL)policyCompliesWithEntry:(NSString *)entry {
    NSArray<NSTextCheckingResult *> *matches = [self.regex matchesInString:entry options:0 range: NSMakeRange(0, entry.length)];
    if (matches.count == 0) {
        return NO;
    }

    NSUInteger rangeCount = matches[0].numberOfRanges;
    NSRange firstMatch = [matches[0] rangeAtIndex:0];

    Policy p = [self parsePolicyFromCheckingResult:matches[0] input:entry];
/* Part 1
    NSInteger count = [p.pwd countOfCharacter:p.codeUnit];
    BOOL meetsPolicy = (count <= p.maxOccurences) && (count >= p.minOccurences);
*/
    /* Part 2 */
    BOOL meetsPolicy = [p.pwd characterAtIndex:p.minOccurences-1] == p.codeUnit ^ [p.pwd characterAtIndex:p.maxOccurences-1] == p.codeUnit;
    [p.pwd release];

    return meetsPolicy;
}

@end


// Given an NSTextCheckingResult, we want to parse that into a struct representing a policy

int main(int argc, char *argv[]) {
    @autoreleasepool {
        Day2 *d2 = [[Day2 new] autorelease];

        // Split input into lines
        NSArray<NSString *> *entries = [d2.input componentsSeparatedByCharactersInSet: NSCharacterSet.newlineCharacterSet];

        NSInteger count = 0;

        for (NSString *entry in entries) {
            if ([d2 policyCompliesWithEntry: entry]) {
                count++;
            }
        }
        NSLog(@"%ld complied with policy", count);
        return count;
    }
}
