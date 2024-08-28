@isTest
public class StripePaymentHandler_Test {
    
    public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public Static testMethod void TestinitiatePayment(){
       Account acc = new Account(Name='Test'); // Account acc = Utility.createAccount('test');
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.LeadSource = 'Website';
        opp.CloseDate = System.today();
        opp.StageName = '1 - Champion with Intent';
        opp.AccountId = acc.Id;
        opp.Amount = 500;
        opp.Customer_Success_Stage__c = 'New Customer Waiting';    
        insert opp;
        
        Invoice__c inv = new Invoice__c();
        inv.Opportunity__c = opp.id;
        inv.Invoice_Status__c = 'Draft';
        inv.Invoice_Date__c = System.today();
        inv.Due_Date__c =  inv.Invoice_Date__c.addDays(30);
        inv.Billing_Start_Date__c = System.today();
        inv.Billing_End_Date__c = System.today().addDays(7);
        inv.Generate_Invoice_Number__c = '34567';
        inv.Amount__c = 600;
        insert inv;
        String accId = acc.Id;
        String oppId = opp.Id;
        String invId = inv.Id;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        StripePaymentHandler.createProductAndPrice('test',500,invId,accId,oppId);
         StripePaymentHandler.createPrice(500,'0065j00000tuG5FAAU',invId);
        StripePaymentHandler.createPaymentLink('500',invId,oppId,accId);
        StripePaymentHandler.initiatePayment(inv.Id);
       
        test.stopTest();
    }
}