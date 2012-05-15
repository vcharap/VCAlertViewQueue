//
//  VCAlertViewQueue.m
//  VCAlertViewQueue
//
//  Created by Victor Charapaev on 3/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//



static NSString *kAlertViewKey = @"AlertViewKey";
static NSString *kPriorityKey = @"PriorityKey";

#import "VCAlertViewQueue.h"

@interface VCAlertViewQueue()
@property (retain) NSMutableArray *highPriorityAlerts;
@property (retain) NSMutableArray *defaultPriorityAlerts;

@property (retain) UIAlertView *currentAlert;
@property priority_t currentAlertPriority;

//helper functions!

/* Makes passed in alert the current alert */
-(void)makeCurrentAlert:(UIAlertView*)alert withPriority:(priority_t)priority;

/* current alert is removed from view, alert property and priority is cleared */
-(void)clearCurrentAlert;

/* Calls addAlert:withPriority: on main thread. 
 UIAlertView and priority are passed through dictionary with keys kAlertViewKey, kPriorityKey
*/
-(void)addAlertOnMainThread:(NSDictionary*)arguments;

/*
 Function checks for next alert,   
*/
-(void)showNextAlert;

@end

@implementation VCAlertViewQueue

#pragma mark getters / setters
@synthesize highPriorityAlerts = _highPriorityAlerts, defaultPriorityAlerts = _defaultPriorityAlerts;
@synthesize currentAlert = _currentAlert, currentAlertPriority = _currentAlertPriority;
@synthesize supressAlerts = _supressAlerts, ignoreAlerts = _ignoreAlerts;

-(void)setSupressAlerts:(BOOL)supress
{
    @synchronized(self){
        if(supress != _supressAlerts){
            _supressAlerts = supress;
            
            if(!supress){
                [self showNextAlert];
            }
        }
    }
}

#pragma mark Public Methods

-(id)init
{
    self = [super init];
    if(self){
        _defaultPriorityAlerts = [[NSMutableArray alloc] init];
        _highPriorityAlerts = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)dealloc
{
    [_currentAlert release];
    [_defaultPriorityAlerts release];
    [_highPriorityAlerts release];
    [super dealloc];
}

/* Public Methods*/

-(void)addAlertView:(UIAlertView *)alertView withPriority:(priority_t)priority
{
    
    if(self.ignoreAlerts) return;
    
    //operate on main thread only
    if([NSThread currentThread] != [NSThread mainThread]){
        [self performSelector:@selector(addAlertOnMainThread:) 
                     onThread:[NSThread mainThread] 
                   withObject:[NSDictionary dictionaryWithObjectsAndKeys:alertView, kAlertViewKey, [NSNumber numberWithInt:priority], kPriorityKey, nil] 
                waitUntilDone:NO];
        return;
    }
    
    switch(priority){
        case PRIORITY_LOW:
        {
            //low priority alert show only when there are no other alerts present, and alerts are not supressed
            if(!self.currentAlert && !self.supressAlerts){
                [self makeCurrentAlert:alertView withPriority:priority];
                [self.currentAlert show];
            }
            break;
        }
        case PRIORITY_MEDIUM:
        {
            if(self.supressAlerts) return;
            
            //show MEDIUM alert only if LOW/MEDIUM ALERTS PRESENT
            if(self.currentAlertPriority == PRIORITY_LOW || self.currentAlertPriority == PRIORITY_MEDIUM){
                [self clearCurrentAlert];
            }
            
            if(self.currentAlertPriority == PRIORITY_NULL){
                [self makeCurrentAlert:alertView withPriority:priority];
                [self.currentAlert show];
            }
            break;
        }
            
        case PRIORITY_DEFAULT:
        {
            if([self.defaultPriorityAlerts count]){
                UIAlertView *previousAlert = [self.defaultPriorityAlerts lastObject];
                previousAlert.hidden = YES;
            }
            
            [self.defaultPriorityAlerts addObject:alertView];
            
            if(self.supressAlerts) return;
            
            if(self.currentAlert){
                if(self.currentAlertPriority == PRIORITY_LOW || self.currentAlertPriority == PRIORITY_MEDIUM){
                    [self clearCurrentAlert];
                }
            }
                 
            if(self.currentAlertPriority != PRIORITY_HIGH){
                [self makeCurrentAlert:alertView withPriority:priority];
                [self.currentAlert show];
            }
            
            break;
        }
        case PRIORITY_HIGH:
        {
            [self.highPriorityAlerts addObject:alertView];
            
            if(self.supressAlerts) return;
            
            if(self.currentAlert){
                if(self.currentAlertPriority == PRIORITY_LOW || self.currentAlertPriority == PRIORITY_MEDIUM){
                    [self clearCurrentAlert];
                }
            }
            
            if(self.currentAlertPriority != PRIORITY_HIGH){
                [self makeCurrentAlert:alertView withPriority:priority];
                [self.currentAlert show];
            }
        }
        default:
        {
            break;
        }
    
    }
}

-(void)removeAllAlerts
{
    [self clearCurrentAlert];
    
    for(UIAlertView *alert in self.highPriorityAlerts){
        [alert removeFromSuperview];
    }
    [self.highPriorityAlerts removeAllObjects];
    
    for(UIAlertView *alert in self.defaultPriorityAlerts){
        [alert removeFromSuperview];
    }
    [self.defaultPriorityAlerts removeAllObjects];
}

#pragma mark Private Methods

-(void)addAlertOnMainThread:(NSDictionary *)arguments
{
    [self addAlertView:[arguments objectForKey:kAlertViewKey] withPriority:[[arguments objectForKey:kPriorityKey] intValue]];
}

-(void)makeCurrentAlert:(UIAlertView *)alert withPriority:(priority_t)priority
{
    self.currentAlertPriority = priority;
    
    if(self.currentAlert){
        if(self.currentAlert != alert){
            self.currentAlert.delegate = _realAlertViewDelegateRef;
        }
    }
    
    _realAlertViewDelegateRef = alert.delegate;
    alert.delegate = self;
    self.currentAlert = alert;
}

-(void)clearCurrentAlert
{
    if(self.currentAlert){
        self.currentAlert.delegate = nil;
        [self.currentAlert dismissWithClickedButtonIndex:self.currentAlert.cancelButtonIndex animated:NO];
        
        /*
        if([_realAlertViewDelegateRef respondsToSelector:@selector(alertViewCancelledByQueue:)]){
            [(id <VCAlertViewQueueDelegate> )_realAlertViewDelegateRef alertViewCancelledByQueue:self.currentAlert];
        }
        */
        
        self.currentAlert = nil;
        _realAlertViewDelegateRef = nil;
    }
    
    self.currentAlertPriority = PRIORITY_NULL;
}

-(void)showNextAlert
{
    if([self.highPriorityAlerts count]){
        [self makeCurrentAlert:[self.highPriorityAlerts objectAtIndex:0] withPriority:PRIORITY_HIGH];
        [self.currentAlert show];
    }
    else if([self.defaultPriorityAlerts count]){
        [self makeCurrentAlert:[self.defaultPriorityAlerts lastObject] withPriority:PRIORITY_DEFAULT];
        
        self.currentAlert.hidden = NO;
        
        if(!self.currentAlert.superview){
            [self.currentAlert show];
        }
    }
}

#pragma mark UIAlertView Delegate callbacks

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //
    if(self.currentAlert == alertView){
        if(self.currentAlertPriority == PRIORITY_DEFAULT){
            [self.defaultPriorityAlerts removeLastObject];
        } 
        else if(self.currentAlertPriority == PRIORITY_HIGH){
            [self.highPriorityAlerts removeObjectAtIndex:0];
        }
        [self clearCurrentAlert];
        
        if(!self.supressAlerts){
            [self showNextAlert];
        }
        
    }
    
    if([_realAlertViewDelegateRef respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]){
        [_realAlertViewDelegateRef alertView:alertView didDismissWithButtonIndex:buttonIndex];
    }
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([_realAlertViewDelegateRef respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]){
        [_realAlertViewDelegateRef alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
/*
- (void)alertViewCancel:(UIAlertView *)alertView
{
    if([_realAlertViewDelegateRef respondsToSelector:@selector(alertViewCancel:)]){
        [_realAlertViewDelegateRef alertViewCancel:alertView];
    }
}
*/

- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if([_realAlertViewDelegateRef respondsToSelector:@selector(willPresentAlertView:)]){
        [_realAlertViewDelegateRef willPresentAlertView:alertView];
    }
}
- (void)didPresentAlertView:(UIAlertView *)alertView
{
    if([_realAlertViewDelegateRef respondsToSelector:@selector(didPresentAlertView:)]){
        [_realAlertViewDelegateRef didPresentAlertView:alertView];
    }
}
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if([_realAlertViewDelegateRef respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]){
        [_realAlertViewDelegateRef alertView:alertView willDismissWithButtonIndex:buttonIndex];
    }
}



// Called after edits in any of the default fields added by the style

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if([_realAlertViewDelegateRef respondsToSelector:@selector(alertViewShouldEnableFirstOtherButton:)]){
        return [_realAlertViewDelegateRef alertViewShouldEnableFirstOtherButton:alertView];
    }
    
    return NO;
}

@end
