//
//  ChanponSettings.m
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


#import "ChanponSettings.h"

#import "OAuthConsumer/OAToken.h"


// a string key used to save the token in the keychain.
#ifndef DEBUG
#define APPNAME_KEYCHAIN @"ChanponContinent"
#else
#define APPNAME_KEYCHAIN @"ChanponContinentTest"
#endif
#define ASP_NAME @"twitter.com"

@implementation ChanponSettings

static id _instance = nil;

+(id)sharedInstance {
	@synchronized(self) {
        if (!_instance) {
            [[self alloc] init];
        }
    }
    return _instance;
}

+ (id)allocWithZone:(NSZone*)zone {
    @synchronized(self) {
        if (!_instance) {
            _instance = [super allocWithZone:zone];
            return _instance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone*)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return UINT_MAX;
}

- (void)release {
}

- (id)autorelease {
    return self;
} 


+(void)setDefaults {
	NSDictionary* appDefaults = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
																		[NSNumber numberWithFloat:1.0],
																		@"YES",
																		@"NO",
																		@":",
																		[NSNumber numberWithUnsignedInteger:NSControlKeyMask],
																		@"",
																		nil]
															forKeys:[NSArray arrayWithObjects:
																		@"alpha",
																		@"showTitleBar",
																		@"front",
																		@"commandIdentifier",
																		@"postKeyModifier",
																		@"footer",
																		nil]];
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	
}

+(OAToken*)getAccessToken {
	return [[[OAToken alloc] initWithKeychainUsingAppName:APPNAME_KEYCHAIN
							  serviceProviderName:ASP_NAME] autorelease];
}

+(void)setAccessToken:(OAToken*)aToken {
	if(aToken != nil){
		[aToken storeInDefaultKeychainWithAppName:APPNAME_KEYCHAIN
							  serviceProviderName:ASP_NAME];
	}
}

+(void)removeAccessToken {
	[OAToken removeFromKeyChainWithAppName:APPNAME_KEYCHAIN
					   serviceProviderName:ASP_NAME];
}

+(NSString*)getUsername{
	return [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
}

+(void)setUserName:(NSString*)username{
	[[NSUserDefaults standardUserDefaults] setObject:username forKey:@"username"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(float)getAlpha {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults floatForKey:@"alpha"] / 100;
}

+(void)setAlpha:(float)aFloat {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setFloat:aFloat forKey:@"alpha"];
	[defaults synchronize];
}

+(BOOL)getShouldComeFront {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"front"];
}

+(void)setShouldComeFront:(BOOL)isFront {
	[[NSUserDefaults standardUserDefaults] setBool:isFront forKey:@"front"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


+(NSUInteger)getPostKeyModifier {
	return [[[NSUserDefaults standardUserDefaults] objectForKey:@"postKeyModifier"] unsignedIntegerValue];
}

+(void)setPostKeyModifier:(NSUInteger)modifierFlag {
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithUnsignedInteger:modifierFlag] forKey:@"postKeyModifier"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)getFooter {
	return footerString;
	//return [[NSUserDefaults standardUserDefaults] objectForKey:@"footer"];
}

-(void)setFooter:(NSString*)newFooter {
	if (footerString) {
		[footerString release];
	}
	footerString = [newFooter copy];
//	[[NSUserDefaults standardUserDefaults] setObject:footerString forKey:@"footer"];
//	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)showTitleBar {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"showTitleBar"];
}

+(void)setShowTilteBar:(BOOL)doShow {
	[[NSUserDefaults standardUserDefaults] setBool:doShow forKey:@"showTitleBar"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString*)commandIdentifier {
	return [[NSUserDefaults standardUserDefaults] stringForKey:@"commandIdentifier"];
}

+(void)setCommandIdentifier:(NSString*)anIdentifier{
	// TODO
}

@end
