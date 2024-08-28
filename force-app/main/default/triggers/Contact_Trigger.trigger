trigger Contact_Trigger on Contact (before insert,after insert) {

    if(Trigger.isBefore && Trigger.isInsert){
        //ContactTrigger_Helper.setCSOwner(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        //ContactTrigger_Helper.mapContactToopportunityContactRoles(Trigger.new);
        //ContactTrigger_Helper.createOppContactRolesOnMasterOpp(Trigger.new);
    }
}