public class InvoiceContactTriggerHandler {
	public static boolean blockContactInvoiceCreation = false;
    public static void copyInvoiceContact(List<Invoice_Contact__c> invoiceContactList){
        Set<Id> invoiceIdSet = new Set<Id>();
        Set<Id> invoiceIdSetTobeSend = new Set<Id>();
        Set<Id> opportunityIdSet = new Set<Id>();
        for(Invoice_Contact__c inc : invoiceContactList){
            invoiceIdSet.add(inc.Invoice__c);
            opportunityIdSet.add(inc.Opportunity_Id__c);
        }
        
        if(!opportunityIdSet.isEmpty()){
            
            List<Invoice__c> invoiceList = new List<Invoice__C>();
            invoiceList = [select id from Invoice__c where Contact_Created__c = false and Opportunity__c in : opportunityIdSet and Id not in : invoiceIdSet and Invoice_Status__c = 'Draft'];
            for(Invoice__c inc : invoiceList){
                invoiceIdSetTobeSend.add(inc.Id);
            }
        }
        
        if(!invoiceIdSetTobeSend.isEmpty()){
            Utility.copyInvoiceContact(invoiceContactList,invoiceIdSetTobeSend);
        }
    }
    
    public static void markContactCreatedFlag(List<Invoice_Contact__c> invoiceContactList){
        Set<Id> invoiceIdSet = new Set<Id>();
        for(Invoice_Contact__c ic : invoiceContactList){
            invoiceIdSet.add(ic.Invoice__c);
        }
        
        if(!invoiceIdSet.isEmpty()){
            List<Invoice__c> invoiceListTobeUpdate = new list<Invoice__c>();
            for(Id invId : invoiceIdSet){
                Invoice__c inv = new Invoice__c();
                inv.Id = invId;
                inv.Contact_Created__c = true;
                invoiceListTobeUpdate.add(inv);
            }
            
            if(!invoiceListTobeUpdate.isEmpty()){
                update invoiceListTobeUpdate;
            }
        }
        
    }
}