public without sharing class BatchOnBulkContractCreation implements Database.Batchable <Sobject>{
    
    public Database.QueryLocator Start (Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id,Name,Account_Id__c,Amount__c,Contract_Length_Months__c,Deal_Org_Type__c,Final_Enrollment_To_Be__c,Final_Total_Amount__c,Opportunity_Id__c,Round_Off__c,Slab_Price__c,Subscription_End_Date__c,Subscription_Start_Date__c FROM Product_Done__c');
    }
    
    public void execute (Database.BatchableContext bc, List<Product_Done__c> prodDone){
        list<Opportunity> oppList = new list<Opportunity>();
        //list<Opportunity> nonValidOppList = new list<Opportunity>();
        set<String> oppidSet = new set<String>();
        for(Product_DOne__c pord : prodDone){
            oppidSet.add(pord.Opportunity_Id__c);
        }
        if(!oppidSet.isempty()){
            oppList = [select id,SBQQ__Contracted__c from Opportunity where id in:oppidSet];
            
            for(Opportunity opp : oppList){
                if(!opp.SBQQ__Contracted__c){
                    opp.SBQQ__Contracted__c = true;
                }
            }
            update oppList;
        }
        
    }
    
    public void finish (Database.BatchableContext bc){
        system.debug('The Batch run successfully');
    }
}