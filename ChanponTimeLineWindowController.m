//
//  ChanponTimeLineWindowController.m
//  ChanponContinent
//
//  Created by Naoki Kuzumi on 10/06/05.
//
//  Copyright 2010 Naoki Kuzumi
//  Licensed under the Apache License, Version 2.0 (the "License"); 
//  you may not use this file except in compliance with the License. 
//  You may obtain a copy of the License at 
//
//      http://www.apache.org/licenses/LICENSE-2.0 
//
//  Unless required by applicable law or agreed to in writing, 
//  software distributed under the License is distributed on an "AS IS" BASIS, 
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
//  See the License for the specific language governing permissions and 
//  limitations under the License. 
//


#import "ChanponTimeLineWindowController.h"


@implementation ChanponTimeLineWindowController
static NSColor*	_whiteColor = nil;
static NSColor*	_stripeColor = nil;


NSInteger idsort(id tweet1, id tweet2, void* context){
	NSNumber *num1 = [tweet1 objectForKey:@"id"];
	NSNumber *num2 = [tweet1 objectForKey:@"id"];
	
	return [num1 compare:num2];
}

NSInteger timesort(id tweet1,id tweet2, void* context){
	NSDate *date1 = [tweet1 objectForKey:@"created_at"];
	NSDate *date2 = [tweet2 objectForKey:@"created_at"];
	
	return [date2 compare:date1]; // [date2 compare date1] だとlatestが上にくる。
}
/*
-(id)initWithWindowNibName:(NSString *)windowNibName {
	if(self = [super initWithWindowNibName:windowNibName]) {
		
	}
}
*/
- (void)awakeFromNib {
	[tlTable setDataSource:self]; // not using the app delegate for filtering
	[tlTable setDelegate:self];
	TLData = [[NSApp delegate] TLBaseDataDictionary];
	[tlTable reloadData];
	reloadTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(update) userInfo:nil repeats:YES];
}

- (void)update {
	//[tlTable noteNumberOfRowsChanged];
	[tlTable reloadData];
}

#pragma mark dataSource methods

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    NSArray *TLArray = [[TLData allValues] sortedArrayUsingFunction:timesort context:NULL];
	id theTweet,theValue;
//	NSArray *TLArray = [TLData allValues];
	
	theTweet = [TLArray objectAtIndex:rowIndex];
	if([[aTableColumn identifier] isEqualToString:@"username"]){
		theValue = [[theTweet objectForKey:@"user"] objectForKey:@"name"];
	}else {
		theValue = [theTweet objectForKey:[aTableColumn identifier]];
	}
	
    return theValue;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [TLData count];
}

#pragma mark delegate methods

- (void)tableView:(NSTableView*)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)tableColumn row:(int)row {
    if (!_whiteColor) {
        _whiteColor = [NSColor whiteColor];
		// couldn't find out the color name that the finder uses.
		if([NSColor currentControlTint] == NSBlueControlTint){
			_stripeColor = [[NSColor colorWithCalibratedRed:0.77 green:0.88 blue:1.0 alpha:0.5] retain];
		} else { 
			_stripeColor = [[NSColor colorWithCalibratedWhite:0.90 alpha:1.0] 
							retain];

		}
        //_stripeColor = [[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.8 alpha:1.0] retain];
		//_stripeColor = [NSColor colorForControlTint:[NSColor currentControlTint]];

    }
    
    // セルの背景色を設定する
    [cell setDrawsBackground:YES];
    if (row % 2 == 1) {
        [cell setBackgroundColor:_stripeColor];
    }
    else {
        [cell setBackgroundColor:_whiteColor];
    }
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
	return YES;
}
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectTableColumn:(NSTableColumn *)aTableColumn {
	return NO;
}
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	return NO;
}


- (void)dealloc {
	[tlTable release];
	if([reloadTimer isValid]) {
		[reloadTimer invalidate];
	}
	if(_whiteColor){
		[_whiteColor release];
		[_stripeColor release];
	}
}


@end
