#import <Foundation/Foundation.h>

#import "Day.h"

NS_ASSUME_NONNULL_BEGIN
@interface Day3: Day

@end

@interface Day3 () {
@private
NSInteger _columns;
NSInteger _rows;
BOOL **_field;

@package
NSInteger _horizontalStep;
NSInteger _verticalStep;
}

// TODO: make it so this is generic rather than an ID
@property (nullable) id solution;

- (BOOL)treeAtSpaceRow:(NSInteger)row column:(NSInteger)column;
- (void)processInput;
- (void)solvePuzzle;

@end

@implementation Day3

- (BOOL)treeAtSpaceRow:(NSInteger)row column:(NSInteger)column {
    row = row % _rows;
    column = column % _columns;

    return _field[row][column] == NO;
}


- (void)processInput {
    NSString *input = [self input];
    
    NSArray<NSString *> *lines = [input componentsSeparatedByCharactersInSet: NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (lines.count < 1 || [lines[0] length] == 0) {
        // early exit
        return;
    }
    
    NSInteger columns = [lines[0] length];
    NSInteger rows = [[lines lastObject] length] == 0 ? lines.count - 1 : lines.count; // Ignore the last line if it just represents a trailing newline in the input
    [self allocateFieldWithColumns:columns rows:rows];

    [lines enumerateObjectsUsingBlock:^void (NSString *line, NSUInteger index, BOOL *stop) {
        if (line.length == 0) {
            assert(index == lines.count -1);
            return;
        }

        unichar buffer[columns];
        [line getCharacters:buffer range:NSMakeRange(0, line.length)];

        for (int i=0; i<line.length; i++) {
            if (buffer[i] == '#') {
                _field[index][i] = NO;
            } else if (buffer[i] == '.') {
                _field[index][i] = YES;
            } else {
                assert("Some bad info");
            }
        }
    }];

}

- (void)allocateFieldWithColumns:(NSInteger)cols rows:(NSInteger)rows {
    // Outer array
    _field = calloc(rows, sizeof(BOOL *));
    for (int row = 0; row < rows; row++) {
        _field[row] = calloc(cols, sizeof(BOOL));
    }
    _columns = cols;
    _rows = rows;
}

- (void)solvePuzzle {
    NSArray<NSString *> *lines = [self.input componentsSeparatedByCharactersInSet: NSCharacterSet.whitespaceAndNewlineCharacterSet];

    NSInteger currentRow = 0, currentColumn = 0, treesEncountered = 0;
    while (currentRow + _verticalStep < _rows) {
        currentRow += _verticalStep;
        currentColumn += _horizontalStep;
        if ([self treeAtSpaceRow:currentRow column:currentColumn]){
            treesEncountered++;
        }
    }
    self.solution = [NSNumber numberWithInteger:treesEncountered]; 
}

- (instancetype)init {
    if ((self = [super init])) {
        _verticalStep = 1;
        _horizontalStep = 3;
    }
    return self;

}
- (void)dealloc {
    for (int row = 0; row < _rows; row++) {
        free(_field[row]);
    }
    free(_field);
    [super dealloc];
}

@end

typedef struct _Slope {
    NSInteger x, y;
} Slope;

NS_ASSUME_NONNULL_END

int main(int argc, char *argv[]) {
    @autoreleasepool {
        // Part 1
        Day3 *day = [[[Day3 alloc] init] autorelease];
        [day processInput];
        [day solvePuzzle];
        NSLog(@"Solution is %@", day.solution);

        // Part 2
        NSInteger product = 1;
        Slope slopes[] = {{.x=1, .y=1}, { .x=3, .y=1}, {.x=5, .y=1}, {.x=7, .y=1}, {.x=1, .y=2}};
        int len = sizeof(slopes) / sizeof(*slopes);
        for (int i=0; i<len; i++) {
            day->_horizontalStep = slopes[i].x;
            day->_verticalStep = slopes[i].y;
            [day solvePuzzle];
            product *= [day.solution integerValue];
        }
        NSLog(@"Solution to pt 2 is %lu", product);
    }

}
