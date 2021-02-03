#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Day<SolutionType>: NSObject

/// Lazily reads in the input from input.txt in the same directory as the executable. Doesn't modify the string in any way.
/// TODO: It would be nice if this method prompted for a filepath if the input.txt couldn't be found locally
@property (nonatomic, readonly) NSString *input;
@property (nullable, readonly) SolutionType solution;

@end

NS_ASSUME_NONNULL_END
