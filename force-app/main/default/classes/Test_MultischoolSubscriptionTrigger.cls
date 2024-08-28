@isTest
public class Test_MultischoolSubscriptionTrigger {
    @isTest
    public static void testMultischoolSubscriptionTrigger(){
        Multischool_Subscription__c insertSub = new Multischool_Subscription__c();
        insertSub.Quantity__c = 10;
        insertSub.Contract_Length__c = 12;
        insertSub.Start_Date__c = system.today();
        insertSub.Subscription_End_Date__c = system.today().addDays(10);
        insertSub.End_Date__c = system.today().addDays(10);
        insert insertSub;
        
        insertSub.Contract_Length__c = 15;
        update insertSub;
    }
}