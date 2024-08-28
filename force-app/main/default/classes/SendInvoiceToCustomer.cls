public class SendInvoiceToCustomer {
    
    @AuraEnabled
    public static void SendEmailAdnPDFToCustomer(String invoiceId){
        try{
            system.debug('invoice ID:: '+invoiceId);
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            EmailTemplate temp = [SELECT Id,Subject,Body,HTMLValue FROM EmailTemplate WHERE Name ='On Invoice generation'];
            OrgWideEmailAddress owea = [SELECT Id, Address FROM OrgWideEmailAddress limit 1];
            Invoice__c invoiceList = [SELECT Id,Opportunity__c,Amount__c,Generate_Invoice_Number__c,Enable_Shipping__c,Invoice_Status__c,Payment_Status__c,Name,Billing_Contact__c,Payment_URL__c,Billing_Contact__r.Name,Billing_Contact__r.Email from Invoice__c WHERE ID =: invoiceId  LIMIT 1];
            system.debug('invoiceList Record ::'+invoiceList.Generate_Invoice_Number__c);
         
            List<Invoice_Contact__c> invoiceConList = [select id,Contact__r.Id,Contact__r.Name,Contact__r.Email,Invoice__r.Name,Active_Email__c,Primary_Contact__c from Invoice_Contact__c where Invoice__c =: invoiceId  AND Active_Email__c = true];
            System.debug('List Invoice Contact Email ::'+invoiceConList.size());
            
            PageReference pdfPage = Page.InvoicePDF_1;
            pdfPage.getParameters().put('id',invoiceId);
            System.debug('pdfPage ::'+pdfPage);
            Blob Blobbody;
            Blobbody =  (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('Fake content'));
            System.debug('Blobbody ::'+Blobbody);
            
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setContentType('application/pdf');
            attach.setFileName(invoiceList.Generate_Invoice_Number__c+'_Invoice.pdf');
            attach.setInline(false);
            attach.Body = Blobbody;
            
            String subject = temp.Subject;
            String plainTextBody = temp.body;
            
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
                String htmlBody = temp.HTMLValue;
               	//htmlBody = htmlBody.replace('{!Invoice__c.Billing_Contact__r.Name}', con.Contact__r.Name); 
                htmlBody = htmlBody.replace('{!Invoice__c.Amount__c}', String.valueOf(invoiceList.Amount__c)); 
                htmlBody = htmlBody.replace('{!Invoice__c.Payment_URL__c}', invoiceList.Payment_URL__c);
                htmlBody = htmlBody.replace('{!$Label.Account_Name}', System.Label.Account_Name);
                htmlBody = htmlBody.replace('{!$Label.Bank_name}', System.Label.Bank_name);
                htmlBody = htmlBody.replace('{!$Label.Account_Number}', System.Label.Account_Number);
                htmlBody = htmlBody.replace('{!$Label.Routing_Number}', System.Label.Routing_Number);
                htmlBody = htmlBody.replace('{!$Label.Routing_NumberACH}', System.Label.Routing_NumberACH);
                htmlBody = htmlBody.replace('{!$Label.SWIFT_Code}', System.Label.SWIFT_Code);
                htmlBody = htmlBody.replace('{!$Label.Bank_Address}', System.Label.Bank_Address);
                subject = subject.replace('{!Invoice__c.Generate_Invoice_Number__c}', invoiceList.Generate_Invoice_Number__c); 
                System.debug('subject ::'+subject);
                System.debug('htmlBody ::'+htmlBody);
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setUseSignature(false);
                mail.setHtmlBody(htmlBody);
                mail.setSubject(subject);
                mail.setReplyTo(owea.Address);
                mail.setPlainTextBody(plainTextBody);
                mail.setToAddresses(ToaddressList);
                mail.setCcAddresses(toBccAddressList);
                mail.setOrgWideEmailAddressId(owea.Id);
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
                mailList.add(mail);
                system.debug('mailList::'+mailList);
            //}
            
            if(!mailList.isEmpty()){
                Messaging.sendEmail(mailList);
                Invoice__c inToUp = new Invoice__c();
                inToUp.id = invoiceList.id;
                inToUp.Invoice_Status__c = 'Sent';
                inToUp.Payment_Status__c = 'Open';
                update inToUp;
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        
    }
    
}