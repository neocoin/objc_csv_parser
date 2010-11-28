
#import "NSString+CSV.h"
#import "NSArray+CSV.h"


@implementation NSArray(CSV)

- (NSString*)CSVString{
	NSMutableString* csv = [NSMutableString stringWithCapacity:[self count]*100];
	
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSUInteger length = [self count], i, j;
	for (i = 0; i < length; i++) {
		NSArray* row = [self objectAtIndex:i];

		NSUInteger rowLen = [row count];
		for (j = 0; j < rowLen; j++) {
			NSString* c = [row objectAtIndex:j];
			[csv appendString:[c CSVEscapedString]];
			if (j < rowLen-1) 
				[csv appendString:@","];
		}
		
		if (i < length-1)
			[csv appendString:@"\n"];		
	}
	
	[pool release];
	
	return csv;
}

@end
