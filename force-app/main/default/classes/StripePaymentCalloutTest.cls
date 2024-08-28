@isTest
public class StripePaymentCalloutTest {
    
    public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public Static testMethod void testStripePaymentCallout(){
        
        Account acc = new Account(Name='Test');
        Opportunity opp = new Opportunity(Name='Test',Leadsource='Website',CloseDate=System.today(),stagename='1 - Champion with Intent',AccountId=acc.Id);  
        Invoice__c invrec = new Invoice__c();
        invrec.Invoice_Status__c = 'Voided'; 
        invrec.Generate_Invoice_Number__c = 'Test 1';
        invrec.Opportunity__c = opp.Id;
        invrec.CN_Number__c = 44;
        invrec.PaymentID__c = 'plink_1MyUlzH06udFZQYB8OA0GVoK';
        insert invrec;
        String inId = invrec.PaymentID__c;
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        StripePaymentCallout.updatePaymentLink(inId,false);
        test.stopTest();
    }
}