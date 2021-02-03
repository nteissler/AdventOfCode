#import <Foundation/Foundation.h>

#import "Day.h"

NS_ASSUME_NONNULL_BEGIN

@implementation Day {
	NSString *_input;
}


- (NSString *)input {
	static dispatch_once_t pred;
	dispatch_once(&pred, ^{
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSData *data = [fileManager contentsAtPath:@"./input.txt"];		
		_input = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	});
	assert(_input.length != 0);
	return [[_input retain] autorelease];
}

- (void)dealloc
{
	[_input release];
	[super dealloc];
}

@end
NS_ASSUME_NONNULL_END
