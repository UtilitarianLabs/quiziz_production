trigger TroggerOnContract on Contract (before delete) {
    /*if(trigger.isBefore && trigger.isInsert){
        //ContractTriggerHelper.mapContractEndDate(trigger.new);
    }
    if(trigger.isBefore && trigger.isUpdate){
        ContractTriggerHelper.createNewSubscriprion(trigger.new,trigger.oldMap);
        ContractTriggerHelper.createRenewalQuote(trigger.new,trigger.oldMap);
        //ContractTriggerHelper.mapContractEndDate(trigger.new);
    }
    if(trigger.isAfter && trigger.isUpdate){
        ContractTriggerHelper.regenrateQuote(trigger.new,trigger.oldMap);
        ContractTriggerHelper.mapMulChildOpportunity(trigger.new,trigger.oldMap);
        ContractTriggerHelper.tagRenewalOppToParent(trigger.new,trigger.oldMap);
    }

    if(trigger.isAfter && Trigger.isInsert){
        ContractTriggerHelper.validateContractCreation(trigger.new);
    }*/
}