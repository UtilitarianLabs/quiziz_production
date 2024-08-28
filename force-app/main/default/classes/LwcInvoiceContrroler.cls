public without sharing class LwcInvoiceContrroler {
    
    @AuraEnabled(cacheable=true)
    public Static Opportunity getOpp(String opId){
        Opportunity opRec = new Opportunity();
        opRec = [Select id,name,Subscription_Start_Date__c,Subscription_End_Date__c,Invoice_Send_Date__c,	Amount,
                 Invoice_Status__c,(select id,name,Opportunity__c from Invoice__r) from Opportunity where id=:opId];
        System.debug('opRec ====> ' + opRec);
        return opRec;
    }
    
    
    @AuraEnabled(cacheable=true)
    Public Static Invoice__c getInvoiceOpp(String inId){
        decimal invoiceLatestNumber = 0;
        Invoice_Latest_Number__c invNum = [select id,Latest_Invoice_Number__c from Invoice_Latest_Number__c];
        Invoice__c latestInvoice = [select id,Generate_Invoice_Number__c  from Invoice__c where Generate_Invoice_Number__c != null order by Generate_Invoice_Number__c desc limit 1];
        
        invoiceLatestNumber = invNum.Latest_Invoice_Number__c + 1; 

        Invoice__c  inOppObj  = new Invoice__c();
        inOppObj = [select id,Amount__c,Shipping_Street__c,Shipping_State__c,Shipping_City__c,Shipping_Country__c,Billing_Street__c,Billing_State__c,Billing_City__c,Billing_Country__c,Invoice_Note__c,Generate_Invoice_Number__c,Invoice_Number__c, Opportunity__r.name,Opportunity__r.Subscription_Start_Date__c,Opportunity__r.Subscription_End_Date__c,Opportunity__r.Deal_Organization_Type__c,
                    Opportunity__r.Account.BillingStreet,Opportunity__r.Account.BillingCity,Opportunity__r.Account.BillingState,Opportunity__r.Account.BillingCountry,Opportunity__r.Account.shippingCity,Shipping_Entity_name__c,Billing_Entity_Name__c,
                    Opportunity__r.Account.shippingState,Opportunity__r.Account.shippingCountry,Opportunity__r.Account.shippingStreet,Opportunity__r.Account.Name,Billing_Postal_Code__c,Opportunity__r.Account.BillingPostalCode,Shipping_Postal_Code__c,Opportunity__r.Account.ShippingPostalCode
                    from Invoice__c where id=:inId];
        system.debug('Generate Invoice Data==> ' +inOppObj);
        if(inOppObj.Generate_Invoice_Number__c == null){
            inOppObj.Generate_Invoice_Number__c = String.valueOf(invoiceLatestNumber);
        }
        
        return inOppObj;
    }
    
    @AuraEnabled
    public Static Invoice__c  InsertInvoice(string shippingEntityName,string billingEntityName,Decimal generateInvoiceNumber,Decimal amount,String inId, Date subStartDate, Date subEndDate, String inNote, Date inDate, String product,string shippingState,String shippingCity,String shippingStreet,String updatedShipping,string billingState,String billingCity,String billingStreet,String billingCountry, String billingCode, String shippingCode ){
        try{
            list<Invoice__c> inVoiceList = new  list<Invoice__c>();
            System.debug('amount :: ' + amount + 'inId :: ' + inId + 'subStartDate ::' +subStartDate + 'subEndDate :: ' + subEndDate + inNote + inDate + product );
            List<Attachment> invAttachment = [SELECT Id,Name,ParentId FROM Attachment WHERE ParentId=:inId AND Name ='Invoice Pdf'];
            System.debug('invAttachment ::'+invAttachment.size());
            if(invAttachment.size()>0){
                for(Attachment att : invAttachment){
                    Attachment at = new Attachment();
                    at.id = att.id;
                    System.debug('at=====>'+at);
                    delete att;
                }
            }
            System.debug('invAttachment ::'+invAttachment.size());
            System.debug('shippingState::'+shippingState);
            Invoice__c  inObj = new  Invoice__c ();
            inObj.Invoice_Note__c=inNote;
            inObj.Subscription_Start__c=subStartDate;
            inObj.Subscription_End__c=subEndDate;
            inObj.Amount__c=amount;
            inObj.id=inId;
            inObj.Product__c=product;
            inObj.Invoice_Date__c=inDate;
            inObj.Invoice_Status__c='Posted';
            inObj.Shipping_Street__c = shippingStreet;
            inObj.Shipping_City__c = shippingCity;
            inObj.Shipping_State__c = shippingState;
            inObj.Shipping_Country__c = updatedShipping;
            inObj.Billing_Street__c = billingStreet;
            inObj.Billing_City__c = billingCity;
            inObj.Billing_State__c = billingState;
            inObj.Billing_Country__c = billingCountry;
            inObj.Invoiced_Amount__c = amount;
            inObj.Generate_Invoice_Number__c = String.valueOf(generateInvoiceNumber);
            inObj.Invoice_Generated__c = true;
            inObj.Shipping_Entity_name__c = shippingEntityName;
            inObj.Billing_Entity_Name__c  = billingEntityName;
            inObj.Enable_Overdue_Email__c = true;
            inObj.Billing_Postal_Code__c  = billingCode;
            inObj.Shipping_Postal_Code__c = shippingCode;
            System.debug('inObj update::'+inObj);
            
            generatePaymentLink(inId);
             System.debug('generatePaymentLink Callded');
             update inObj;
            Invoice_Latest_Number__c invNum = [select id,Latest_Invoice_Number__c from Invoice_Latest_Number__c];
            invNum.Latest_Invoice_Number__c = generateInvoiceNumber; 
            update invNum;
            //String pfdResponse = InvoicePDFCmpHelper_1.attachFileToOppotunities(inId);
            return inObj; 
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    @future(callout = true)
    public static void generatePaymentLink(String inId){ // Method 2
        String paymentlink = StripePaymentHandler.initiatePayment(inId); // Method 1
        system.debug('paymentlink::'+paymentlink);
        String pfdResponse = InvoicePDFCmpHelper_1.attachFileToOppotunities(inId);
        System.debug('Insert Invoice Callded');
    }
    
    public static void generatePaymentLinkForOverdueBatch(String inId){
        String paymentlink = StripePaymentHandler.initiatePayment(inId); // Method 1
        system.debug('paymentlink::'+paymentlink);
        //String pfdResponse = InvoicePDFCmpHelper_1.attachFileToOppotunities(inId);
        //System.debug('Insert Invoice Callded');
    }
    
    @AuraEnabled(cacheable=true)
    Public static Invoice__c fetchCreditNoteDetails(String invoiceId){
        try {
            decimal creditLatestNumber = 0;
            Invoice__c latestInvoice = [select id,CN_Number__c  from Invoice__c where CN_Number__c != null order by CN_Number__c desc limit 1];
            system.debug('latestInvoice::'+latestInvoice);
            if(latestInvoice == null || latestInvoice.CN_Number__c == null){
                system.debug('insode default value');
                creditLatestNumber = 10001;
            }else{
                system.debug('Outside value');
                creditLatestNumber = latestInvoice.CN_Number__c + 1;
            }
            Invoice__c  invoiceObject  = new Invoice__c();
            invoiceObject = [select id,Amount__c,CN_Number__c,Credit_Note__c,Credit_Note_Amount__c from Invoice__c where id=:invoiceId];
            if(invoiceObject.CN_Number__c == null){
                invoiceObject.CN_Number__c = creditLatestNumber;
            }
            
            return invoiceObject;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static Invoice__c generateCreditNote( String inId, Decimal amount , String creditNote ,Decimal cnNumber){
        
        
        Credit_Note__c crNote =new Credit_Note__c();
        crNote.Invoice__c	 = inId;
        crNote.Credit_Note__c = creditNote;
        crNote.Credit_Note_Amount__c = amount;
        crNote.Credit_Note_Date__c = system.today();
        insert crNote;
        List<Credit_Note__c> creditNoteDetails = [select id,Name,Credit_Note_Amount__c from Credit_Note__c where id =:crNote.Id];
        Invoice__c inv = [SELECT Id,Amount__c,Credit_Note_Amount__c,Credit_Note__c,Invoiced_Amount__c FROM Invoice__c WHERE Id=:inId];
        if(!creditNoteDetails.isEmpty()){
            if(inv.Credit_Note_Amount__c == null){
                inv.Credit_Note_Amount__c = creditNoteDetails[0].Credit_Note_Amount__c;
            }else{
                inv.Credit_Note_Amount__c = inv.Amount__c + creditNoteDetails[0].Credit_Note_Amount__c;
            }
            
            if(inv.Invoiced_Amount__c == inv.Credit_Note_Amount__c){
                inv.Payment_Status__c = 'Paid';
            }else{
                inv.Payment_Status__c = 'Partial Paid';
            }
            
            if(inv.Credit_Note__c != null){
                inv.Credit_Note__c = inv.Credit_Note__c +' ,' + creditNoteDetails[0].Name;
            }else{
                inv.Credit_Note__c = creditNoteDetails[0].Name;
            }
            
            update inv;
        }
        
        return inv;
    }
    @AuraEnabled
    public static Invoice__c upDateInvoiceCreditNote( String inId, Decimal amount , String creditNote ,Decimal cnNumber){
        try{
            return generateCreditNote(inId,  amount ,  creditNote , cnNumber);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    Public static Invoice__c manualPaymentInvoice(String invoiceId){
        try {
            Invoice__c  invoiceObject  = new Invoice__c();
            invoiceObject = [select id,Amount__c,Credit_Note__c,Paid_Amount__c,Invoiced_Amount__c,First_Payment_Check_Wire_No__c,Second_Payment_Check_Wire_No__c,Third_Payment_Check_Wire_No__c,Payment_Notes__c,Credit_Note_Amount__c,Payment_Status__c,Payment_Mode_Type__c,Payment_Date__c,First_Payment_Amount__c,First_Payment_Date__c,Second_Payment_Amount__c,Second_Payment_Date__c,Third_Payment_Amount__c,Third_Payment_Date__c from Invoice__c where id=:invoiceId];
            system.debug(invoiceObject);
            
            return invoiceObject;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Invoice__c upDateManualPayment( String invoiceId ,date paymentDate, String paymentModeType,String paymentStatus,Decimal reciviedAmount, String paymentNotes,Date firstPaymentDate, Decimal firstPaymentAmount, Date secondPaymentDate, Decimal secondPaymentAmount, Date thirdPaymentDate, Decimal thirdPaymentAmount, String firstPaymentCheckNo, String secondPaymentCheck, String thirdPaymentCheck ){
       

        try{
            Invoice__c inv = [SELECT Id,Name,First_Payment_Date__c,Paid_Amount__c,First_Payment_Amount__c,X1st_Reminder__c,X2nd_Reminder__c,X3rdReminder__c,X4th_Reminder__c,X5th_Reminder__c,Invoiced_Amount__c,First_Payment_Check_Wire_No__c,Second_Payment_Check_Wire_No__c,Third_Payment_Check_Wire_No__c,Second_Payment_Date__c,Second_Payment_Amount__c,Third_Payment_Date__c,Third_Payment_Amount__c FROM Invoice__c WHERE ID =:invoiceId];
            
            inv.Payment_Date__c=paymentDate;
            
            inv.Payment_Mode_Type__c=paymentModeType;
            if(inv.Paid_Amount__c != null){
                inv.Paid_Amount__c = inv.Paid_Amount__c + reciviedAmount;
            }else{
                inv.Paid_Amount__c = reciviedAmount;
            }
            if(inv.Invoiced_Amount__c > inv.Paid_Amount__c){
                inv.Payment_Status__c='Partial Paid';
            }else{
                inv.Payment_Status__c='Paid';
            }
            inv.Payment_Notes__c=paymentNotes;
            if(firstPaymentAmount != null){
                inv.First_Payment_Date__c = firstPaymentdate;
                inv.First_Payment_Amount__c = firstPaymentAmount;
                inv.First_Payment_Check_Wire_No__c = firstPaymentCheckNo;
            }else if(secondPaymentAmount != null){
                inv.Second_Payment_Date__c = secondPaymentDate;
                inv.Second_Payment_Amount__c = secondPaymentAmount;
                inv.Second_Payment_Check_Wire_No__c = secondPaymentCheck;
            }else if(thirdPaymentAmount != null){
                inv.Third_Payment_Date__c = thirdPaymentDate;
                inv.Third_Payment_Amount__c = thirdPaymentAmount;
                inv.Third_Payment_Check_Wire_No__c = thirdPaymentCheck;
            }
            update inv;
            return inv;
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
             return null;
            }
        
    }


    @AuraEnabled(cacheable=true)
    Public static Invoice__c voideInvoice(String invoiceId){
        try {
            Invoice__c  invoiceObject  = new Invoice__c();
            invoiceObject = [select id,Amount__c,Credit_Note__c,Invoiced_Amount__c,Payment_Notes__c,Credit_Note_Amount__c,Payment_Status__c,Payment_Mode_Type__c,Payment_Date__c from Invoice__c where id=:invoiceId];
            system.debug(invoiceObject);
            return invoiceObject;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public Static Invoice__c updateVoideInvoice ( String invoiceId){
        list<Invoice__c> inVoiceList = new  list<Invoice__c>();
        Invoice__c  inObj = new  Invoice__c ();
        //inObj.Payment_Status__c=paymentStatus;
        inObj.Invoice_Status__c='Voided';
        inObj.id=invoiceId;
        system.debug(inObj);
        update inObj;
        return inObj;
        
    }
    
    
    
    
    
    
}