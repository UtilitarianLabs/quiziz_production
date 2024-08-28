public class CPQQuoteLineTriggerHandler {
    
    public static void handleCPQQuoteLineItem(list<SBQQ__QuoteLine__c> quoteLineItemList){
        if(!quoteLineItemList.isEmpty()){
            for(SBQQ__QuoteLine__c quoteLine : quoteLineItemList){
                quoteLine.SBQQ__PricingMethod__c = 'Custom';
                quoteLine.SBQQ__ProductSubscriptionType__c = 'Renewable';
                quoteLine.SBQQ__SubscriptionType__c = 'Renewable';
                quoteLine.SBQQ__DefaultSubscriptionTerm__c = 12;
            }
        }
    }
    
}