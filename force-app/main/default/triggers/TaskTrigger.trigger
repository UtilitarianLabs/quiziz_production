trigger TaskTrigger on Task (before insert,after insert,before update,after update) {

    if(trigger.isUpdate && trigger.isBefore){
        TaskTriggerHelper.validateClosedWonTask(trigger.new);

    }
    if(trigger.isUpdate && trigger.isAfter){
        TaskTriggerHelper.createInvoiceSubscriptionTask(trigger.new);
    }
}