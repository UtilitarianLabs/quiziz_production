trigger TriggerOnInvoice on Invoice__c (before insert,before Update ,after update) {
    
    if(Trigger.isUpdate && Trigger.isBefore){
        InvoiceTriggerHandler.updatePaymentStatus(Trigger.new,Trigger.oldMap);
        InvoiceTriggerHandler.updateInvoicePaidPaymentStatus(trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.isAfter){
        //InvoiceTriggerHandler.generateInvoicePDF(Trigger.new,Trigger.oldMap);sendPaymentThankyouEmail
        //InvoiceTriggerHandler.sendThankyouEmail(trigger.new, trigger.oldMap);
        //InvoiceTriggerHandler.sendOverdueEmail(trigger.new, trigger.oldMap);
        for(Invoice__c inv :trigger.new){
            if(inv.Payment_Status__c !=null && inv.Payment_Status__c =='Paid' && inv.Payment_Status__c != trigger.oldmap.get(inv.id).Payment_Status__c){
                system.debug('inv.PaymentID__c === >'+inv.PaymentID__c);
                StripePaymentCallout.updatePaymentLink(inv.PaymentID__c,false);
            }
        }
    }
    if(trigger.isBefore && trigger.isInsert){
       // InvoiceTriggerHandler.UpdateInvoiceDueDate(trigger.new, trigger.oldMap);
    }
    if(trigger.isBefore && trigger.isUpdate){
        InvoiceTriggerHandler.UpdateInvoiceDueDate(trigger.new, trigger.oldMap);
    }
}