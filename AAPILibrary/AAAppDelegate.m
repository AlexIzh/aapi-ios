//
//  AAAppDelegate.m
//  AAPILibrary
//
//  Created by Andrew Kopanev on 4/18/14.
//  Copyright (c) 2014 Moqod. All rights reserved.
//

#import "AAAppDelegate.h"
#import "NSURL+AlterAPI.h"

@implementation AAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
		
	[NSURL setAaProjectId:@"sampleProjectId"];
	
	// 1. update url
	NSString *originalURLString = @"http://moqod.com";
	NSURL *url = [NSURL URLWithString:originalURLString];
	NSLog(@"url == %@", url);
	
	NSURL *url2 = [NSURL URLWithString:url.absoluteString];
	NSLog(@"url == %@", url2);
	
	// 2. exclude host
	[NSURL aaExcludeURLs:@"http://moqod.com", nil];
	url = [NSURL URLWithString:originalURLString];

	// 3. exclude path
	originalURLString = @"http://moqod.com/users/authorization";
	url = [NSURL URLWithString:originalURLString];
	NSLog(@"url == %@", url);
	
    return YES;
}

@end
