@isTest
public class Test_LeadTriggerHanlder {
    Static testMethod void test_method(){
        lead ld = new lead();
        ld.Lastname = 'Test Method';
        ld.Company = 'Test Company';
        ld.Status = 'New';
        
        insert ld;
    }
}