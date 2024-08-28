@isTest
public class Test_TriggerCoverage {
	@isTest
    Public static void trigger_testv1(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert Acc;
        
        Contact con = new contact();
        con.lastname = 'Test Name';
        con.Phone = '1234567890';
        con.Email = 'test@gmail.com';
        con.AccountId = acc.Id;
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.CloseDate = system.today();
        opp.StageName = 'Engaging';
        opp.Name = 'Test Name';
        opp.Contract_Length__c = 12;
        opp.Subscription_Start_Date__c = system.today();
        opp.Deal_Organization_Type__c = 'School';
        opp.Deal_Confirmed_Enrollment__c = 10000;
        opp.SDR_Attribution__c = 'Cyrus Joseph';
        insert opp;
        
        OpportunityContactRole oppCon = new OpportunityContactRole();
        oppCon.ContactId = con.Id;
        oppCon.OpportunityId = opp.Id;
        oppCon.Role = 'Business User';
        insert oppCon;
        
        Product2 p = new Product2();
p.Name = ' Test Product ';
p.Description='Test Product Entry For Product';
p.productCode = 'SFDCPanther-123';
p.isActive = true;
insert p;

// insert pricebook entry for the product
PricebookEntry standardPrice = new PricebookEntry();
standardPrice.Pricebook2Id = Test.getStandardPricebookId();
standardPrice.Product2Id = p.Id;
standardPrice.UnitPrice = 100;
standardPrice.IsActive = true;
standardPrice.UseStandardPrice = false;
insert standardPrice ;
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
oppLineItem.OpportunityId = opp.Id;
oppLineItem.PricebookEntryId = standardPrice.Id;
oppLineItem.UnitPrice = 7000;
oppLineItem.Quantity = 5;
insert oppLineItem;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Opportunity2__c = opp.id;
        quote.SBQQ__Account__c = acc.id;
        insert quote;
        
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Product__c = p.id;
        quoteLine.SBQQ__Quantity__c = 5;
        quoteLine.SBQQ__PricingMethod__c = 'custom';
        quoteLine.SBQQ__ListPrice__c = 20;
        quoteLine.SBQQ__Quote__c = quote.Id;
        insert quoteLine;
        
        Task ts = new task();
        ts.Status = 'Open';
        ts.Subject = 'Test Task';
        ts.WhatId = opp.Id;
       	insert ts;
        
        task ts1 = new task();
        ts1.Id = ts.Id;
        ts1.Status = 'Completed';
        update ts1;
        
        contract contr = new contract();
        contr.AccountId = acc.Id;
        contr.StartDate = system.today();
        contr.ContractTerm = 12;
contr.Status = 'Draft';
      contr.SBQQ__Opportunity__c =  opp.Id;
        insert contr;
        
        contract contr1 = new contract();
        contr1.Status = 'Activated';
        contr1.id = contr.id;
        //update contr1;
        
    }
    
}