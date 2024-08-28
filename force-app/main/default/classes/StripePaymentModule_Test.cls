@isTest(SeeAllData=true)
public class StripePaymentModule_Test {
    
      public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public Static testMethod void TestgenerateStripePaymentLink(){
        Account acc = new Account(Name='Test'); //Utility.createAccount('test');
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.LeadSource = 'Website';
        opp.CloseDate = System.today();
        opp.StageName = '1 - Champion with Intent';
        opp.AccountId = acc.Id;
        opp.Amount = 500;
        insert opp;
        
        Invoice__c inv = new Invoice__c();
        inv.Opportunity__c = opp.id;
        inv.Invoice_Status__c = 'Draft';
        inv.Invoice_Date__c = System.today();
        inv.Due_Date__c =  inv.Invoice_Date__c.addDays(30);
        inv.Billing_Start_Date__c = System.today();
        inv.Billing_End_Date__c = System.today().addDays(7);
        insert inv;
        
        Set<Id> parentObjIdSet = new Set<Id>();
        parentObjIdSet.add(inv.Id);
        test.startTest();
         Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        StripePaymentModule.generateStripePaymentLink(parentObjIdSet);
        test.stopTest();
    }
}