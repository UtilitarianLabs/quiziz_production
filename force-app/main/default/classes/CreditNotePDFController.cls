public class CreditNotePDFController {
    
    public id OpportunityID {get;set;}
    public id invoiceIdFromPage {get;set;}
    public List<OpportunityLineItem> oppProductList {get;set;}
    public Invoice__c billInfoForInvoice {get;set;}
    public Opportunity oppDetails {get;set;}
    public aggregateResult TotalQty {get;set;}
    public List<Invoice__c> paidAmountFromInvoice {get;set;}
    public List<Invoice__c> invRecordList {get;set;}   
    public List<Invoice_Contact__c> invoicContact {get;set;}
    List<Contact> conList {get;set;}
    public String InvoiceNote {get;set;}
    public List<Credit_Note__c> credNoteList {get;set;}
    public String CreditNoteName {get;set;}
    public String invoiceName {get;set;}
    public String ReasonCode {get;set;}
    public String SubscriptionID {get;set;}
    public SBQQ__Subscription__c subRecord {get;set;}
    public String SubId {get;set;}
    
    
    public String invoiceVersion {get;set;}
    public string CreatedDate {get;set;}
    public string NoToWord {get;set;}
    public Double totalAmount {get;set;}
    public Double TotalTax {get;set;}
    
    public Double dueAmount {get;set;}
    public Double padiAmountInvoice {get;set;}
    public Double OpportunityAmount {get;set;}
    public String WireAchTaransferNo {get;set;}
    public String BankName {get;set;}
    public String AccountName {get;set;}
    public String AccountNumber {get;set;}
    public String RoutingNumber {get;set;}
    public String SwiftCode {get;set;}
    public String BankAddress {get;set;}
    public String SendChecksPayable  {get;set;}
    public String invoiceDate {get;set;}
    public String dueDate {get;set;}
    public String paymentStatus {get;set;}
    public String PONumber {get;set;}
    public String PONumberInv {get;set;}
    public String SubStartDate {get;set;}
    public String SubEndDate {get;set;}
    public String CreditNumber {get;set;}
    public String customerName {get;set;}
    public String customerPhone {get;set;}
    public Double invoiceAmountTotal {get;set;}
    public Double invoicePaidAmount {get;set;}
    public Double invoiceDueAmount {get;set;}
    public Boolean EnableShipping {get;set;}
    public String invContactName {get;set;}
    public String invContactPhone {get;set;}
    public decimal creditAmount{get;set;}
    public decimal invoicedAmount{get;set;}
    public string customerId{get;set;}
    public Credit_Note__c creditNoteDetails{get;set;}
    public string subIdValue{get;set;}
    public String generalDescription {get;set;}
    public static Credit_Note__c invo{get;set;}
    public CreditNotePDFController(ApexPages.StandardController controller){
        try{
            string invoiceid= ApexPages.currentPage().getParameters().get('id');
             invo = [SELECT Id,Name,Credit_Note_Amount__c,Invoice__c,Invoice__r.Invoiced_Amount__c,Invoice__r.Generate_Invoice_Number__c,Invoice__r.Name,Invoice__r.Enable_Shipping__c,Invoice__r.Opportunity__c,Invoice__r.Opportunity__r.AccountId,Reason_Code__c,Credit_Note_Date__c,
                                   Invoice__r.Billing_Street__c,Invoice__r.Billing_City__c,Invoice__r.Billing_Postal_Code__c,Invoice__r.Billing_State__c,Invoice__r.Billing_Country__c,Invoice__r.Shipping_Street__c,
                                   Invoice__r.Shipping_City__c,Invoice__r.Billing_Entity_Name__c,Invoice__r.Shipping_Entity_name__c,Invoice__r.Shipping_Postal_Code__c,Invoice__r.General_Description__c,Invoice__r.Shipping_State__c,Invoice__r.Shipping_Country__c FROM Credit_Note__c WHERE Id=:invoiceid];
            
            
            this.invoiceIdFromPage = invo.Invoice__c;
            this.creditNoteDetails = invo;
            Opportunity opp = [SELECT Id,Name FROM Opportunity WHERE ID =:invo.Invoice__r.Opportunity__c];
            this.oppDetails=[select Account.Id, Account.Name,Account.BillingStreet,Account.BillingCity,Account.BillingState, Account.ShippingCity,Amount, Subscription_Start_Date__c,Subscription_End_Date__c,
                             Account.ShippingStreet,Account.ShippingState,Account.ShippingCountry,Account.Billing_Accounts_Receivable_Email_Addres__c, Invoice_Status__c, PO_Number__c from Opportunity where Id=:invo.Invoice__r.Opportunity__c LIMIT 1];
            String oppId = opp.Id;
            if(oppId!=null){
                this.OpportunityID=oppId;
                this.oppProduct1(invo);
                DateTime todaysDate = System.today();
                CreatedDate = todaysDate.format('dd-MM-yyyy');
                System.debug(CreatedDate);
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
    }
    
    public void oppProduct1(Credit_Note__c creditNoteDetails){
        if(creditNoteDetails.Invoice__r.Opportunity__c != null){
                this.subIdValue = [select id from SBQQ__Subscription__c where Opportunity__c =: creditNoteDetails.Invoice__r.Opportunity__c].Id;
            }
        this.CreditNoteName = creditNoteDetails.Name;
        this.invoiceName = String.valueOf(creditNoteDetails.Invoice__r.Generate_Invoice_Number__c);
        Date d = creditNoteDetails.Credit_Note_Date__c + 1;
            Integer y = d.year();
            Integer m = d.month();
            Integer d1 = d.day();
            DateTime dt = DateTime.newInstance(y,m,d1);
        this.invoiceDate = dt.format('MMM dd, yyyy');
        this.creditAmount = creditNoteDetails.Credit_Note_Amount__c;
        this.invoicedAmount = creditNoteDetails.Invoice__r.Invoiced_Amount__c;
        this.ReasonCode = creditNoteDetails.Reason_Code__c;
        this.customerId = creditNoteDetails.Invoice__r.Opportunity__r.AccountId;
        this.generalDescription = creditNoteDetails.Invoice__r.General_Description__c;
        this.EnableShipping = creditNoteDetails.Invoice__r.Enable_Shipping__c;

    }
}