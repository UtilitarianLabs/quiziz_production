trigger AccountTrigger on Account (before insert) {
    
    if(trigger.isbefore){
        if(trigger.isinsert){
            AccountTriggerHelper.UpdateAccountFields(trigger.new);
        }
    }

}