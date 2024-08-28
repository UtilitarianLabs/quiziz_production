@isTest
public class PaidInvoiceAuraControllerTest {
    public static testMethod void TestPaidInvoiceAuraControllerTest(){
        test.startTest();
        List<Attachment> attachList = new List<Attachment>();
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TESTCQ',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;
        
        Account acc = New Account();
        acc.Name = 'Test AccountFor Quote Cal';
        acc.OwnerId = u.Id;
        acc.Customer_Success__c = u.Id;
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.CloseDate = System.today();
        opp.AccountId = acc.Id;
        opp.StageName = 'Prospecting';
       
       // opp.Is_Contract_Created__c = true;
       // opp.ContactId = con.Id;
        insert opp;
        
        Invoice__c inv = new Invoice__c();
        inv.Amount__c = 9000;
        inv.CN_Number__c = 900;
        inv.Opportunity__c = opp.Id;
        inv.Payment_Status__c ='Paid';
        inv.Payment_Mode_Type__c = 'Check';
        inv.Payment_Date__c = system.now();
        inv.Payment_Notes__c = 'Text Area';
        insert inv;
        PageReference pdfPage = Page.PaidInvoicePDF;
        pdfPage.getParameters().put('id',inv.id);
        Blob b;
        if(Test.isRunningTest()){
            b = blob.valueOf('Unit.Test');
        }else{
            b = pdfPage.getContentAsPDF();}
        
        //  Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = inv.Id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        attachment.IsPrivate = false;
        attachment.ContentType = 'application/pdf';
        attachList.add(attachment);
        insert attachList;
        
        PaidInvoiceAuraController.attachPaidInvoicePDF(inv.Id);
        test.stopTest();
    }
}