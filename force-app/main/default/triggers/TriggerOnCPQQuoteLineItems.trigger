trigger TriggerOnCPQQuoteLineItems on SBQQ__QuoteLine__c (before insert,after insert,before update,after update) {
    if(trigger.isBefore && trigger.isInsert){
        //CPQQuoteLineTriggerHandler.beforetest(trigger.new);
        CPQQuoteLineTriggerHandler.handleCPQQuoteLineItem(trigger.new);
    }
    
    if(trigger.isAfter && trigger.isInsert){
        //CPQQuoteLineTriggerHandler.afterinsert(trigger.new,trigger.oldmap);
    }
    
    if(trigger.isBefore && trigger.isupdate){
        //CPQQuoteLineTriggerHandler.beforeupdate(trigger.new,trigger.oldmap);
    }
    if(trigger.isAfter && trigger.isupdate){
        //CPQQuoteLineTriggerHandler.afterupdate(trigger.new,trigger.oldmap);
    }
}