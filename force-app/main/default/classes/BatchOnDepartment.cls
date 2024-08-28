public without sharing class BatchOnDepartment implements Database.Batchable <Sobject>{
    
    public Database.QueryLocator Start (Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id,Name,Account_Id__c,Amount__c,Contract_Length_Months__c,End_Date__c,Final_Enrollment_To_Be__c,No_Of_Department__c,Opportunity_Id__c,Slab_Price_Per_Department__c,Start_Date__c From Department__c');
    }
    
    public void execute (Database.BatchableContext bc, List<Department__c> department){
        list<Opportunity> oppList = new list<Opportunity>();
        set<String> oppidSet = new set<String>();
        for(Department__c dept : department){
            oppidSet.add(dept.Opportunity_Id__c);
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