public class SendOverdueFirstReminderBatch Implements Database.batchable <Sobject>,Database.AllowsCallouts,Database.Stateful{
    public Database.queryLocator Start(Database.batchableContext bx){
        String query = 'SELECT Id,Name,Due_Date__c,Amount__c,Payment_URL__c,Payment_Status__c,X1st_Reminder__c,X2nd_Reminder__c,X3rdReminder__c,X4th_Reminder__c,X5th_Reminder__c,Generate_Invoice_Number__c,Over_Due_Amount__c FROM Invoice__c WHERE Enable_Overdue_Email__c = true and X1st_Reminder__c = false AND Over_Due_Amount__c > 0 AND Contact_Created__c = true ';
        return Database.getQueryLocator(query);
    }
    public void Execute(Database.batchableContext bc, List<Invoice__c> invoiceList){
        Set<Id> InvIdSet = new Set<Id>();
        Map<Id,String> mapofInvoiceIdbyReminderCount = new Map<Id,String>();
        OrgWideEmailAddress owea = [SELECT Id, Address FROM OrgWideEmailAddress limit 1];
        for(Invoice__c invConc: invoiceList){
            if(invConc.Due_Date__c != null){
                System.debug('YES --> '+ 1);
                System.debug('invConc Record === > '+invConc);
                if((invConc.Due_Date__c) == system.today()){
                    System.debug('YES --> '+ 2);
                    System.debug('system.today() --> '+system.today());
                    InvIdSet.add(invConc.Id); 
                    mapofInvoiceIdbyReminderCount.put(invConc.Id,'first');
                }
            }
        }
        
        if(!InvIdSet.isEmpty()){
            System.debug('YES --> '+ 3);
            StripePaymentModule.generateStripePaymentLink(InvIdSet);
            List<Invoice_Contact__c> invoiceConList = [select id,Contact__r.Id,Contact__r.Name,Contact__r.Email,Invoice__r.Generate_Invoice_Number__c,Invoice__r.Name,Invoice__r.Due_Date__c,Invoice__r.Amount__c,Invoice__r.Over_Due_Amount__c,Invoice__r.Payment_URL__c,Invoice__c,Active_Email__c,Primary_Contact__c from Invoice_Contact__c where Invoice__c IN: InvIdSet AND Active_Email__c = true];
            EmailTemplate temp = [SELECT Id,Subject,Body,HTMLValue FROM EmailTemplate WHERE Name ='On-the-day Reminder Email'];
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            List<Invoice__c> invRecordList = [SELECT Id,Name,Generate_Invoice_Number__c,Due_Date__c,Amount__c,Payment_URL__c FROM Invoice__c WHERE Id IN:InvIdSet];
            if(!invRecordList.isEmpty() && invRecordList.size()>0){
                for(Invoice__c invRecord : invRecordList){
                    List<String> ToaddressList = new List<String>();
                    List<String> toBccAddressList = new List<String>();
                    for(Invoice_Contact__c con : invoiceConList){
                        if(con.Invoice__c == invRecord.Id){
                            System.debug('YES --> '+ 4);
                            if(con.Active_Email__c == true && con.Primary_Contact__c){
                                System.debug('YES --> '+ 5);
                                ToaddressList.add(con.Contact__r.Email);
                                System.debug('ToaddressList Email --> '+ToaddressList);
                            }else if(con.Active_Email__c){
                                toBccAddressList.add(con.Contact__r.Email);
                            }
                        }
                    }
                    toBccAddressList.add('billing@quizizz.com');
                    System.debug('ToaddressList Email Overdue First::'+ToaddressList);
                    PageReference pdfPage = Page.InvoicePDF_1;
                    pdfPage.getParameters().put('id',invRecord.Id);
                    System.debug('pdfPage ::'+pdfPage);
                    Blob Blobbody;
                    Blobbody =  (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('Fake content'));
                    System.debug('Blobbody ::'+Blobbody);
                    
                    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                    attach.setContentType('application/pdf');
                    if(!String.isBlank(invRecord.Generate_Invoice_Number__c)){
                        attach.setFileName(invRecord.Generate_Invoice_Number__c+'_OverdueInvoice_1.pdf');
                    }
                    attach.setInline(false);
                    attach.Body = Blobbody;
                    String subject = temp.Subject;
                    String plainTextBody = temp.body;
                    String htmlBody = temp.HTMLValue;
                    if(!String.isBlank(invRecord.Generate_Invoice_Number__c)){
                        htmlBody = htmlBody.replace('{!Invoice__c.Generate_Invoice_Number__c}', invRecord.Generate_Invoice_Number__c); 
                    }
                    
                    htmlBody = htmlBody.replace('{!Invoice__c.Due_Date__c}', String.valueOf(invRecord.Due_Date__c));
                    htmlBody = htmlBody.replace('{!Invoice__c.Amount__c}', String.valueOf(invRecord.Amount__c));
                    if(!String.isBlank(invRecord.Payment_URL__c)){
                        htmlBody = htmlBody.replace('{!Invoice__c.Payment_URL__c}', invRecord.Payment_URL__c);
                    }
                    htmlBody = htmlBody.replace('{!$Label.Account_Name}', System.Label.Account_Name);
                    htmlBody = htmlBody.replace('{!$Label.Bank_name}', System.Label.Bank_name);
                    htmlBody = htmlBody.replace('{!$Label.Account_Number}', System.Label.Account_Number);
                    htmlBody = htmlBody.replace('{!$Label.Routing_Number}', System.Label.Routing_Number);
                    htmlBody = htmlBody.replace('{!$Label.Routing_NumberACH}', System.Label.Routing_NumberACH);
                    htmlBody = htmlBody.replace('{!$Label.SWIFT_Code}', System.Label.SWIFT_Code);
                    htmlBody = htmlBody.replace('{!$Label.Bank_Address}', System.Label.Bank_Address);
                    subject = subject.replace('{!Invoice__c.Name}', invRecord.Name);
                    if(!String.isBlank(invRecord.Generate_Invoice_Number__c)){
                        subject = subject.replace('{!Invoice__c.Generate_Invoice_Number__c}', invRecord.Generate_Invoice_Number__c);
                    }
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setUseSignature(false);
                    mail.setHtmlBody(htmlBody);
                    mail.setSubject(subject);
                    mail.setPlainTextBody(plainTextBody);
                    mail.setToAddresses(ToaddressList);
                    mail.setCcAddresses(toBccAddressList);
                    mail.setOrgWideEmailAddressId(owea.Id);
                    System.debug('owea.Id ::'+owea.Id);
                    mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
                    mailList.add(mail);
                }
                
            }
            
            //  }
            
            if(!mailList.isEmpty()){
                Messaging.sendEmail(mailList);
            }
            
            List<Invoice__c> invoiceListTobeUpdate = new List<Invoice__c>();
            for(Id invId : mapofInvoiceIdbyReminderCount.keySet()){
                Invoice__c inv = new Invoice__c();
                inv.Id = invId;
                if(mapofInvoiceIdbyReminderCount.get(invId) != null && mapofInvoiceIdbyReminderCount.get(invId) == 'first'){
                    inv.X1st_Reminder__c = true;
                }
                if(mapofInvoiceIdbyReminderCount.get(invId) != null && mapofInvoiceIdbyReminderCount.get(invId) == 'second'){
                    inv.X2nd_Reminder__c = true;
                }
                if(mapofInvoiceIdbyReminderCount.get(invId) != null && mapofInvoiceIdbyReminderCount.get(invId) == 'third'){
                    inv.X3rdReminder__c = true;
                }
                if(mapofInvoiceIdbyReminderCount.get(invId) != null && mapofInvoiceIdbyReminderCount.get(invId) == 'fourth'){
                    inv.X4th_Reminder__c = true;
                }
                if(mapofInvoiceIdbyReminderCount.get(invId) != null && mapofInvoiceIdbyReminderCount.get(invId) == 'fifth'){
                    inv.X5th_Reminder__c = true;
                }
                
                invoiceListTobeUpdate.add(inv);
            }
            
            if(!invoiceListTobeUpdate.isEmpty()){
                update invoiceListTobeUpdate;
            }
        }
        
        
        
    }
    public void Finish(Database.batchableContext bc){
        
    }
}