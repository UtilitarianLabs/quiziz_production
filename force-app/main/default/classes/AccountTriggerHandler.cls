public class AccountTriggerHandler {
    
    public static void handleOrgTypeBasedOnRecordtype(List<Account> accList,Map<Id,Account> accountOldMap){
        for(Account acc : accList){
            if(acc.RecordtypeId != null && acc.RecordtypeId != accountOldMap.get(acc.id).RecordtypeId){
                if(acc.RecordtypeId == '0125j000000kn1aAAA'){
                    acc.Org_Type__c = 'District';
                }else if(acc.RecordtypeId == '0125j000000kn1bAAA'){
                    acc.Org_Type__c = 'School';
                }
            }
        }
    }
    
    public static void UpdateAccountFields(List<Account> acclist){
        if(!acclist.isEmpty()){
            for(Account acc : acclist){
                acc.SBQQ__ContractCoTermination__c = '	Never';
                acc.SBQQ__RenewalPricingMethod__c = 'Same';
                acc.SBQQ__RenewalModel__c = 'Contract Based';
            }
        }
    }
}