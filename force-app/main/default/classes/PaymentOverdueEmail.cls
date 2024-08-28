public class PaymentOverdueEmail {
    
    public Static void sednPaymentOverdueEmail(Set<Id> invoiceIdSet){
        try{
            if(!invoiceIdSet.isEmpty()){
                List< Invoice__c> invList = [SELECT Id,Name,Invoice_Number__c,Invoice_Status__c,Payment_Date__c,Invoiced_Amount__c,Payment_Mode_Type__c,Subscription_End__c,Due_Date__c,Payment_URL__c,Payment_Status__c,Amount__c FROM Invoice__c WHERE ID IN : invoiceIdSet];
                System.debug('invList Size ::'+invList.size());
                List<Invoice_Contact__c> invoiceConList = [select id,Contact__r.Id,Contact__r.Name,Contact__r.Email,Invoice__r.Name,Invoice__c,Invoice__r.Amount__c,Invoice__r.Payment_URL__c,Invoice__r.Due_Date__c from Invoice_Contact__c where Invoice__c in: invoiceIdSet];
                System.debug('invoiceConList Size ::'+invoiceConList.size());
                List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                EmailTemplate temp = [SELECT Id,Subject,Body,HTMLValue FROM EmailTemplate WHERE Name ='Payement Overdue Email'];
                if(!invoiceConList.isEmpty()){
                    String subject = temp.Subject;
                    String plainTextBody = temp.body;
                    for(Invoice_Contact__c inv  : invoiceConList){
                        System.debug('Email ::'+inv.Contact__r.email);
                        String htmlBody = temp.HTMLValue;
                        htmlBody = htmlBody.replace('{!Invoice__c.Name}', inv.Invoice__r.Name); 
                        htmlBody = htmlBody.replace('{!Invoice__c.Due_Date__c}', String.valueOf(inv.Invoice__r.Due_Date__c));
                        htmlBody = htmlBody.replace('{!Invoice__c.Amount__c}', String.valueOf(inv.Invoice__r.Amount__c)); 
                        htmlBody = htmlBody.replace('{!Invoice__c.Payment_URL__c}', inv.Invoice__r.Payment_URL__c);
                        
                        htmlBody = htmlBody.replace('{!$Label.Account_Name}', System.Label.Account_Name);
                        htmlBody = htmlBody.replace('{!$Label.Bank_name}', System.Label.Bank_name);
                        htmlBody = htmlBody.replace('{!$Label.Account_Number}', System.Label.Account_Number);
                        htmlBody = htmlBody.replace('{!$Label.Routing_Number}', System.Label.Routing_Number);
                        htmlBody = htmlBody.replace('{!$Label.Routing_NumberACH}', System.Label.Routing_NumberACH);
                        htmlBody = htmlBody.replace('{!$Label.SWIFT_Code}', System.Label.SWIFT_Code);
                        htmlBody = htmlBody.replace('{!$Label.Bank_Address}', System.Label.Bank_Address);
                        subject = subject.replace('{!Invoice__c.Name}', inv.Invoice__r.Name);  
                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setUseSignature(false);
                        mail.setHtmlBody(htmlBody);
                        mail.setSubject(subject);
                        mail.setPlainTextBody(plainTextBody);
                        mail.setToAddresses(new String[] {inv.Contact__r.email});
                        mailList.add(mail);
                        if(!mailList.isEmpty()){
                            Messaging.sendEmail(mailList);
                        }
                    }
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());   
        }
    }
}