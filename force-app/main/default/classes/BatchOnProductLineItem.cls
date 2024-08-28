public without sharing class BatchOnProductLineItem implements Database.Batchable <Sobject>{
    
    public Database.QueryLocator Start (Database.BatchableContext bc){
        String orgType = 'Multi-school';
        return Database.getQueryLocator('SELECT Id,Name,Account_Id__c,Amount__c,Contract_Length_Months__c,Deal_Org_Type__c,Final_Enrollment_To_Be__c,Final_Total_Amount__c,Opportunity_Id__c,Round_Off__c,Round_Off_Type__c,Slab_Price__c,Subscription_End_Date__c,Subscription_Start_Date__c FROM Product_Done__c WHERE Deal_Org_Type__c =: orgType');
    }
    
    public void execute (Database.BatchableContext bc, List<Product_Done__c> oppLineItemsList){
        system.debug('oppLineItemsList::'+oppLineItemsList);
        string productId = '01t5j000004Kj4bAAC';
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Opportunity2__c = oppLineItemsList[0].Opportunity_Id__c;//Opportunity_Id__c
        quote.SBQQ__SubscriptionTerm__c = oppLineItemsList[0].Contract_Length_Months__c;//Contract_Length_Months__c
        quote.SBQQ__Account__c = oppLineItemsList[0].Account_Id__c;//Account_Id__c
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__StartDate__c = oppLineItemsList[0].Subscription_Start_Date__c;//Subscription_Start_Date__c
        quote.SBQQ__EndDate__c = oppLineItemsList[0].Subscription_End_Date__c;//Subscription_End_Date__c
        insert quote;
        
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Product__c = productId;
        quoteLine.SBQQ__Quantity__c = oppLineItemsList[0].Final_Enrollment_To_Be__c;//Final_Enrollment_To_Be__c
        quoteLine.SBQQ__PricingMethod__c = 'Custom';
        quoteLine.SBQQ__ProductSubscriptionType__c = 'Renewable';
        quoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        quoteLine.SBQQ__DefaultSubscriptionTerm__c = oppLineItemsList[0].Contract_Length_Months__c;//Contract_Length_Months__c
        quoteLine.SBQQ__SubscriptionType__c = 'Renewable';
        quoteLine.SBQQ__ListPrice__c = ((oppLineItemsList[0].Slab_Price__c / 12)*oppLineItemsList[0].Contract_Length_Months__c);
        quoteLine.Slab_Price__c = oppLineItemsList[0].Slab_Price__c;
        quoteLine.SBQQ__Quote__c = quote.Id;
        /*quoteLine.Round_Off__c = oppLineItemsList[0].Round_Off__c;
        quoteLine.Round_Off_Type__c = oppLineItemsList[0].Round_Off_Type__c;*/
        insert quoteLine;
    }
    
    public void finish (Database.BatchableContext bc){
        system.debug('The Batch run successfully');
    }
}