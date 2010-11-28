
#import "CSVTestCase.h"
#import "NSString+CSV.h"
#import "NSArray+CSV.h"

@implementation CSVTestCase

#pragma mark -
#pragma mark building
// http://tools.ietf.org/html/rfc4180
- (void)testEscapeStringToCSVFormat{
	STAssertEqualObjects([@"first" CSVEscapedString],
						 @"first", 
						 @"no change with no special character");
	
	STAssertEqualObjects([@"\"" CSVEscapedString],
						 @"\"\"",
						 @"quote to double quote");
	
	STAssertEqualObjects([@"," CSVEscapedString],
						 @"\",\"",
						 @"seperator is wrapped quotes");
	
	STAssertEqualObjects([@"\n" CSVEscapedString],
						 @"\"\n\"",
						 @"new line  is wrapped quotes");
	
	STAssertEqualObjects([@"aa,bb,\"cc\"" CSVEscapedString],
						 @"\"aa,bb,\"\"cc\"\"\"",
						 @"complex example1");
	
	STAssertEqualObjects([@"aa,bb,\"cc\"\n" CSVEscapedString],
						 @"\"aa,bb,\"\"cc\"\"\n\"",
						 @"complex example1");
}

- (void)testMakeCSVStringWithNSArray{
	NSArray *rows = [NSArray arrayWithObjects:
					 [NSArray arrayWithObjects:@"abc,def",@"ghi",nil],
					 [NSArray arrayWithObjects:@"1",@"2",@"3",nil],
					 nil];
	
	STAssertEqualObjects([rows CSVString], 
						 @"\"abc,def\",ghi\n" 
						 @"1,2,3"
						 ,@"csv string from 2d array");
}




#pragma mark -
#pragma mark parsing

- (void)testBasicParsing
{
	NSString* csvData = 
	@"1,2,3,4\n"
	@"1,2,3,4,5,6\n";
	
	NSArray* csvRows = [csvData CSVRows];

	STAssertEquals((NSUInteger)2, [csvRows count],
				   @"Failed to check row count %d", [csvRows count]);
	
	NSArray* row1 = [csvRows objectAtIndex:0];
	NSArray* expectedRow1 = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",nil];
	STAssertEqualObjects(row1, expectedRow1, @"first row");
}

- (void)testIgnoreEmptyRow{
	NSString* csvData = 
	@"1,2,3,4\n"
	@"\n"
	@"1,2,3,4,5,6\n";
	
	NSArray* csvRows = [csvData CSVRows];
	
	STAssertEquals((NSUInteger)2, [csvRows count],
				   @"Failed to check row count %d", [csvRows count]);

	NSArray* row1 = [csvRows objectAtIndex:0];
	NSArray* expectedRow1 = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",nil];
	STAssertEqualObjects(row1, expectedRow1, @"first row");
	
}

- (void)testPasringEnumerator{
	NSEnumerator* en = [@"aaa,bbb,ccc\n"
						@"1,2,3\n" CSVEnumerator];
	NSArray* row, *expectedRow;
	
	row = [en nextObject];
	expectedRow = [NSArray arrayWithObjects:@"aaa",@"bbb",@"ccc",nil];
	STAssertEqualObjects(row,expectedRow,@"first row");

	row = [en nextObject];
	expectedRow = [NSArray arrayWithObjects:@"1",@"2",@"3",nil];
	STAssertEqualObjects(row,expectedRow,@"second row");
	
	STAssertNil([en nextObject],@"nil");
}

- (void)testParsingInRFC4180{
	NSArray* rows, *expectedRows;
	
	NSString* csvString2_6 = 
	@"\"aaa\",\"b \n"
	@"bb\",\"ccc\"\n"
	@"zzz,yyy,xxx";
	
	rows = [csvString2_6 CSVRows];
	expectedRows = [NSArray arrayWithObjects:
					[NSArray arrayWithObjects:@"aaa", @"b \nbb",@"ccc",nil],
					[NSArray arrayWithObjects:@"zzz",@"yyy",@"xxx",nil],
					nil];
	STAssertEqualObjects(rows, expectedRows,@"RFC4180 2-6" );

	
	NSString* csvString2_7 = @"\"aaa\",\"b\"\"bb\",\"ccc\"";
	
	rows = [csvString2_7 CSVRows];
	expectedRows = [NSArray arrayWithObjects:
					[NSArray arrayWithObjects:@"aaa", @"b\"bb",@"ccc",nil],
					nil];
	STAssertEqualObjects(rows, expectedRows,@"rfc4180 2-6" );
	STAssertEqualObjects([expectedRows CSVString], @"aaa,b\"\"bb,ccc",@"RFC4180 2-6" );
}




@end
