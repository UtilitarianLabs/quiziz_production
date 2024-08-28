trigger SubScriptionTrigger on SBQQ__Subscription__c (before insert,After Insert,After Update) {
    
    if(Trigger.isUpdate && Trigger.isAfter){
        SubscriptionTriggerHandler.triggerBackendAPI(Trigger.New);
    }

}