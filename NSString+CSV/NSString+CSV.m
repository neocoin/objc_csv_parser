

@interface CSVEnumerator : NSEnumerator
{
	NSString* _dataStr;
	
	NSMutableCharacterSet *_newlineCharacterSet;
	NSMutableCharacterSet *_importantCharactersSet;
	NSScanner *_scanner;
}
@end

@implementation CSVEnumerator

- (id)initWithString:(NSString*)dataStr{
	if (self = [super init]) {
		_dataStr = [dataStr retain];
		
		// Get newline character set
		_newlineCharacterSet = [[NSMutableCharacterSet whitespaceAndNewlineCharacterSet] retain];
		[_newlineCharacterSet formIntersectionWithCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];
		
		// Characters that are important to the parser
		_importantCharactersSet = [[NSMutableCharacterSet characterSetWithCharactersInString:@",\""] retain];
		[_importantCharactersSet formUnionWithCharacterSet:_newlineCharacterSet];
		
		// Create scanner, and scan string
		_scanner = [[NSScanner scannerWithString:_dataStr] retain];
		[_scanner setCharactersToBeSkipped:nil];		
	}
	return self;
}

- (void)dealloc{
	[_newlineCharacterSet release];
	[_importantCharactersSet release];
	[_scanner release];
	[_dataStr release];
	[super dealloc];
}

/*
 Baseed source is
 http://www.macresearch.org/cocoa-scientists-part-xxvi-parsing-csv-data
 Original code have last blank text ignoring bug, so two line fixed. See 'FIXED' marks
 */
- (id)nextObject{
	if ([_scanner isAtEnd]) {
		return nil;
	}
	NSMutableArray *columns = [NSMutableArray arrayWithCapacity:10];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	BOOL insideQuotes = NO;
	BOOL finishedRow = NO;
	NSMutableString *currentColumn = [NSMutableString string];
	while ( !finishedRow ) {
		NSString *tempString;
		if ( [_scanner scanUpToCharactersFromSet:_importantCharactersSet intoString:&tempString] ) {
			[currentColumn appendString:tempString];
		}
		
		if ( [_scanner isAtEnd] ) {
			//FIXED if ( ![currentColumn isEqualToString:@""] ) [columns addObject:currentColumn];
			if ( (![currentColumn isEqualToString:@""]) || ([columns count] > 0) ) [columns addObject:currentColumn];
			finishedRow = YES;
		}
		else if ( [_scanner scanCharactersFromSet:_newlineCharacterSet intoString:&tempString] ) {
			if ( insideQuotes ) {
				// Add line break to column text
				[currentColumn appendString:tempString];
			}
			else {
				// End of row
				//FIXED if ( ![currentColumn isEqualToString:@""] ) [columns addObject:currentColumn];
				[columns addObject:currentColumn];
				finishedRow = YES;
			}
		}
		else if ( [_scanner scanString:@"\"" intoString:NULL] ) {
			if ( insideQuotes && [_scanner scanString:@"\"" intoString:NULL] ) {
				// Replace double quotes with a single quote in the column string.
				[currentColumn appendString:@"\""]; 
			}
			else {
				// Start or end of a quoted string.
				insideQuotes = !insideQuotes;
			}
		}
		else if ( [_scanner scanString:@"," intoString:NULL] ) {  
			if ( insideQuotes ) {
				[currentColumn appendString:@","];
			}
			else {
				// This is a column separating comma
				[columns addObject:currentColumn];
				currentColumn = [NSMutableString string];
				[_scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
			}
		}
	}	
	[pool drain];	
	
	return columns;
}

- (id)allObjects{
	@throw([NSException exceptionWithName:@"CSVEnumeratorException" 
								   reason:@"Do not support 'allObjects' method." 
								 userInfo:nil]);
	return nil;
}
@end

#pragma mark -

@implementation NSString (CSV)

- (NSEnumerator*)CSVEnumerator{	
	return [[[CSVEnumerator alloc] initWithString:self] autorelease];
}

- (NSArray*)CSVRows{
    NSMutableArray *rows = [NSMutableArray array];
	NSEnumerator* en = [self CSVEnumerator];
	
	id obj = nil;
	while (obj = [en nextObject]) {
		[rows addObject:obj];
	}
	return rows;
}

- (NSString*)CSVEscapedString {
	NSString* s = self;
	
	NSString * escapedString = s;
    BOOL containsSeperator = !NSEqualRanges([s rangeOfString:@","], NSMakeRange(NSNotFound, 0));
    BOOL containsQuotes = !NSEqualRanges([s rangeOfString:@"\""], NSMakeRange(NSNotFound, 0));
    BOOL containsLineBreak = !NSEqualRanges([s rangeOfString:@"\n"], NSMakeRange(NSNotFound, 0));
	
    if (containsQuotes) {
        escapedString = [escapedString stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
    }
	
    if (containsSeperator || containsLineBreak) {
        escapedString = [NSString stringWithFormat:@"\"%@\"", escapedString];
    }
    return escapedString;
}

@end

