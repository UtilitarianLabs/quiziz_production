public class PDFInvoiceController_1 {
    
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
    public String RoutingNumberWire {get;set;}
     public String RoutingNumberWireACH {get;set;}
    public String SwiftCode {get;set;}
    public String BankAddress {get;set;}
    public String SendChecksPayable  {get;set;}
    public String invoiceDate {get;set;}
    public String paidInvoiceDate {get;set;}
    public String dueDate {get;set;}
    public String paymentStatus {get;set;}
    public String PONumber {get;set;}
    public String PONumberInv {get;set;}
    public String SubStartDate {get;set;}
    public String SubEndDate {get;set;}
    public String customerName {get;set;}
    public String customerPhone {get;set;}
    public Decimal invoiceAmountTotal {get;set;}
    public Double invoicePaidAmount {get;set;}
    public Decimal invoiceDueAmount {get;set;}
    public Boolean EnableShipping {get;set;}
    public String invContactName {get;set;}
    public String invContactPhone {get;set;}
    public String invoiceNote {get;set;}
    public String generalDescription {get;set;}
    public String GeneralNote {get;set;}
    public string paymentType{get;set;}
    public string paymentTerm{get;set;}
    public date dueInvoiceDate{get;set;}
    
    public PDFInvoiceController_1(ApexPages.StandardController controller){
        this.totalAmount=0;
        string invoiceid= ApexPages.currentPage().getParameters().get('id');
        Invoice__c invo = [SELECT Id,Name,Opportunity__c FROM Invoice__c WHERE Id=:invoiceid];
        this.invoiceIdFromPage = invo.Id;
        Opportunity opp = [SELECT Id,Name FROM Opportunity WHERE ID =:invo.Opportunity__c];
        String oppId = opp.Id;
        // System.debug(id);
        if(oppId!=null)
        {
            this.OpportunityID=oppId;
            this.oppProduct1();
            DateTime todaysDate = System.today();
            CreatedDate = todaysDate.format('dd-MM-yyyy');
            System.debug(CreatedDate);
        }
    }
    
    public void oppProduct1(){
        try{
            Transfer_Details__mdt data = [SELECT Id,Send_Checks_Payable_to__c,Routing_NumberACH__c, DeveloperName,Account_Name__c,Account_Number__c,Bank_Address__c,Bank_Name__c,Routing_Number__c,Swift_Code__c FROM Transfer_Details__mdt];
            this.WireAchTaransferNo = data.DeveloperName;
            this.BankName = data.Bank_Name__c;
            this.AccountName =  data.Account_Name__c;
            this.AccountNumber = data.Account_Number__c ; 
            this.RoutingNumberWire =data.Routing_Number__c ;
            this.RoutingNumberWireACH = data.Routing_NumberACH__c;
            this.SwiftCode = data.Swift_Code__c;
            this.BankAddress = data.Bank_Address__c;
            this.SendChecksPayable = data.Send_Checks_Payable_to__c;
            
            this.invoicContact = [SELECT Id,Name,Contact__r.Name,Contact__r.Phone,Invoice__c,Active_Email__c FROM Invoice_Contact__c WHERE Invoice__c =:this.invoiceIdFromPage ];
            system.debug('invoicContact:: ' +invoicContact);
            for(Invoice_Contact__c inv : invoicContact){
                if(inv.Active_Email__c == true){
                    System.debug('Inside the True Condtion ::');
                    this.invContactName = inv.Contact__r.Name;
                    this.invContactPhone = inv.Contact__r.Phone;
                    
                }
            }
            
            
            system.debug('i m OUTSIDE OF INVOICE PDF');
            
            
            this.oppProductList=[Select Id,Product2.Name, Description, Quantity, UnitPrice, TotalPrice from OpportunityLineItem where OpportunityID=:this.OpportunityID order by CreatedDate asc];
            this.oppDetails=[select Account.Id, Account.Name,Account.BillingStreet,Account.BillingCity,Account.BillingState, Account.ShippingCity,Amount, Subscription_Start_Date__c,Subscription_End_Date__c,
                             Account.ShippingStreet,Account.ShippingState,Account.ShippingCountry,Account.Billing_Accounts_Receivable_Email_Addres__c, Invoice_Status__c from Opportunity where Id=:this.OpportunityID LIMIT 1];
            Date d = oppDetails.Subscription_Start_Date__c;
            Integer y = d.year();
            Integer m = d.month();
            Integer d1 = d.day();
            DateTime dt = DateTime.newInstance(y,m,d1);
            this.SubStartDate = dt.format('MMM dd, yyyy');
            Date endD = oppDetails.Subscription_End_Date__c;
            Integer endY = endD.year();
            Integer endM = endD.month();
            Integer endD1 = endD.day();
            DateTime endDT = DateTime.newInstance(endY,endM,endD1);
            this.SubEndDate = endDT.format('MMM dd, yyyy');
            
            this.OpportunityAmount = oppDetails.Amount;
            this.invRecordList = [Select Name, Invoice_Date__c,Payment_Mode_Type__c,Paid_Amount__c,Subscription_Start__c,Invoiced_Amount__c,Subscription_End__c,Enable_Shipping__c, Total_Amount__c, Payment_Status__c, Due_Date__c, Billing_Contact__r.Phone, Billing_Contact__r.Name, Invoice_Number__c,Generate_Invoice_Number__c from Invoice__c  where Id =:invoiceIdFromPage AND Opportunity__c = :this.OpportunityID];
            this.invoiceAmountTotal = invRecordList[0].Total_Amount__c;
            System.debug('RecordLIst >>>>'+invRecordList);
            if(invRecordList[0].Payment_Mode_Type__c != null){
                this.invoicePaidAmount = invRecordList[0].Paid_Amount__c;
            }else{
                this.invoicePaidAmount = 0;
            }
            System.debug('this.invoiceAmountTotal === >'+this.invoiceAmountTotal);
            System.debug('this.invoicePaidAmount === >'+this.invoicePaidAmount);
            this.invoiceDueAmount = this.invoiceAmountTotal -  this.invoicePaidAmount;
            
            
            this.billInfoForInvoice = [Select Name,Billing_Entity_Name__c,Billing_Postal_Code__c,Shipping_Postal_Code__c,Shipping_Entity_name__c,Payment_Term__c,Payment_Mode_Type__c,
                                       Invoice_Date__c,Subscription_Start__c,General_Notes__c,General_Description__c,Credit_Note__c,Invoice_Note__c,
                                       Generate_Invoice_Number__c,Subscription_End__c,Enable_Shipping__c, Total_Amount__c, Payment_Status__c,
                                       Due_Date__c, Billing_Contact__r.Phone, Billing_Contact__r.Name, Invoice_Number__c,Billing_City__c,
                                       Billing_Country__c,Billing_State__c,Billing_Street__c,Shipping_City__c,Shipping_Country__c,Shipping_State__c,
                                       Shipping_Street__c,PO_Number__c,Payment_Date__c
                                       from Invoice__c  
                                       where Id =:invoiceIdFromPage AND Opportunity__c = :this.OpportunityID LIMIT 1 ];
            DateTime invoiceDateTime = billInfoForInvoice.Invoice_Date__c + 1;
            date invDate = Date.newInstance(invoiceDateTime.year(), invoiceDateTime.month(), invoiceDateTime.day());
            Integer invY1 = invDate.year();
            Integer invM1 = invDate.month();
            Integer invD11 = invDate.day();
            DateTime invLatestDate = DateTime.newInstance(invY1,invM1,invD11);
            this.invoiceDate = invLatestDate.format('MMM dd, yyyy');
            
            if(billInfoForInvoice.Payment_Date__c != null){
                DateTime invpaiddatetime =billInfoForInvoice.Payment_Date__c + 1;
                Date paiddate = Date.newInstance(invpaiddatetime.year(), invpaiddatetime.month(), invpaiddatetime.day());
                
                Date invD = paiddate;
                Integer invY = invD.year();
                Integer invM = invD.month();
                Integer invD1 = invD.day();
                DateTime invDT = DateTime.newInstance(invY,invM,invD1);
                this.paidInvoiceDate = invDT.format('MMM dd, yyyy');
            }
            
            if(billInfoForInvoice.Due_Date__c != null){
                Date overDueD = billInfoForInvoice.Due_Date__c;
                Integer dueY = overDueD.year();
                Integer dueM = overDueD.month();
                Integer dueD1 = overDueD.day();
                DateTime dueDT = DateTime.newInstance(dueY,dueM,dueD1);
                this.dueDate = dueDT.format('MMM dd, yyyy');
            }
            if(billInfoForInvoice.Payment_Status__c != null){
                this.paymentStatus = billInfoForInvoice.Payment_Status__c;
            }
            
            if(billInfoForInvoice.Payment_Mode_Type__c != null){
                this.paymentType = billInfoForInvoice.Payment_Mode_Type__c;
            }
            if(billInfoForInvoice.Total_Amount__c != null){
                this.invoiceAmountTotal = billInfoForInvoice.Total_Amount__c;
            }
            this.EnableShipping = billInfoForInvoice.Enable_Shipping__c;
            if(billInfoForInvoice.Invoice_Note__c != null){
                this.invoiceNote = billInfoForInvoice.Invoice_Note__c;
            }
            if(billInfoForInvoice.General_Description__c != null){
                this.generalDescription = billInfoForInvoice.General_Description__c;
            }
            if(billInfoForInvoice.General_Notes__c != null){
               this.GeneralNote = billInfoForInvoice.General_Notes__c; 
            }
            if(billInfoForInvoice.Payment_Term__c != null){
                this.paymentTerm = billInfoForInvoice.Payment_Term__c;
            }
            
            //this.customerName = billInfoForInvoice.Billing_Contact__r.Name;
            //this.customerPhone = billInfoForInvoice.Billing_Contact__r.Phone;
            
            this.paidAmountFromInvoice = [Select Name, Invoice_Date__c, Payment_Status__c, Amount__c,Generate_Invoice_Number__c from Invoice__c  where Opportunity__c = :this.OpportunityID AND Payment_Status__c ='Paid'];
            this.padiAmountInvoice  = 0;
            for(Invoice__c inv  : this.paidAmountFromInvoice){
                this.padiAmountInvoice = this.padiAmountInvoice + inv.Amount__c;
            }
            this.dueAmount = this.OpportunityAmount - this.padiAmountInvoice;
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
    }
}