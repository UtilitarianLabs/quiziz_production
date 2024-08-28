trigger TriggerOnInvoiceContact on Invoice_Contact__c (before insert,after insert) {
	
    if(trigger.isAfter && trigger.isInsert){
        InvoiceContactTriggerHandler.markContactCreatedFlag(trigger.new);
        InvoiceContactTriggerHandler.copyInvoiceContact(trigger.new);
        
    }
}