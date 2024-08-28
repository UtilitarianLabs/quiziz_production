//    SK    Oct 19 2022    Invocable method to call Leadassignment rules post creation

public class AssignLeadsUsingAssignmentRules
{
    @InvocableMethod
    public static void LeadAssign(List<Id> LeadIds)
    {
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true;          
            Lead Leads=[select id from lead where lead.id in :LeadIds];
            Leads.setOptions(dmo);
            update Leads;
   }
}