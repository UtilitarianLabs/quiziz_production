@isTest
public class CreditNotePDFController_Test {

    public Static testMethod void TestCreditNotePDFController(){
        
         Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.CloseDate = System.today();
        opp.StageName = 'Prospecting';
        insert opp;
        
        Invoice__c inv = new Invoice__c();
        inv.Amount__c = 9000;
        inv.CN_Number__c = 900;
        inv.Opportunity__c = opp.Id;
        inv.Payment_Status__c ='Paid';
        inv.Payment_Mode_Type__c = 'Check';
        inv.Payment_Date__c = system.now();
        inv.Payment_Notes__c = 'Text Area';
        inv.Invoiced_Amount__c = 9000;
        inv.Due_Date__c = System.today();
        inv.Payment_Status__c = 'Paid';
        inv.Invoice_Note__c = 'Invoice Note';
        inv.Invoice_Date__c = System.today();
        insert inv;
        
        Contact con = new Contact();
        
        
        Invoice_Contact__c invCon = new Invoice_Contact__c();
        invCon.Invoice__c = inv.Id;
        invCon.Primary_Contact__c = true;
        insert invCon;
        
        
       
        ApexPages.StandardController sc2 = new ApexPages.StandardController(inv);
        PageReference pageRef2 = Page.CreditNoteVF;
        pageRef2.getParameters().put('Id', inv.Id);
        Test.setCurrentPage(pageRef2);
        CreditNotePDFController dfT2 = new CreditNotePDFController(sc2);
     //   dfT2.getmyimageurl();
     
    }
}