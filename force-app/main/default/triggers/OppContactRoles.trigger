trigger OppContactRoles on OpportunityContactRole (before insert) {
    if(Trigger.isInsert && Trigger.isBefore){
        TriggerOnOppContactRole.attachCSTeamMember(Trigger.new);
    }
}