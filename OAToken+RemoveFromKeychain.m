//
//  OAToken+RemoveFromKeychain.m
//  ChanponContinent
//
//  Created by Naoki Kuzumi on 10/05/25.
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

#import "OAuthConsumer/OAToken.h"
#import <Security/Security.h>

@interface OAToken (RemoveFromKeychain)

+(int)removeFromKeyChainWithAppName:(NSString*)appName serviceProviderName:(NSString*)aspName;

@end

@implementation OAToken (RemoveFromKeychain)
+(int)removeFromKeyChainWithAppName:(NSString*)appName serviceProviderName:(NSString*)aspName {
	SecKeychainItemRef item;
	NSString *serviceName = [NSString stringWithFormat:@"%@::OAuth::%@", appName, aspName];
	OSStatus status = SecKeychainFindGenericPassword(NULL,
													 strlen([serviceName UTF8String]),
													 [serviceName UTF8String],
													 0,
													 NULL,
													 NULL,
													 NULL,
													 &item);
    if (status != errSecSuccess) {
        return status;
    }
	status = SecKeychainItemDelete(item);
	
	return status;
}
@end
