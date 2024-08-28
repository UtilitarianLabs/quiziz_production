trigger Opportunity_Trigger on Opportunity (before insert,after insert ,after update,before update,before delete) {
    if(Label.Opportunity_Trigger_Handler == 'true'){
        if(Trigger.isInsert && Trigger.isBefore){
            opportunityTrigger_Helper.mapOpportunityWithPricebook(Trigger.New);
            opportunityTrigger_Helper.assignedSubscriptionEndDate(Trigger.New);
            opportunityTrigger_Helper.updatePilotPeriodOnContractLenght(Trigger.new,Trigger.oldMap);
            opportunityTrigger_Helper.handleRenewalOpportunityAndProduct(Trigger.New);
            opportunityTrigger_Helper.tagDeafultORGType(Trigger.New);
            
        }
        
        if(trigger.isInsert && Trigger.isAfter){
            opportunityTrigger_Helper.createOpportunityProduct(Trigger.new,trigger.Oldmap);
            opportunityTrigger_Helper.tagDocumentAttachmentToRenewal(Trigger.New);
            opportunityTrigger_Helper.createChildMultiSchoolOppProduct(Trigger.new,trigger.Oldmap);
            opportunityTrigger_Helper.mapAttchmentAndRolesForPilotWon(Trigger.New);
            opportunityTrigger_Helper.createContactRole(Trigger.New);
        }
        
        if(Trigger.isUpdate && Trigger.isBefore){
            opportunityTrigger_Helper.assignedSubscriptionEndDate(Trigger.New);
            opportunityTrigger_Helper.updatePilotPeriodOnContractLenght(Trigger.new,Trigger.oldMap);
            opportunityTrigger_Helper.validateMultischoolClosedWonOpportunity(trigger.new,trigger.oldMap);
            opportunityTrigger_Helper.opportunityClosedWonActivity(trigger.new,trigger.oldMap);
        }
        if(Trigger.isUpdate && Trigger.isAfter){
            
            if(opportunityTrigger_Helper.afterUpdate){
                opportunityTrigger_Helper.createOpportunityProduct(Trigger.new,trigger.Oldmap);
                opportunityTrigger_Helper.tagTrialProduct(trigger.new,trigger.oldmap);
                opportunityTrigger_Helper.completeVerifyClosedWonTask(trigger.new,trigger.oldmap);// check if task is created or not.
                opportunityTrigger_Helper.createOpportunityFromPilotOpportunity(trigger.new,trigger.oldmap);
                opportunityTrigger_Helper.onchangeMapDettoMulOppo(trigger.new,trigger.oldmap);
                //opportunityTrigger_Helper.createAdminContact(trigger.new,trigger.oldmap);
                opportunityTrigger_Helper.postOnboardingActivity(trigger.new,trigger.oldmap);
                opportunityTrigger_Helper.updateContractWithPrimaryQuote(trigger.new,trigger.oldmap);
                opportunityTrigger_Helper.postOpportunityClosedWonActivity(trigger.new,trigger.oldmap);
                opportunityTrigger_Helper.syncStartDateEndDate(trigger.new,trigger.oldmap);
                opportunityTrigger_Helper.afterUpdate = false;
            } 
        }
        
    }
}