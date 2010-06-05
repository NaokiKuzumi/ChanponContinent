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
	NSMutableString *treatedString = [NSMutableString stringWithString:statusString];
	
	if ([statusString length] > [identifier length] &&
		[[statusString substringToIndex:[identifier length]] isEqualToString:identifier] == YES){
		
		NSString *commandString = [statusString substringFromIndex:[identifier length]];
		
#ifdef DEBUG
		NSLog(@"command came");		
		NSLog(@"command: [%@]",commandString);
#endif	
		
		// :chanpon command.		
		if ([commandString isEqualToString:@"chanpon"] || [commandString isEqualToString:@"champon"]) {
			switch (rand() % 9) {
				case 0:
					treatedString = [NSMutableString stringWithString:@"感性を阻害しない唯一のtwitterクライアント。 *ChanponContinent*"];
					break;
				case 1:
					treatedString = [NSMutableString stringWithString:@"SnowLeopardだと、投稿力の変わらないただひとつのtwitterクライアントが使えないって？　ちゃんぽん大陸があるじゃないか！ *ChanponContinent*"];
					break;
				case 2:
					treatedString = [NSMutableString stringWithString:@"革命的で魔法のようなクライアント。しかも、信じられないネーミングで。 *ChanponContinent*"];
					break;
				case 3:
					treatedString = [NSMutableString stringWithString:@"呟きのプロから愛されたクライアントをご家庭や仕事場にも。 *ChanponContinent*"];
					break;
				case 4:
					treatedString = [NSMutableString stringWithString:@"きみもちゃんぽん大陸に上陸してみないかい？ *ChanponContinent*"];
					break;
				case 5:
					treatedString = [NSMutableString stringWithString:@"TLなんて気にするな。君の発言もみんな気にしてないんだから。 *ChanponContinent*"];
					break;
				case 6:
					treatedString = [NSMutableString stringWithString:@"いつでも変わらぬ投稿力であなたを待っている。そう、ちゃんぽん大陸ならね。 *ChanponContinent*"];
					break;
				case 7:
					treatedString = [NSMutableString stringWithString:@"なるほどちゃんぽん大陸じゃねーの *ChanponContinent*"];
					break;
				default:
					treatedString = [NSMutableString stringWithString:@"そう、ちゃんぽん大陸ならね *ChanponContinent*"];
					break;
			}
			return treatedString; // we need no footers or so now.
		}
		
		// :footer command

		if([commandString length] >= 6 &&
		   [[commandString substringToIndex:6] isEqualToString:@"footer"]){
			NSString *footer;
			if ([commandString length] >= 6) {
				footer = [commandString substringFromIndex:6];
			}else {
				footer = nil;
			}
			[[ChanponSettings sharedInstance] setFooter:footer];
			[delegate refreshFooter];
		}

		[delegate clearStatusField];
	
		return nil;		
	}
		
	// ここでフッター挿入とかする。
	if ([[ChanponSettings sharedInstance] getFooter] != nil) {
#ifdef DEBUG
		NSLog(@"footer: %@",[[ChanponSettings sharedInstance] getFooter]);
#endif
		treatedString = [NSString stringWithFormat:@"%@%@",statusString,[[ChanponSettings sharedInstance] getFooter]];
	}

	return treatedString;
}

@end
