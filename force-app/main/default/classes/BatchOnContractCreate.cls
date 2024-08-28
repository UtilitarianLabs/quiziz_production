public class BatchOnContractCreate implements Database.Batchable <Sobject>{
    public Database.QueryLocator Start (Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id,Opportunity_Id__c From Renewal_Closed_Backup__c');
    }
    
    public void execute (Database.BatchableContext bc, List<Renewal_Closed_Backup__c> renewalData){
        System.debug('renewalData---->'+renewalData);
        Set<String> strSet = new set<String>();
        for(Renewal_Closed_Backup__c renew : renewalData){
            strSet.add(renew.Opportunity_Id__c);
        }

        List<Opportunity> oppList = [SELECT Id,Name,Customer_Success_Stage__c,Teacher_Rostering_Status__c,Contact_Verify_Status__c FROM Opportunity WHERE ID IN:strSet];
        System.debug('oppList---->'+oppList);
        System.debug('oppList ID---->'+oppList[0].Id);
        for(Opportunity opp: oppList){
            if(opp.Customer_Success_Stage__c != 'Onboarding Complete'){
                opp.Customer_Success_Stage__c = 'Onboarding Complete';
            }
            if(opp.Teacher_Rostering_Status__c != 'Teachers Onboarded'){
               opp.Teacher_Rostering_Status__c = 'Teachers Onboarded';
            }
            if(opp.Contact_Verify_Status__c !='Details Received	'){
                opp.Contact_Verify_Status__c = 'Details Received';
            }
        }
        update oppList;
        
        List<Contract> conList = [Select id,SBQQ__RenewalForecast__c from Contract where SBQQ__Opportunity__c in: strSet];
        for(Contract conDet : conList){
            conDet.SBQQ__RenewalForecast__c = true;
        }
        update conList;
    }
    
    public void finish (Database.BatchableContext bc){
        system.debug('The Batch run successfully');
    }
}