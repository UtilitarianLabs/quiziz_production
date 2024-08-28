trigger TriggerOpportunityLineItem on OpportunityLineItem (before insert,after insert,after update,before update,before delete) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        OppLineItemTriggerHandler.recalculateOppItemStatDate(trigger.new);
        OppLineItemTriggerHandler.addSlabPriceToOppLineItem(trigger.new);// for reewal opportunity
        OppLineItemTriggerHandler.addEndDate(trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        if(OppLineItemTriggerHandler.isBeforeUpdateTrigger){
            OppLineItemTriggerHandler.updateSlalPriceonDiscount(Trigger.new,trigger.oldmap);
            OppLineItemTriggerHandler.recalculateUnitPrizeOnSlabPrizeChange(Trigger.new,trigger.oldmap);
            OppLineItemTriggerHandler.validateDuplicateDepartmentType(Trigger.new,Trigger.oldmap);
            OppLineItemTriggerHandler.addEndDate(trigger.new);
        }
        
    }
}