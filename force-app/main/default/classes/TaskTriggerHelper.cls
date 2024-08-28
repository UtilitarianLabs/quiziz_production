public with sharing class TaskTriggerHelper {
    public TaskTriggerHelper() {
        
    }
    
    public static void validateClosedWonTask(list<task> newTaskList){
        boolean validationRequired = false;
        if(!newTaskList.isEmpty()){
            set<string> opportunityIdSet = new set<string>();
            list<opportunity> opportunityList = new list<opportunity>();
            for(task ts : newTaskList){
                if(ts.Status == 'Completed' && ts.subject =='Onboarding task for customer'){
                    opportunityIdSet.add(ts.whatId);
                }
                
            }
            if(!opportunityIdSet.isEmpty()){
                opportunityList = [select id,StageName,Contact_Verify_Status__c,Teacher_Rostering_Status__c,LMS_Activation__c,Customer_Success_Stage__c from opportunity where id in: opportunityIdSet];
                for(Opportunity opp : opportunityList){
                    if(opp.Contact_Verify_Status__c == null){
                        validationRequired = true;
                    }else if(opp.Teacher_Rostering_Status__c == null){
                        validationRequired = true;                        
                    }else if(opp.LMS_Activation__c == null){
                        validationRequired = true;
                    }else if(opp.Customer_Success_Stage__c == null || opp.Customer_Success_Stage__c != 'Onboarding Complete'){
                        validationRequired = true;
                    }
                }
                
                for(task ts : newTaskList){
                    if(validationRequired){
                        ts.addError('Please fill contact verify status,Teacher roasting status,LMS Activation at opportunity level to complete this task.');
                    }
                }
            }
            
            
        }
    }
    
    public static void createInvoiceSubscriptionTask(list<task> newTaskList){
        if(!newTaskList.isEmpty()){
            list<task> taskListTobeInsert = new list<task>();
            for(Task ts : newTaskList){
                if(ts.status == 'Completed' && ts.subject == 'Customer Onboarding Task'){
                    task invoiceTask = new task();
                    invoiceTask.whatId = ts.whatId;
                    invoiceTask.Subject = 'Generate Invoive Task';
                    invoiceTask.OwnerId = ts.ownerId;
                    invoiceTask.ActivityDate = system.today() + 7;
                    invoiceTask.Priority = 'Normal';
                    invoiceTask.Status = 'Open';
                    taskListTobeInsert.add(invoiceTask);
                    
                    
                    /*task subscriptionTask = new task();
subscriptionTask.whatId = ts.whatId;
subscriptionTask.Subject = 'Create Subscrption Task';
subscriptionTask.OwnerId = ts.ownerId;
subscriptionTask.ActivityDate = system.today() + 7;
subscriptionTask.Priority = 'Normal';
subscriptionTask.Status = 'Open';
taskListTobeInsert.add(subscriptionTask);*/
                }
            }
            
            if(!taskListTobeInsert.isEmpty()){
                insert taskListTobeInsert;
            }
        }
    }
    
    @auraEnabled
    public static void createSubscriptionRecord(string oppId){
        system.debug('oppId::'+oppId);
        list<contract> contractListTobeUpdate = new list<contract>();
        contractListTobeUpdate = [select id,StartDate from contract where SBQQ__Opportunity__c =: oppId];
        system.debug('contractListTobeUpdate::'+contractListTobeUpdate);
        if(!contractListTobeUpdate.isEmpty()){
            system.debug('contractListTobeUpdate::'+contractListTobeUpdate);
            for(Contract conDetails : contractListTobeUpdate){
                conDetails.StartDate = conDetails.StartDate;
            }
            system.debug('contractListTobeUpdate::'+contractListTobeUpdate);
            update contractListTobeUpdate;
            
            opportunity oppDet = new opportunity();
            oppDet.Opportunity_Subscription_Created__c = true;
            oppDet.Id = oppId;
            //Update oppDet;
        }
    }
    
    
    
}