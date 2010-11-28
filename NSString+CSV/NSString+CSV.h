
// http://tools.ietf.org/html/rfc4180 + empty line ignore
// http://www.macresearch.org/cocoa-scientists-part-xxvi-parsing-csv-data

@interface NSString(CSV)

#pragma mark -
#pragma mark parsing
- (NSEnumerator*)CSVEnumerator;
- (NSArray*)CSVRows;

#pragma mark -
#pragma mark building
- (NSString*)CSVEscapedString;

@end
