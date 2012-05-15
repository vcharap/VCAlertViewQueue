//
//  VCAlertViewQueueViewController.m
//  VCAlertViewQueue
//
//  Created by Victor Charapaev on 3/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "VCAlertViewQueueViewController.h"

@implementation VCAlertViewQueueViewController
@synthesize alertOrder;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
       // _alertQueue = [[VCAlertViewQueue alloc] init];
       // _alerts = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)awakeFromNib
{
    NSLog(@"Something goes here");
}

-(void)viewDidLoad
{
    _alertQueue = [[VCAlertViewQueue alloc] init];
    _alerts = [[NSMutableArray alloc] init];
}

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"low"]){
        [self lowPriorityAlert:self];
    }
    else if([title isEqualToString:@"medium"]){
        [self mediumPriorityAlert:self];
    }
    else if([title isEqualToString:@"default"]){
        [self defaultPriorityAlert:self];
    }
    else if([title isEqualToString:@"high"]){
        [self highPriorityAlert:self];
    }
    else if([title isEqualToString:@"clear"]){
        [_alertQueue clearCurrentAlert];
    }
}

-(UIAlertView*)alertWithStringPriority:(NSString*)priority
{
    return [[[UIAlertView alloc] initWithTitle:priority message:[NSString stringWithFormat:@"This is a %@ priority alert. Present another alert?", priority] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
}

-(NSString*)stringForPriority:(priority_t)priority
{
    switch(priority){
        case PRIORITY_LOW:
        {   
            return @"low";
            break;
        }
        case PRIORITY_MEDIUM:
        {
            return @"medium";
            break;
        }
        case PRIORITY_DEFAULT:
        {   
            return @"default";
            break;
        }
        case PRIORITY_HIGH:
        {
            return @"high";
        }
        default:{
            return nil;
        }
    }
}

-(NSDictionary*)dictionaryForAlertWithPriority:(priority_t)priority
{
    return [NSDictionary dictionaryWithObjectsAndKeys:[self alertWithStringPriority:[self stringForPriority:priority]], @"alert", [NSNumber numberWithInt:priority], @"priority", nil];
}

-(IBAction)lowPriorityAlert:(id)sender
{
    alertOrder.text = [alertOrder.text stringByAppendingFormat:@"%@ + ", [self stringForPriority:PRIORITY_LOW]];
    [_alerts addObject:[self dictionaryForAlertWithPriority:PRIORITY_LOW]];
    
}
-(IBAction)mediumPriorityAlert:(id)sender
{
    alertOrder.text = [alertOrder.text stringByAppendingFormat:@"%@ + ", [self stringForPriority:PRIORITY_MEDIUM]];
    [_alerts addObject:[self dictionaryForAlertWithPriority:PRIORITY_MEDIUM]];
}
-(IBAction)defaultPriorityAlert:(id)sender
{
    alertOrder.text = [alertOrder.text stringByAppendingFormat:@"%@ + ", [self stringForPriority:PRIORITY_DEFAULT]];
    [_alerts addObject:[self dictionaryForAlertWithPriority:PRIORITY_DEFAULT]];
}
-(IBAction)highPriorityAlert:(id)sender
{
    alertOrder.text = [alertOrder.text stringByAppendingFormat:@"%@ + ", [self stringForPriority:PRIORITY_HIGH]];
    [_alerts addObject:[self dictionaryForAlertWithPriority:PRIORITY_HIGH]];
}

-(IBAction)ignoreAlerts:(id)sender
{
    _alertQueue.ignoreAlerts =  ((UISwitch*)sender).on;
    
}
-(IBAction)supressAlerts:(id)sender
{
    _alertQueue.supressAlerts = ((UISwitch*)sender).on;
}

-(IBAction)presentAlerts
{
    //present alerts over some period of time
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [timer fire];
}

-(void)timerFired:(NSTimer*)timer
{
    if([_alerts count]){
        NSDictionary *dictionary = [_alerts objectAtIndex:0];
        [_alertQueue addAlertView:[dictionary objectForKey:@"alert"] withPriority:[[dictionary objectForKey:@"priority"] intValue]];
        
        [_alerts removeObjectAtIndex:0];
    }
    else{
        alertOrder.text = @"";
        [timer invalidate];
    }
}

@end
