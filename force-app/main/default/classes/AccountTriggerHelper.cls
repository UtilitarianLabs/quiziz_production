public class AccountTriggerHelper {
    
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