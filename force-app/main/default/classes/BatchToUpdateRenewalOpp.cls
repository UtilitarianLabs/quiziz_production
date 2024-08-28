public without sharing class BatchToUpdateRenewalOpp implements Database.batchable <SObject> {
    
    Public Database.QueryLocator Start(Database.batchableContext bc){
        return Database.getQueryLocator('Select id,Parent_Opportunity__c from Opportunity where SBQQ__Renewal__c = true and Parent_Opportunity__c != null');
    }

    public void Execute(Database.batchableContext bc, List<Opportunity> oppList){

        Map<String,Opportunity> mapofParentIdbyRenewalOpp = new Map<String,Opportunity>();
        Set<String> parentSet = new Set<String>();
        for(Opportunity opp : oppList){
            mapofParentIdbyRenewalOpp.put(opp.Parent_Opportunity__c,opp);
            parentSet.add(opp.Parent_Opportunity__c);
        }

        if(!parentSet.isEmpty()){
            List<Opportunity> oppListTobeUpdate = new List<Opportunity>();
            oppListTobeUpdate = [SELECT id,Renewal_Opportunity__c from Opportunity where id in: parentSet];
            
            for(Opportunity oppDet : oppListTobeUpdate){
                oppDet.Renewal_Opportunity__c = mapofParentIdbyRenewalOpp.get(oppDet.Id).Id;
            }
            
            update oppListTobeUpdate;
        }

    }

    public void Finish(Database.batchableContext bc){
     System.debug('Batch Run Successfully');
    }
}