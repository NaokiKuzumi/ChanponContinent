//
//  ChanponSettings.h
//  ChanponContinent
//
//  Created by Naoki Kuzumi on 10/05/20.
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
#import <OAuthConsumer/OAToken.h>

@interface ChanponSettings : NSObject {
	NSString *footerString;
}
+(id)sharedInstance;

+(void)setDefaults;

+(OAToken*)getAccessToken;
+(void)setAccessToken:(OAToken*)aToken;
+(void)removeAccessToken;


+(NSString*)getUsername;
+(void)setUserName:(NSString*)username;

+(float)getAlpha;
+(void)setAlpha:(float)aAlpha;

+(BOOL)getShouldComeFront;
+(void)setShouldComeFront:(BOOL)isFront;

+(NSUInteger)getPostKeyModifier;
+(void)setPostKeyModifier:(NSUInteger)modifierFlag;

-(NSString*)getFooter;
-(void)setFooter:(NSString*)newFooter;

+(BOOL)showTitleBar;
+(void)setShowTilteBar:(BOOL)doShow;



+(NSString*)commandIdentifier;
+(void)setCommandIdentifier:(NSString*)anIdentifier;
@end
