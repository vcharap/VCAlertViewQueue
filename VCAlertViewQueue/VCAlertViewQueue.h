//
//  VCAlertViewQueue.h
//  VCAlertViewQueue
//
//  Created by Victor Charapaev on 3/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//


/*
 VCAlertViewQueue is a queue like object for dealing with UIAlertViews
 
 The queue works based on a priority ordering.
 The priorities are LOW < MEDIUM < DEFAULT < HIGH
 
 Their interdependencies work as such
 
 LOW: 
    when Adding:    if ANY other alter present, this alert is discarded
    when already visible:   if a MED/DEF/HIGH alert is added when LOW is visible, LOW is dismissed
 
 MEDIUM
    when adding;    if LOW/MED alert present, that alert gets dismissed, this alert will be shown.
                    if DEF/HIGH alert present, this alert is discarded
 
    when already visible: when a MED/DEF/HIGH alert is queued up, this alert is dismissed
 
 DEFAULT
    when adding:    if LOW/MED present, they get dismissed, this gets show.
                    if DEFAULT present, this alert is shown over the present alert, no alerts are dismissed - DEF are presented in LIFO order
                    if HIGH present, this alert not shown but added to the queue, will be shown after all HIGH alerts are dismissed.
    
    when already visible:   when a DEF/HIGH queued up, this will get covered by the new alert, but not dismissed
 
 HIGH
    when adding:    gets shown unless there is another HIGH alert in the queue, in which case this alert is added to the queue. HIGH are presented in FIFO order
    when already visible:   nothing gets shown over an already visible HIGH alert! Any incomgin HIGH alerts are added to the queue in FIFO fashion.
    
*/
#import <Foundation/Foundation.h>

@protocol VCAlertViewQueueDelegate <NSObject>
@optional
-(void)alertViewCancelledByQueue:(UIAlertView*)alertView; 
@end


typedef enum
{
    PRIORITY_NULL = 0,
    PRIORITY_LOW,
    PRIORITY_MEDIUM,
    PRIORITY_DEFAULT, 
    PRIORITY_HIGH
    
} priority_t;

@interface VCAlertViewQueue : NSObject <UIAlertViewDelegate>
{

@private
    NSMutableArray *_highPriorityAlerts;
    NSMutableArray *_defaultPriorityAlerts;
    UIAlertView *_currentAlert;    
    priority_t _currentAlertPriority;
    
    id <UIAlertViewDelegate> _realAlertViewDelegateRef;
    
    BOOL _supressAlerts;
    BOOL _ignoreAlerts;
}


/* setting this to YES will make the queue ignore any LOW/MEDIUM alerts being queued up. 
    Any DEFAULT/HIGH alerts will be added to the queue, but not show until 
    the property is set to NO
 */
@property BOOL supressAlerts;

/* setting this to YES will make the queue ignore any alerts being queued up. */
@property BOOL ignoreAlerts;

/* add alert to the queue with priority. */
-(void)addAlertView:(UIAlertView*)alertView withPriority:(priority_t)priority;

/* clears the queue of all alerts */
-(void)removeAllAlerts;


@end
