public class InvoiceThankyEmail  {
    @future(callout = true)
    public Static void sendThankYouEmail(Set<Id> RecordIdList){
        try{
            List< Invoice__c> invList = [SELECT Id,Name,Invoice_Number__c,Invoice_Status__c,Payment_Date__c,Invoiced_Amount__c,Payment_Mode_Type__c,Subscription_End__c,Billing_Contact__r.Email,Billing_Contact__r.Name,Payment_URL__c,Payment_Status__c,Amount__c,Payment_Notes__c,Generate_Invoice_Number__c FROM Invoice__c WHERE ID IN : RecordIdList];
            OrgWideEmailAddress owea = [SELECT Id, Address FROM OrgWideEmailAddress limit 1];
            Map<Id,Invoice__c> mapofInvIdByInv = new Map<Id,Invoice__c>();
            System.debug('invList::'+invList);
            if(!invList.isEmpty()){
                for(Invoice__c invRec : invList){
                    mapofInvIdByInv.put(invRec.Id,invRec);
                }
                system.debug('mapofInvIdByInv::'+mapofInvIdByInv);
                List<Invoice_Contact__c> invoiceConList = [select id,Contact__r.Id,Contact__r.Name,Contact__r.Email,Invoice__r.Name,Invoice__c from Invoice_Contact__c where Invoice__c in: RecordIdList];
                system.debug('invoiceConList::'+invoiceConList);
                List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                EmailTemplate temp = [SELECT Id,Subject,Body,HTMLValue FROM EmailTemplate WHERE Name ='Payment Success Email'];
                system.debug('temp::'+temp);
                List<String> ToaddressList = new List<String>();
                List<String> toBccAddressList = new List<String>();
                for(Invoice_Contact__c con : invoiceConList){
                    
                    if(con.Active_Email__c == true && con.Primary_Contact__c){
                        ToaddressList.add(con.Contact__r.Email);
                        System.debug('ToaddressList Email --> '+ToaddressList);
                    }else if(con.Active_Email__c){
                        toBccAddressList.add(con.Contact__r.Email);
                    }
                }
                toBccAddressList.add('billing@quizizz.com');
                //for(Invoice_Contact__c invCon : invoiceConList){
                    PageReference pdfPage = Page.PaidInvoicePDF;
                    pdfPage.getParameters().put('id',invList[0].Id);
                    System.debug('pdfPage ::'+pdfPage);
                    Blob Blobbody;
                    Blobbody = pdfPage.getContent();
                    //  Blobbody = (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('Fake content'));
                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                    attach.setContentType('application/pdf');
                    attach.setFileName(invList[0].Generate_Invoice_Number__c+'_Invoice.pdf');
                    attach.setInline(false);
                    attach.Body = Blobbody;
                    
                    String htmlBody = temp.HTMLValue;
                    String subject = temp.Subject;
                    String plainTextBody = temp.body; 
                    //htmlBody = htmlBody.replace('{!Invoice__c.Billing_Contact__r.Name}', ' Team'); 
                    htmlBody = htmlBody.replace('{!Invoice__c.Invoice_Number__c}', String.valueOf(invList[0].Generate_Invoice_Number__c)); 
                    htmlBody = htmlBody.replace('{!Invoice__c.Invoiced_Amount__c}', String.valueOf(invList[0].Invoiced_Amount__c)); 
                    htmlBody = htmlBody.replace('{!Invoice__c.Payment_Date__c}', String.valueOf(invList[0].Payment_Date__c));
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setUseSignature(false);
                    mail.setHtmlBody(htmlBody);
                    mail.setSubject(subject);
                    mail.setPlainTextBody(plainTextBody);
                mail.setToAddresses(ToaddressList);
                mail.setCcAddresses(toBccAddressList);
                mail.setOrgWideEmailAddressId(owea.Id);
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
                    mailList.add(mail);
                    System.debug('EMIL SUCCESS::'+mailList);
               // }
                
                if(!mailList.isEmpty()){
                    Messaging.sendEmail(mailList);
                }
                
            }
        }catch(Exception e){
            system.debug('Exception Trace::'+e.getStackTraceString());
        }
    }
}