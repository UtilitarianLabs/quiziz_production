trigger MultischoolSubscriptionTrigger on Multischool_Subscription__c (before insert,After Insert,After Update) {
    
    if(Trigger.isUpdate && Trigger.isAfter){
        SubscriptionTriggerHandler.triggerBackendAPIForMultiSchool(Trigger.New);
    }
    
}