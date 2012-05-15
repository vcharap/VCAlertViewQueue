//
//  VCAlertViewQueueAppDelegate.h
//  VCAlertViewQueue
//
//  Created by Victor Charapaev on 3/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VCAlertViewQueueViewController;

@interface VCAlertViewQueueAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet VCAlertViewQueueViewController *viewController;

@end
