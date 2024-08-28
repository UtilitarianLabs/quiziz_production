public class BatchOnCustomerSuccess implements Database.Batchable <Sobject> {
    
    public Database.QueryLocator Start(Database.BatchableContext bc){
        String query = 'select id,admin_contact__c,billing_contact__c,contact_verify_status__c,Customer_success_stage__c,IT_contact__c,lms_activation_status__c,Opportunity_ID__c,teacher_rostering_status__c from Customer_Success__c';
        return Database.getQueryLocator(query);
    }
    public void Execute(Database.BatchableContext bc, List<Customer_Success__c> cusList){
        List<Opportunity> oppListTobeUpdate = new List<Opportunity>();
        for(Customer_Success__c cs : cusList){
            Opportunity opp = New Opportunity();
            opp.Admin_User_Email_Address__c = cs.admin_contact__c;
            opp.Billing_Accounts_Receivable_Email_Addres__c = cs.billing_contact__c;
            opp.Contact_Verify_Status__c =  cs.contact_verify_status__c;
            opp.Customer_Success_Stage__c = cs.Customer_success_stage__c;
            opp.IT_Contact__c = cs.IT_contact__c;
            opp.LMS_Activation__c = cs.lms_activation_status__c;
            opp.Id = cs.Opportunity_ID__c;
            opp.Teacher_Rostering_Status__c = cs.teacher_rostering_status__c;
            oppListTobeUpdate.add(opp);
        }
        update oppListTobeUpdate;
    }
    
    public void Finish(Database.BatchableContext bc){
        System.debug('The Batch Run Successfully');
    }
}