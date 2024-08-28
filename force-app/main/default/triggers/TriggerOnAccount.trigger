trigger TriggerOnAccount on Account (before update) {
    
    if(trigger.isInsert && trigger.isBefore){
        AccountTriggerHandler.UpdateAccountFields(trigger.new);
    }
    
    if(trigger.isUpdate && trigger.isBefore){
        AccountTriggerHandler.handleOrgTypeBasedOnRecordtype(trigger.new,trigger.oldMap);
    }
}