//
//  ChanponContinentAppDelegate.m
//  ChanponContinent
//
//  Created by Naoki Kuzumi on 10/05/18.
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

#import "ChanponContinentAppDelegate.h"
#import "ChanponSettings.h"
#import "OAuthConsumer/OAuthConsumer.h"
#import "MGTwitterEngine.h"

#import "TwitterAPIKey.h" 

// used only in old unofficial BASIC authentication API. They don't use these strings anymore, so it's just for fun now.
#define CLIENT_NAME @"ChanponContinent"
#define CLIENT_VERSION @"0.13"
#define CLIENT_URL @"http://d.hatena.ne.jp/kudzu_naoki/20100519/1274258452"
#define CLIENT_TOKEN nil
// things you know
#define MAX_STATUS_LEN 140

// connection identifing object
#define CONNECTION_AUTH @"AuthConnection"

#ifdef DEBUG
// from http://hmdt.jp/cocoaProg/AppKit/NSResponder/NSResponder.html#section03
// 
void showResponderChain(NSResponder* responder)
{
    NSLog(@"- Show responder chain?   ");
    
    while(true) {
        NSLog(@"%@", NSStringFromClass([responder class]));
        responder = [responder nextResponder];
        
        if(responder == nil) {
            break;
        }
        printf("-> ");
	}
}
	
#endif

@interface ChanponContinentAppDelegate (PrivateMethod)
-(void)_reloadSettings;
-(void)_setKeyWindow;
-(void)_setAuthButtons:(BOOL)enableAuth;
@end


@implementation ChanponContinentAppDelegate

@synthesize window,authWindow;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	twitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
	[twitterEngine setClientName:CLIENT_NAME version:CLIENT_VERSION URL:CLIENT_URL token:CLIENT_TOKEN];
	[twitterEngine setConsumerKey:CONSUMER_KEY secret:CONSUMER_SECRET];
	connectionDictionary = [[NSMutableDictionary alloc] init];
	
	commandController = [[ChanponCommandController alloc] initWithDelegate:self];
	
	
	// set can quit on setting view.
	[window setPreventsApplicationTerminationWhenModal:NO];
	[authWindow setPreventsApplicationTerminationWhenModal:NO];
	
	[ChanponSettings setDefaults];
	[label setIntValue:MAX_STATUS_LEN];
	[controlPost setRepresentedObject:[NSNumber numberWithUnsignedInteger:NSControlKeyMask]];
	[commandPost setRepresentedObject:[NSNumber numberWithUnsignedInteger:NSCommandKeyMask]];
	[shiftPost setRepresentedObject:[NSNumber numberWithUnsignedInteger:NSShiftKeyMask]];
	[altPost setRepresentedObject:[NSNumber numberWithUnsignedInteger:NSAlternateKeyMask]];

#ifdef DEBUG
//	NSLog(@"is key window?: %d",[window isKeyWindow]);
//	showResponderChain([window firstResponder]);
	[window setTitle:@"CHANPON TEST"];
#endif
	
	[self _setKeyWindow];
	// load all settings
	[self _reloadSettings];
}

- (IBAction)settingsDone:(id)sender {	// save all the settings 
	[self _setKeyWindow];
	
	[ChanponSettings setAlpha:[alphaSlider floatValue]];
	
	if([comeFrontCheck state] == NSOnState){
		[ChanponSettings setShouldComeFront:YES];
	}else {
		[ChanponSettings setShouldComeFront:NO];
	}
	
	NSEnumerator *enumerator= [[postKeyMatrix cells] objectEnumerator];
	id obj = nil;
	NSUInteger mask = 0;
	while (obj = [enumerator nextObject]){
		if([obj state] == NSOnState){
			mask = mask + [[obj representedObject] unsignedIntegerValue];
		}
	}
	[ChanponSettings setPostKeyModifier:mask];
	

	[NSApp endSheet: authWindow];
	[authWindow orderOut:self];
	[window makeKeyAndOrderFront:self];
	[self _reloadSettings];

}

- (void)refreshFooter {
	[footerLabel setEditable:YES];
	[footerLabel setStringValue:[[ChanponSettings sharedInstance] getFooter]];
	[footerLabel setEditable:NO];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}

- (void)setString: (NSString *) newValue {
	// a setter for statusString. it
    if (statusString != newValue) {
        if (statusString) [statusString release];
        statusString = [newValue copy];
	}
}

#pragma mark Main Window

- (void)toggleTitleBar:(id)sender {
	if ([ChanponSettings showTitleBar] == YES) {
		[ChanponSettings setShowTilteBar:NO];
	} else {
		[ChanponSettings setShowTilteBar:YES];
	}
	[self _reloadSettings];
}

- (void)clearStatusField {
	[[statusField textStorage] setAttributedString:[[[NSAttributedString alloc] initWithString:@""] autorelease]];
	[self textDidChange:nil];
}

- (void)post2twitter {
	// http://apiwiki.twitter.com/Counting-Characters
	// look at the section "Unicode Normalization". They count characters using the normalizing Form C.
	NSString *treatedText = [statusString precomposedStringWithCanonicalMapping];
	treatedText = [commandController interpretCommand:treatedText];
    if ([treatedText length] > MAX_STATUS_LEN) {
		return;
//		treatedText = [treatedText substringToIndex:MAX_STATUS_LEN];
    }
	
	NSLog(@"posting: %@",treatedText);
	[twitterEngine sendUpdate:treatedText];
	[self clearStatusField];

}

- (IBAction)showAuthenticateWindow:(id)sender {
	[NSApp beginSheet:authWindow modalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

#pragma mark Auth Window

- (IBAction)authenticate:(id)sender {
	NSString* connectionIdentifier = [twitterEngine getXAuthAccessTokenForUsername:[usernameField stringValue] password:[passwordField stringValue]];
	[connectionDictionary setObject:CONNECTION_AUTH forKey:connectionIdentifier];
	[authIndicator startAnimation:self];
}

- (IBAction)resetAuthentication:(id)sender {
	[self _setAuthButtons:YES];
	[ChanponSettings removeAccessToken];
}

- (void)dealloc {
	[twitterEngine release];
	[connectionDictionary release];
	[commandController release];
	 if (statusString) [statusString release];
	
	[super dealloc];
}

#pragma mark modalTextFieldDelegate

- (void) textDidChange:(NSNotification *)aNotification {
	[self setString: [statusField string]];
	NSString *normalizedText = [statusString precomposedStringWithCanonicalMapping];
	[label setEditable:YES];
	NSInteger len = [normalizedText length];
	NSInteger footerlen = [[[ChanponSettings sharedInstance] getFooter] length];
	[label setIntValue:MAX_STATUS_LEN - len - footerlen];
	if((len + footerlen) > MAX_STATUS_LEN){
		[label setTextColor:[NSColor redColor]];
	}else {
		[label setTextColor:[NSColor blueColor]];
	}
	[label setEditable:NO];
}

#pragma mark miscSettings

- (IBAction)alphaValueChanged:(id)sender {
	[window setAlphaValue:[sender floatValue]/100];
}

#pragma mark MGTwitterEngineDelegate Methods

- (void)accessTokenReceived:(OAToken *)token forRequest:(NSString *)connectionIdentifier {
	[ChanponSettings setAccessToken:token];
	[ChanponSettings setUserName:[usernameField stringValue]];
	[authIndicator stopAnimation:self];
	[self _setAuthButtons:NO];
}

- (void)connectionStarted:(NSString *)connectionIdentifier {
	[progressIndicator startAnimation:self];
}
- (void)connectionFinished:(NSString *)connectionIdentifier {
	if([twitterEngine numberOfConnections] == 0) {
		[progressIndicator stopAnimation:self];
	}
}

- (void)requestSucceeded:(NSString *)connectionIdentifier
{
    NSLog(@"Request succeeded for connectionIdentifier = %@", connectionIdentifier);

	[label setTextColor:[NSColor blueColor]];
}


- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error
{
    NSLog(@"Request failed for connectionIdentifier = %@, error = %@ (%@)", 
          connectionIdentifier, 
          [error localizedDescription], 
          [error userInfo]);
	NSString* connectionFor = [connectionDictionary objectForKey:connectionIdentifier];
	if ([connectionFor compare:CONNECTION_AUTH] == NSOrderedSame) {
		[authIndicator stopAnimation:self];
		[authConditionLabel setEditable:YES];
		[authConditionLabel setTextColor:[NSColor redColor]];
		[authConditionLabel setStringValue:@"Authentication Failed"];
		[authConditionLabel setEditable:NO];
	}
	[label setTextColor:[NSColor redColor]];
}

#pragma mark PrivateMethods

- (void)_reloadSettings {
	// window settings
	float alpha = [ChanponSettings getAlpha];
	if(alpha != 0) {
		[alphaSlider setFloatValue:alpha * 100];
		[window setAlphaValue:alpha];
	}
	BOOL showTitleBar = [ChanponSettings showTitleBar];
	if (showTitleBar == NO) {
		[window setStyleMask:NSBorderlessWindowMask | NSTexturedBackgroundWindowMask];
	}else {
		[window setStyleMask:(NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask | NSTexturedBackgroundWindowMask)];
		[window setTitle:@"Chanpon Continent"];
#ifdef DEBUG
		[window setTitle:@"CHANPON TEST"];
#endif
	}
	BOOL shouldComeFront = [ChanponSettings getShouldComeFront];
	if (shouldComeFront == NO){
		[window setLevel:NSNormalWindowLevel];
		[comeFrontCheck setState:NSOffState];
	}else {
		[window setLevel:NSFloatingWindowLevel];
		[comeFrontCheck setState:NSOnState];
	}
	// auth window settings
	if ([ChanponSettings getUsername] != nil) {
		[usernameField setStringValue:[ChanponSettings getUsername]];
	}
	NSUInteger postKeyMask = [ChanponSettings getPostKeyModifier];
	if (postKeyMask & NSControlKeyMask) {
		[controlPost setState:NSOnState];
	}else {
		[controlPost setState:NSOffState];
	}
	if (postKeyMask & NSShiftKeyMask) {
		[shiftPost setState:NSOnState];
	}else {
		[shiftPost setState:NSOffState];
	}
	if (postKeyMask & NSCommandKeyMask) {
		[commandPost setState:NSOnState];
	}else {
		[commandPost setState:NSOffState];
	}
	if (postKeyMask & NSAlternateKeyMask){
		[altPost setState:NSOnState];
	}else {
		[altPost setState:NSOffState];
	}
	

		


	// engines
	OAToken *accessToken = [ChanponSettings getAccessToken];	
	if(accessToken != nil && [accessToken.key compare:@""] != NSOrderedSame && [accessToken.secret compare:@""] != NSOrderedSame){
		[self _setAuthButtons:NO];
		[twitterEngine setAccessToken:accessToken];
	}else {
		[self _setAuthButtons:YES];
		[settingsTab selectFirstTabViewItem:self];
		[self showAuthenticateWindow:self];
	}
	
}

- (void)_setKeyWindow {
	// for unknown reason, titleless window can't be the key window.
	// it should be set to proper style by _reloadSettings.
	[window setStyleMask:(NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask | NSTexturedBackgroundWindowMask)];
	[window makeKeyWindow];
}

-(void)_setAuthButtons:(BOOL)enableAuth {
	if(enableAuth == YES){
		[authButton setEnabled:YES];
		[resetButton setEnabled:NO];
		[authConditionLabel setEditable:YES];
		[authConditionLabel setTextColor:[NSColor blackColor]];
		[authConditionLabel setStringValue:@"Not authenticated"];
		[authConditionLabel setEditable:NO];
	} else {
		[authButton setEnabled:NO];
		[resetButton setEnabled:YES];
		[authConditionLabel setEditable:YES];
		[authConditionLabel setTextColor:[NSColor greenColor]];
		[authConditionLabel setStringValue:@"O.K."];
		[authConditionLabel setEditable:NO];
	}
}



@end


