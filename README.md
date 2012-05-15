VCAlertViewQueue
================

A UIAlertView queue based around a priority ordering.

How it works
---------------

  Create a VCAlertViewQueue object, preferably as a singleton.
  Add an UIAlertView using 
  
    addAlertView:withPriority:

(The alerts are retained, so  you should release them before adding to queue)


The queue will present alerts based on their priority.

 The priorities are *LOW*, *MEDIUM*, *DEFAULT*, *HIGH*
 
<h3>Their interdependencies work as such <h3>
 
  LOW: 
  
      when Adding:    if ANY other alert present, this alert is discarded
      when already visible:   if a MED/DEF/HIGH alert is added when LOW is visible, LOW is dismissed
 
 MEDIUM
 
    when adding;    if LOW/MED alert present, that alert gets dismissed, this alert will be shown.
                    if DEF/HIGH alert present, this alert is discarded
 
    when already visible: when a MED/DEF/HIGH alert is queued up, this alert is dismissed
 
 DEFAULT
 
    when adding:    if LOW/MED present, they get dismissed, this gets show.
                    if DEFAULT present, this alert is shown over the present alert, no alerts are dismissed.
                    if HIGH present, this alert not shown but added to the queue, will be shown after all HIGH alerts are dismissed.
    
    when already visible:   when a DEF/HIGH queued up, this will get covered by the new alert, but not dismissed
 
 HIGH
 
    when adding:    gets shown unless there is another HIGH alert in the queue, in which case this alert is added to the queue. HIGH are presented in FIFO order
    when already visible:   nothing gets shown over an already visible HIGH alert! Any incomgin HIGH alerts are added to the queue in FIFO fashion.
    
