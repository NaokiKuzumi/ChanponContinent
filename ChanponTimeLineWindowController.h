//
//  ChanponTimeLineWindowController.h
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

#import <Cocoa/Cocoa.h>


@interface ChanponTimeLineWindowController : NSWindowController <NSTableViewDataSource,NSTableViewDelegate> {
	IBOutlet NSTableView* tlTable;
	
	NSMutableDictionary *TLData;
	NSTimer *reloadTimer;
}
// delegate
- (void)tableView:(NSTableView*)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn*)tableColumn row:(int)row; //TODO: <3とか#worldcupとか対応できたらいいな
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex;
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectTableColumn:(NSTableColumn *)aTableColumn;
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;

// datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
@end
