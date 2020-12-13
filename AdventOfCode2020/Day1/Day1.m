#import <Foundation/Foundation.h>

// Hidden GCD method for benchmarking:
extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));


static NSMutableArray<NSNumber *>* years;
static NSString * const inputFile = @"./input.txt";

static void scanInput();
static NSInteger find2020Pair();
static NSInteger find2020Triplet();

int main(int argc, char *argv[]) {
	@autoreleasepool {
		scanInput();
		
		__block NSInteger solution = -1;
		uint64_t t = dispatch_benchmark(10, ^{
			@autoreleasepool {
				solution = find2020Triplet();
			}
		});
		
		NSLog(@"Avg. Runtime over 10 iterations: %f seconds", (double)t / NSEC_PER_SEC);
		NSLog(@"The answer is %ld", (long)solution);
	}
}

@interface PairSumIndex: NSObject {
	@package
	int a;
	int b;
	NSInteger pairSum;
}
@end

@implementation PairSumIndex
@end

void scanInput() {
	years = [NSMutableArray array];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSData *data = [fileManager contentsAtPath:inputFile];
	
	NSString *allInput = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
	NSScanner *scanner = [[NSScanner alloc] initWithString:allInput];
	NSInteger num = 0;
	while ([scanner scanInteger:&num]) {
		@autoreleasepool {
			[years addObject:[NSNumber numberWithInt:num]];
		}
	}

}

/// Returns the product of the 2020 pair
NSInteger find2020Pair() {
	for (int first = 0; first < years.count - 1; first++) { // The comparison of the final two numbers is done as years[n-2], years[n-1] for n elements
		for (int second = first + 1; second < years.count; second++) {
			int a = years[first].integerValue;
			int b = years[second].integerValue;
			if (a + b == 2020) {
				return a * b;
			}
		}
	}
	return -1;
}

/// Returns the product of the 2020 triplet
/// precondition: Years has been parsed and read in
static NSInteger find2020Triplet() {
	// Create the smallest possible array of all sums
	NSInteger n = (NSInteger)years.count;
	NSInteger nC2 = n * (n - 1) / 2;
	
	NSMutableArray<PairSumIndex *> * const sumPairs = [[[NSMutableArray alloc] initWithCapacity:nC2] autorelease];
	
	int counter = 0;
	for (int i = 0; i < n - 1; i++) {
		for (int j = 1+i; j < n; j++, counter++) {
			@autoreleasepool { // ~20,000 iterations for an input size of 200 lines
				// No real need for this fancy math, as we can just take a counter outside this loop.
				// I was trying to get around having to encode the indices in, but can't figure out how to do that.
				/*
				int intermediateSum = (n-i) * (n-(i + 1)) / 2; // sum of n - i - 1 down to zero
				int calculatedIndex = (nC2 - 1) - intermediateSum + (j - i);
				NSLog(@"Calculated index %d for the sum of pre-index %d and %d", calculatedIndex, i, j);
				*/
				
				PairSumIndex *p = [[PairSumIndex new] autorelease];
				NSInteger pairSum = years[i].integerValue + years[j].integerValue;
				p->a = i;
				p->b = j;
				p->pairSum = pairSum;
				[sumPairs insertObject:p atIndex:counter];
			}
		}
	}
	
	// Once we have the array, find the third number that makes 2020 without wasting work adding the same combindations multiple times.
	int i, k;
	for (k = 0; k < years.count; k++) {
		for (i = 0; i < sumPairs.count; i++) {
			NSInteger tripleSum = years[k].integerValue + sumPairs[i]->pairSum;
			if (tripleSum == 2020) goto DONE;
		}
	}
	
	// If we found nothing, bail out
	return -1;
	
	DONE: // It's AOC after all. Gotta put it in a block though: http://clang-developers.42468.n3.nabble.com/Objective-C-in-goto-label-block-td4030560.html
	{
		// Otherwise, decompose the combined index and return the product.
		// The answer is the elemenets in years at a, b, and k
		PairSumIndex *p = sumPairs[i];
		int a = p->a;
		int b = p->b;
		return years[a].integerValue * years[b].integerValue * years[k].integerValue;
	}
} 