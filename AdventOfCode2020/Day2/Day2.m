#import "Day.h"


typedef struct Policy {
    NSInteger minOccurences;
    NSInteger maxOccurences;
    unichar codeUnit;
    NSString *pwd;
} Policy;

@implementation NSString (CharacterCounter)

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

Policy parsePolicyFromCheckingResult(NSTextCheckingResult *regexResult, NSString* _Nonnull string) {
    assert(regexResult.resultType == NSTextCheckingTypeRegularExpression && "This must be used on a regex match");
    // 0. whole match 1. min 2. max 3. code unit 4. password
    assert(regexResult.numberOfRanges == 5);
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    Policy p = {};

    // Min
    NSRange minRange = [regexResult rangeAtIndex: 1];
    unichar *minSubstring= calloc(minRange.length, sizeof(unichar));
    [string getCharacters: minSubstring range: minRange];

    NSString *substring = [NSString stringWithCharacters: minSubstring length:minRange.length];
    free(minSubstring);
    NSNumber *parsed = [formatter numberFromString: substring];
    

    // Max
    NSRange maxRange = [regexResult rangeAtIndex: 2];
    unichar *maxSubstring = calloc(maxRange.length, sizeof(unichar));
    [string getCharacters:maxSubstring range:maxRange];

    NSString *backToString = [NSString stringWithCharacters:maxSubstring length:maxRange.length];
    free(maxSubstring);
    NSNumber *parsedMax = [formatter numberFromString:backToString];

    
    // Unichar
    NSRange charRange = [regexResult rangeAtIndex: 3];
    NSString *subStr = [string substringWithRange: charRange];
    // Assume just a single character. Actually per our regex, this should only be one and only one character
    unichar policyCharacter = [subStr characterAtIndex: 0];

    // Password
    NSRange pwdRange = [regexResult rangeAtIndex: 4];
    NSString *pwd = [string substringWithRange: pwdRange];
    [pwd retain]; // we'll say the struct owns the string points

    p.pwd = pwd;
    p.minOccurences = [parsed intValue];
    p.maxOccurences = [parsedMax intValue];
    p.codeUnit = policyCharacter;

    return p;

}
@interface Day2: Day

@end

@interface Day2 ()

@property (readonly, strong) NSRegularExpression *regex;

@end

@implementation Day2 {
    NSRegularExpression *_regex;
}

/// This regex property implicitly encodes the policy of Day2
- (NSRegularExpression *)regex {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _regex = [[NSRegularExpression alloc] initWithPattern: @"^(\\d+)-(\\d+)\\s+([A-z]):\\s+(.*)$" options:0 error: nil];
    });

    return _regex;
}

- (void)dealloc {
    [_regex release];
    [super dealloc];
}

- (NSString *)stringFromPolicy:(Policy)p {
    return [[NSString alloc] initWithFormat: @"Policy:\n\tMinimum Occurence Required: %ld\n\tMaximum Occurenece Required: %ld\n\tCharacter: %C\n\tPassword: %@",
           p.minOccurences, p.maxOccurences, p.codeUnit, p.pwd];
}

- (BOOL)policyCompliesWithEntry:(NSString *)entry {
    NSArray<NSTextCheckingResult *> *matches = [self.regex matchesInString:entry options:0 range: NSMakeRange(0, entry.length)];
    if (matches.count == 0) {
        return NO;
    }

    NSUInteger rangeCount = matches[0].numberOfRanges;
    NSRange firstMatch = [matches[0] rangeAtIndex:0];

    Policy p = parsePolicyFromCheckingResult(matches[0], entry);
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
