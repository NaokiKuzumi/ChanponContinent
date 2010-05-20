//
//  ChanponContinentAppDelegate.h
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

#import <Cocoa/Cocoa.h>
#import <OAuthConsumer/OAToken.h>
#import "MGTwitterEngine.h"

@interface ChanponContinentAppDelegate : NSObject <NSApplicationDelegate,MGTwitterEngineDelegate> {
	// controls all views
	
	// main window stuffs
    NSWindow *window;
	IBOutlet NSTextField *label;
	IBOutlet NSTextView *statusField;
	NSString *statusString;
	// settings window stuffs
	// tab 1
	NSWindow *authWindow;	
	IBOutlet NSTextField *pinField;
	IBOutlet NSSlider *alphaSlider;
	IBOutlet NSButton *getPINButton,*authButton,*resetButton;
	// tab 2
	IBOutlet NSButton *comeFrontCheck;
	// else
	MGTwitterEngine *twitterEngine;
	OAToken *requestToken;//,*accessToken;
}
- (IBAction)showAuthenticateWindow:(id)sender;

// TODO: change authentication method to xAuth.
- (IBAction)getPIN:(id)sender;
- (IBAction)authenticateToken:(id)sender;
- (IBAction)resetAuthentication:(id)sender;

- (IBAction)alphaValueChanged:(id)sender;
- (void)toggleTitleBar:(id)sender;
- (IBAction)settingsDone:(id)sender;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *authWindow;

@end
