/*
 * Name          : Create_Contract
 * Author        : 
 * Description   : Set's Contracted to TRUE on the opportunity if the quote has all required fields
 *
 * Maintenance History:
 * Date         - Name                  - Version   - Remarks
 * 03/06/2023   - IcebergOps/jlozano    - 2.0       - Added validations to confirm that the quote has all the necessary information to be contracted
 */    
public class Create_Contract {

    @AuraEnabled
    public static String createContract(String oppId){
        String returnMessage = '';
        System.debug(oppId);
        Opportunity opp = [
            SELECT Id,SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.of_subscriptions__c, SBQQ__PrimaryQuote__r.SBQQ__StartDate__c,
            SBQQ__PrimaryQuote__r.SBQQ__EndDate__c,SBQQ__Contracted__c FROM Opportunity WHERE Id = :oppId];
        /*if(opp==null){
            return 'No opportunity found';
        }
        */
        if(opp.SBQQ__Contracted__c){
            returnMessage += 'Opportunity has already been contracted;';
        }
        if(opp.SBQQ__PrimaryQuote__c==null){
            returnMessage += ' No primary quote found;';
        }
        if(opp.SBQQ__PrimaryQuote__r.of_subscriptions__c == null || opp.SBQQ__PrimaryQuote__r.of_subscriptions__c == 0){
            returnMessage += ' There are no subscriptions to contract;';
        }
        if(opp.SBQQ__PrimaryQuote__r.of_subscriptions__c > 0 && (opp.SBQQ__PrimaryQuote__r.SBQQ__StartDate__c == null || opp.SBQQ__PrimaryQuote__r.SBQQ__EndDate__c == null)){
            returnMessage += ' The quote has subscriptions but no start or end date';
        }
        if (returnMessage.length() > 0) {
            return returnMessage;
        }
        opp.SBQQ__Contracted__c=true;
        update opp;
        return 'SUCCESS';
    }
}