
This is very simple csv builder and parser.

This project is based on 
[Cocoa for Scientists (Part XXVI): Parsing CSV Data](http://www.macresearch.org/cocoa-scientists-part-xxvi-parsing-csv-data).

Thanks Drew McCormack,


##Usage

### building CSV format

<pre>
	NSArray *rows = [NSArray arrayWithObjects:
					 [NSArray arrayWithObjects:@"abc,def",@"ghi",nil],
					 [NSArray arrayWithObjects:@"1",@"2",@"3",nil],
					 nil];
	
	NSString* csvString = [rows CSVString];
</pre>


### parsing CSV format

#### parsing whole string at one time.
<pre>
	NSString* csvData = 
	@"1,2,3,4\n"
	@"1,2,3,4,5,6\n";
	
	NSArray* csvRows = [csvData CSVRows];
</pre>

#### parsing each row with enumerator

You can use enumerator style. If you want to parse huge number of csv rows, this method can be efficient. 

This don't mean streaming from NSData. Generally, csv file size is small (under 5 MB), but parsing time can be very long (10000 lines over).

<pre>
	NSEnumerator* en = [@"aaa,bbb,ccc\n"
						@"1,2,3\n" CSVEnumerator];
	
	NSString* row1   = [en nextObject];
	NSString* row2   = [en nextObject];
	NSString* NilRef = [en nextObject];
</pre>


##License

Free for use.


