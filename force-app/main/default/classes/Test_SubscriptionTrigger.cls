@isTest
public class Test_SubscriptionTrigger {
	
    @isTest
    public static void testSubscriptionTrigger(){
        SBQQ__Subscription__c insertSub = new SBQQ__Subscription__c();
        insertSub.SBQQ__Quantity__c = 10;
        insertSub.Contract_Length__c = 12;
        insertSub.SBQQ__SubscriptionStartDate__c = system.today();
        insertSub.SBQQ__SubscriptionEndDate__c = system.today().addDays(10);
        insert insertSub;
        
        insertSub.Contract_Length__c = 15;
        update insertSub;
    }
}