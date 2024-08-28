public without sharing class BatchontagRenewalOpportunityToParent 

Implements Database.batchable <Sobject>  {
    
    public Database.QueryLocator Start(Database.BatchableContext bc){
        String query = 'SELECT Id,SBQQ__Opportunity__r.Id,SBQQ__RenewalOpportunity__c,SBQQ__Opportunity__r.StageName,SBQQ__Opportunity__r.Renewal_Opportunity__c FROM Contract WHERE SBQQ__Opportunity__r.StageName =\'Closed WON\' AND  SBQQ__RenewalOpportunity__c=null';
        return Database.getQueryLocator(query);
    }
    
    public void Execute(Database.BatchableContext bc, List<Contract> contractList){
        for(Contract con : contractList){
            con.SBQQ__RenewalOpportunity__c = con.SBQQ__Opportunity__r.Renewal_Opportunity__c ;
            
        }
        update contractList;
    }
    public void Finish(Database.BatchableContext bc){
        
    }
}