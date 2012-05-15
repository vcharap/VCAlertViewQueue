//
//  VCAlertViewQueueViewController.h
//  VCAlertViewQueue
//
//  Created by Victor Charapaev on 3/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCAlertViewQueue.h"

@interface VCAlertViewQueueViewController : UIViewController <UIAlertViewDelegate>
{
    VCAlertViewQueue *_alertQueue;
    NSMutableArray *_alerts;
    UILabel *alertOrder;
}

@property (retain) IBOutlet UILabel *alertOrder;

-(IBAction)lowPriorityAlert:(id)sender;
-(IBAction)mediumPriorityAlert:(id)sender;
-(IBAction)defaultPriorityAlert:(id)sender;
-(IBAction)highPriorityAlert:(id)sender;

-(IBAction)ignoreAlerts:(id)sender;
-(IBAction)supressAlerts:(id)sender;

-(IBAction)presentAlerts;
@end
