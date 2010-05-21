//
//  ChanponCommandController.m
//  ChanponContinent
//
//  Created by Naoki Kuzumi on 10/05/22.
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
#import "ChanponCommandController.h"
#import "ChanponSettings.h"

@implementation ChanponCommandController

-(ChanponCommandController*)initWithDelegate:(id)aDelegate {
	if(self = [super init]) {
		delegate = aDelegate;
	}
	return self;
}

-(NSString*)interpretCommand:(NSString *)statusString {
	NSString *identifier = [ChanponSettings commandIdentifier];
	
/*	if ([statusString length] > [identifier length] &&
		[statusString compare:identifier
					  options:NSCaseInsensitiveSearch 
						range:[identifier length]] == NSOrderedSame){
 */
	if ([statusString length] > [identifier length] &&
		[[statusString substringToIndex:[identifier length]] isEqualToString:identifier] == YES){
		
		//command
#ifdef DEBUG
		NSLog(@"command came");

		NSString *commandString = [statusString substringFromIndex:[identifier length]];
		NSLog(@"command: [%@]",commandString);
		if ([commandString isEqualToString:@"ちゃんぽん大陸"]) {
			return @"そう、ちゃんぽん大陸ならね。";
		}

		[delegate clearStatusField];
		return nil;
#endif		
		return statusString;
	}else {
#ifdef DEBUG
		NSLog(@"not a command");
#endif
		return statusString;
	}
}

@end
