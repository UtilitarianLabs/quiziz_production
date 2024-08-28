public class InvoiceTriggerHandler {
    
    Public Static void UpdateInvoiceDueDate(List<Invoice__c> InvoiceList,Map<Id,Invoice__c> mapofOldInvoice){
        try{
            for(Invoice__c inv1 : InvoiceList){
                    inv1.Due_Date__c = inv1.Invoice_Date__c.addDays(Integer.ValueOf(inv1.Payment_Term__c));
            }
        }catch(Exception e){
            System.debug('Error ::'+e.getMessage() +' AND Line ::'+e.getLineNumber());
        }
    }
	
    public static void updatePaymentStatus(List<Invoice__c> InvoiceList,Map<Id,Invoice__c> mapofOldInvoice){
        for(Invoice__c inc : InvoiceList){
            if(inc.Payment_Captured__c && inc.Payment_Captured__c != mapofOldInvoice.get(inc.id).Payment_Captured__c){
                inc.Payment_Status__c = 'Paid';
                inc.Payment_Mode_Type__c = 'Stripe Payment';
                inc.Paid_Amount__c = inc.Invoiced_Amount__c;
            }
        }
    }
    
    public Static void updateInvoicePaidPaymentStatus(List<Invoice__c> InvoiceList){
        System.debug('InvoiceList Paid :'+InvoiceList);
        for(Invoice__c inv : InvoiceList){
            if(inv.Payment_Status__c == 'Paid'){
                inv.Invoice_Status__c = 'Paid';
            }
        }
        
    }
    
    public static void sendThankyouEmail(List<Invoice__c> InvoiceList,Map<Id,Invoice__c> mapofOldInvoice){
        Set<Id> InvoiceId = new Set<Id>();
        for(Invoice__c inc : InvoiceList){
            if(inc.Payment_Status__c != null && inc.Payment_Mode_Type__c != null
               && inc.Payment_Status__c != mapofOldInvoice.get(inc.id).Payment_Status__c && inc.Payment_Status__c== 'Paid'){
                 InvoiceId.add(inc.Id);  
                
            }
        }
        
        if(!InvoiceId.isEmpty()){
            /*
            if(System.isFuture() || System.isBatch()) {
                 InvoiceThankyEmail.sendThankYouEmail(InvoiceId);
            }else{
                if(Limits.getFutureCalls() < Limits.getLimitFutureCalls()){
                     InvoiceThankyEmail.sendThankYouEmail(InvoiceId);
                }
            }
           */
        }
    }
    
    public static void sendOverdueEmail(List<Invoice__c> InvoiceList,Map<Id,Invoice__c> mapofOldInvoice){
        Set<Id> invoiceIdSet = new Set<Id>();
        for(Invoice__c inv : InvoiceList){
            system.debug('inv::'+inv);
            if(inv.Enable_Overdue_Email__c && inv.Payment_Status__c != null && inv.Payment_Status__c != mapofOldInvoice.get(inv.Id).Payment_Status__c && inv.Payment_Status__c == 'Overdue'){
                invoiceIdSet.add(inv.Id);
            }else if(inv.Payment_Status__c != null && inv.Payment_Status__c == 'Overdue' && inv.Enable_Overdue_Email__c && inv.Enable_Overdue_Email__c != mapofOldInvoice.get(inv.Id).Enable_Overdue_Email__c){
                invoiceIdSet.add(inv.Id);
            }
        }
        
        if(!invoiceIdSet.isEmpty()){
            //PaymentOverdueEmail.sednPaymentOverdueEmail(invoiceIdSet);
        }
    }
    
    public static void updateCreditNoteOnInvoice(Map<Id,String> invIdCreditNoteNo){
        Set<id> IdSet = new Set<Id>();
        List<String> creditNote = new List<String>();
        for(Id invId : invIdCreditNoteNo.keySet()){
            IdSet.add(invId);
        }
        
        System.debug('IdSet ::'+IdSet);
    }
    
    
}