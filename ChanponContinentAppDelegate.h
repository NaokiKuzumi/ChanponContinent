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
#import "ChanponCommandController.h"

@interface ChanponContinentAppDelegate : NSObject <NSApplicationDelegate,MGTwitterEngineDelegate> {
	// controls two windows.
	// main tweet window & settings window.
	// TODO: should've made window controller for each window, and use app delegate as an app delegate.
	
	// main window stuffs
    NSWindow *window;
	IBOutlet NSTextField *label,*footerLabel;
	IBOutlet NSTextView *statusField;
	IBOutlet NSProgressIndicator *progressIndicator;

	// settings window stuffs
	IBOutlet NSTabView* settingsTab;
	// tab 1
	NSWindow *authWindow;
	IBOutlet NSTextField *usernameField,*passwordField;
	IBOutlet NSTextField *authConditionLabel;
	IBOutlet NSProgressIndicator *authIndicator;
	IBOutlet NSSlider *alphaSlider;
	IBOutlet NSButton *authButton,*resetButton;
	// tab 2
	IBOutlet NSButton *comeFrontCheck;
	// tab 3
	IBOutlet NSMatrix *postKeyMatrix;
	IBOutlet NSButtonCell *commandPost,*controlPost,*shiftPost,*altPost; // post key
	
	// else
	MGTwitterEngine *twitterEngine;
	NSMutableDictionary *connectionDictionary;
	ChanponCommandController *commandController;
	OAToken *requestToken;//,*accessToken;
	NSMutableDictionary* TLBaseDataDictionary;
	NSTimer *reloadTimer;
	NSString *statusString;
	
}
- (IBAction)showAuthenticateWindow:(id)sender;

- (IBAction)authenticate:(id)sender;
- (IBAction)resetAuthentication:(id)sender;

- (IBAction)alphaValueChanged:(id)sender;
- (void)toggleTitleBar:(id)sender;
- (IBAction)settingsDone:(id)sender;

-(void)clearStatusField;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *authWindow;
@property (assign) NSMutableDictionary *TLBaseDataDictionary;
//@property (assign) MGTwitterEngine *twitterEngine;

@end
