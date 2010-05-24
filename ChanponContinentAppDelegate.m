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
// "TwitterAPIKey.h" is not added to the public repo. Make it like below.
/*
// the two keys you get after registering your app at http://twitter.com/apps
#define CONSUMER_KEY @""
#define CONSUMER_SECRET @""
*/

// used only in old unofficial BASIC authentication API. They don't use these strings anymore, so it's just for fun now.
#define CLIENT_NAME @"ChanponContinent"
#define CLIENT_VERSION @"0.07"
#define CLIENT_URL @"http://d.hatena.ne.jp/kudzu_naoki/20100519/1274258452"
#define CLIENT_TOKEN nil
// things you know
#define MAX_STATUS_LEN 140

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
	
	[window setPreventsApplicationTerminationWhenModal:NO];
	[authWindow setPreventsApplicationTerminationWhenModal:NO];
	
	[ChanponSettings setDefaults];
	[label setIntValue:MAX_STATUS_LEN];

#ifdef DEBUG
//	NSLog(@"is key window?: %d",[window isKeyWindow]);
//	showResponderChain([window firstResponder]);
	[window setTitle:@"CHANPON TEST"];
#endif
	
	[self _setKeyWindow];
	// load all settings
	[self _reloadSettings];
}

- (IBAction)settingsDone:(id)sender {
	[self _setKeyWindow];
	
	//first save the settings
	[ChanponSettings setAlpha:[alphaSlider floatValue]];
	if([comeFrontCheck state] == NSOnState){
		[ChanponSettings setShouldComeFront:YES];
	}else {
		[ChanponSettings setShouldComeFront:NO];
	}
	[NSApp endSheet: authWindow];
	//[authWindow close];
	[authWindow orderOut:self];
	[window makeKeyAndOrderFront:self];
	[self _reloadSettings];

}

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
	[label setIntValue:MAX_STATUS_LEN];
}

- (IBAction)resetAuthentication:(id)sender {
	[self _setAuthButtons:YES];
	[ChanponSettings setAccessToken:[[OAToken alloc] init]];
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

- (void)post2twitter {
	// http://apiwiki.twitter.com/Counting-Characters
	// look at the section "Unicode Normalization". They count characters using the normalizing Form C.
	NSString *treatedText = [statusString precomposedStringWithCanonicalMapping];
	treatedText = [commandController interpretCommand:treatedText];
    if ([treatedText length] > MAX_STATUS_LEN) {
        treatedText = [treatedText substringToIndex:MAX_STATUS_LEN];
    }
	
	NSLog(@"posting: %@",treatedText);
	[twitterEngine sendUpdate:treatedText];
//	[connectionDictionary [twitterEngine sendUpdate:treatedText]];
	[self clearStatusField];

	/*

	
	OAConsumer *consumer = [[OAConsumer alloc] initWithKey:CONSUMER_KEY
													secret:CONSUMER_SECRET];
	
	NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.xml"];
	
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																   consumer:consumer
																	  token:accessToken
																	  realm:nil 
														  signatureProvider:nil]; 
	//[request setOAuthParameterName:@"status" withValue:trimmedText];
	[request setHTTPMethod:@"POST"];
	
	OARequestParameter *statusParam = [[OARequestParameter alloc] initWithName:@"status" value:trimmedText];//[trimmedText dataUsingEncoding:NSUTF8StringEncoding];
	NSArray *params = [NSArray arrayWithObject:statusParam];
	[request setParameters:params];
	
	
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
	[fetcher fetchDataWithRequest:request
						 delegate:self
				didFinishSelector:@selector(postOfTicket:didFinishWithData:)
				  didFailSelector:@selector(postOfTicket:didFailWithError:)];
	*/
}

- (IBAction)showAuthenticateWindow:(id)sender {
	[NSApp beginSheet:authWindow modalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (IBAction)getPIN:(id)sender {
	//NSLog(@"get PIN start");
	OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:CONSUMER_KEY
                                                    secret:CONSUMER_SECRET] autorelease];
	
    NSURL *url = [NSURL URLWithString:@"http://twitter.com/oauth/request_token"];
	
    OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:nil   // we don't have a Token yet
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil] autorelease]; // use the default method, HMAC-SHA1
	
    [request setHTTPMethod:@"POST"];
	
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
}

- (IBAction) authenticateToken:(id)sender {
	OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:CONSUMER_KEY
                                                    secret:CONSUMER_SECRET] autorelease];
	
    NSURL *url = [NSURL URLWithString:@"http://twitter.com/oauth/access_token"];
	
    OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:requestToken
                                                                      realm:nil
                                                          signatureProvider:nil] autorelease];
	[request setOAuthParameterName:@"oauth_verifier" withValue:[pinField stringValue]];
	
    [request setHTTPMethod:@"POST"];
	
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(authenticateTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(authenticateTokenTicket:didFailWithError:)];
	
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
	[label setIntValue:MAX_STATUS_LEN - len];
	if(len > MAX_STATUS_LEN){
		[label setTextColor:[NSColor redColor]];
	}else {
		[label setTextColor:[NSColor blueColor]];
	}
	[label setEditable:NO];
}

#pragma mark OAuthConsumerDelegate Methods
// 汚いがもはや直す気はない！ 直す時はすなわち捨てる時、xAuthに移行する時だ！！
#pragma mark request Token

- (void) requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	if (ticket.didSucceed) {
		NSString *responseBody = [[[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding] autorelease];
		requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
		NSLog(@"got request token successfully");
		
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/oauth/authorize?oauth_token=%@",[requestToken key]]];
		[[NSWorkspace sharedWorkspace] openURL:url];
	}
}

-(void) requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error{
	NSLog(@"error on request token: %@ (%@)",[error localizedDescription],[error userInfo]);
}

#pragma mark authenticate Token
- (void) authenticateTokenTicket:(OAServiceTicket*)ticket didFinishWithData:(NSData *)data{
	if (ticket.didSucceed) {
		NSString *responseBody = [[[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding] autorelease];
		OAToken *accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
//		[accessToken storeInDefaultKeychainWithAppName:APPNAME_KEYCHAIN
//								   serviceProviderName:ASP_NAME];
		[ChanponSettings setAccessToken:accessToken];
		NSLog(@"got access token successfully");
		[twitterEngine setAccessToken:accessToken];
		[accessToken release];
	}
#ifdef DEBUG
	NSString *temp = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	NSLog(@"%@",temp);
	NSLog(@"recieved: %@",temp);
	[self _setAuthButtons:NO];
#endif
}

- (void) authenticateTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error{
	NSLog(@"error authenticate token: %@ (%@)",[error localizedDescription],[error userInfo]);
	[self _setAuthButtons:YES];
}
/*
#pragma mark post Status
- (void) postOfTicket:(OAServiceTicket*)ticket didFinishWithData:(NSData *)data{
	NSString *temp = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
	NSLog(@"%@",temp);
	if (ticket.didSucceed) {
		NSLog(@"post ok");
	}
	[label setTextColor:[NSColor blueColor]];
}
- (void) postOfTicket:(OAServiceTicket*)ticket didFailWithError:(NSError *)error{
	NSLog(@"post fail: %@ (%@)",[error localizedDescription],[error userInfo]);
	// maybe I should tell the users why their post has failed.
	[label setTextColor:[NSColor redColor]];
}
*/

#pragma mark miscSettings

- (IBAction)alphaValueChanged:(id)sender {
	[window setAlphaValue:[sender floatValue]/100];
}





#pragma mark MGTwitterEngineDelegate Methods

- (void)accessTokenReceived:(OAToken *)token forRequest:(NSString *)connectionIdentifier {
	
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
#ifdef DEBUG
		//		showResponderChain([window firstResponder]);
		//		[window makeKeyWindow];
		//		BOOL result = [window isKeyWindow];
		//		NSLog(@"keywindow:%d",result);
		//		showResponderChain([window firstResponder]);
#endif
	}else {
		[window setStyleMask:(NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask | NSTexturedBackgroundWindowMask)];
		[window setTitle:@"Chanpon Continent"];
#ifdef DEBUG
		[window setTitle:@"CHANPON TEST"];
		//		showResponderChain([window firstResponder]);
		//		BOOL result = [window isKeyWindow];
		//		NSLog(@"keywindow:%d",result);
		//		showResponderChain([window firstResponder]);
#endif
	}
	BOOL shouldComeFront = [ChanponSettings getShouldComeFront];
	if (shouldComeFront == NO){
		[window setLevel:NSNormalWindowLevel];
	}else {
		[window setLevel:NSFloatingWindowLevel];
	}
	
	// engines
	OAToken *accessToken = [ChanponSettings getAccessToken];	
	if(accessToken != nil && [accessToken.key compare:@""] != NSOrderedSame && [accessToken.secret compare:@""] != NSOrderedSame){
		[self _setAuthButtons:NO];
		[twitterEngine setAccessToken:accessToken];
	}else {
		[self _setAuthButtons:YES];
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
		[getPINButton setEnabled:YES];
		[pinField setEnabled:YES];
		[pinField setEditable:YES];
		[authButton setEnabled:YES];
		[resetButton setEnabled:NO];
	} else {
		[getPINButton setEnabled:NO];
		[pinField setEnabled:NO];
		[pinField setEditable:NO];
		[authButton setEnabled:NO];
		[resetButton setEnabled:YES];
	}
}



@end


