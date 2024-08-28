/*
 * Name          : Create_ContractTest
 * Author        : IcebergOps/sTarasevich
 * Description   : Test class for Create_Contract
 *
 * Maintenance History:
 * Date         - Name                      - Version   - Remarks
 * 03/07/2023   - IcebergOps/sTarasevich    - 1.0       - Initial
 */   
@isTest
public with sharing class Create_ContractTest {
    @TestSetup static void methodName() {
        Account acc = Utility.createAccount('test');

        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.LeadSource = 'Website';
        opp.CloseDate = System.today();
        opp.StageName = '1 - Champion with Intent';
        opp.AccountId = acc.Id;
        opp.Billing_Accounts_Receivable_Email_Addres__c = 'dinesh@gmail.com';
        insert opp;

        Opportunity opp1 = new Opportunity();
        opp1.Name = 'test1';
        opp1.LeadSource = 'Website';
        opp1.CloseDate = System.today();
        opp1.StageName = '1 - Champion with Intent';
        opp1.AccountId = acc.Id;
        opp1.Billing_Accounts_Receivable_Email_Addres__c = 'dinesh@gmail.com';
        opp1.SBQQ__Contracted__c = true;
        insert opp1;

        Contact con = Utility.createContact('testname', 'dineshtest@gmail.com', acc.Id);
        Product2 prod = new Product2(Name = 'Test Product');
        insert prod;

        SBQQ__Quote__c sbq = new SBQQ__Quote__c();
        sbq.SBQQ__Account__c = acc.Id;
        sbq.SBQQ__PrimaryContact__c = con.Id;
        sbq.SBQQ__Opportunity2__c = opp1.Id;
        sbq.SBQQ__StartDate__c = null;
        sbq.SBQQ__EndDate__c = null;
        insert sbq;

        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
        quoteLine.SBQQ__Product__c = prod.Id;
        quoteLine.SBQQ__Quantity__c = 1;
        quoteLine.SBQQ__PricingMethod__c = 'Custom';
        quoteLine.SBQQ__ProductSubscriptionType__c = 'Renewable';
        quoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        quoteLine.SBQQ__SubscriptionType__c = 'Renewable';
        quoteLine.SBQQ__Quote__c = sbq.Id;
        insert quoteLine;


        Opportunity opp2 = new Opportunity();
        opp2.Name = 'test2';
        opp2.LeadSource = 'Website';
        opp2.CloseDate = System.today();
        opp2.StageName = '1 - Champion with Intent';
        opp2.AccountId = acc.Id;
        opp2.Billing_Accounts_Receivable_Email_Addres__c = 'dinesh@gmail.com';
        opp2.SBQQ__Contracted__c = false;
        opp2.SBQQ__PrimaryQuote__c = sbq.Id;
        insert opp2;

        Product2 p = new Product2();
        p.Name = ' Test Product ';
        p.Description='Test Product Entry For Product';
        p.productCode = 'SFDCPanther-123';
        p.isActive = true;
        insert p;


        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Opportunity2__c = opp2.id;
        quote.SBQQ__Account__c = acc.id;
        sbq.SBQQ__StartDate__c = null;
        sbq.SBQQ__EndDate__c = null;
        insert quote;

        SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c();
        quoteLine2.SBQQ__Product__c = p.id;
        quoteLine2.SBQQ__Quantity__c = 5;
        quoteLine2.SBQQ__PricingMethod__c = 'custom';
        quoteLine2.SBQQ__ListPrice__c = 20;
        quoteLine2.SBQQ__Quote__c = quote.Id;
        insert quoteLine2;


    }


    @IsTest static void testCreateContract_negative() {
        String oppId = [SELECT Id FROM Opportunity WHERE Name = 'test'].Id;
        String result;
        try {
            test.startTest();
            result = Create_Contract.createContract(oppId);
            test.stopTest();
        } catch (Exception ex) {
            String error = ex.getMessage();
            System.assertEquals('No primary quote found;', error);
        }
    }

    @IsTest static void testCreateContract_contracted() {
        String oppId = [SELECT Id FROM Opportunity WHERE Name = 'test1'].Id;
        String result;
        try {
            test.startTest();
            result = Create_Contract.createContract(oppId);
            test.stopTest();
        } catch (Exception ex) {
            String error = ex.getMessage();
            System.assertEquals('Opportunity has already been contracted', error);
        }
    }
}