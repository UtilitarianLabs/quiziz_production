public class PaidInvoiceAuraController {
    
    @AuraEnabled
    public static String attachPaidInvoicePDF(Id InvoiceId) {
        try{
            Invoice__c inv = [SELECT Id,Name,Opportunity__c,Opportunity__r.Is_Contract_Created__c,Opportunity__r.StageName,Generate_Invoice_Number__c FROM Invoice__c WHERE Id =: InvoiceId];
            System.debug('inv ::'+inv);
            Set<Id> invIdSet = new Set<Id>();
            invIdSet.add(inv.id);
            if(!invIdSet.isEmpty()){
               // InvoiceThankyEmail.sendThankYouEmail(invIdSet);
            }

            List<Attachment> attList = [Select id,name from Attachment where parentId =:InvoiceId AND Name LIKE '%_Paid_Invoice.Pdf%' ];
            System.debug('attList Size ::'+attList.size());
            if(attList.size()>0){
                System.debug('Paid Invoice Deleted Successfully');
              delete attList;
            }

            List<Attachment> attachList = new List<Attachment>();
            PageReference pdfPage = Page.PaidInvoicePDF;   
            pdfPage.getParameters().put('id',InvoiceId);
            blob pdfBody;
           // pdfBody = pdfPage.getContent();
            pdfBody = (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('Fake content'));
            Attachment attach = new Attachment(); 
            attach.Body = pdfBody;
            attach.Name = inv.Generate_Invoice_Number__c+'_Paid_Invoice.Pdf';
            attach.IsPrivate = false;
            attach.ParentId = inv.Id;
            attach.ContentType = 'application/pdf';
            attachList.add(attach);
            if(!attachList.isEmpty()){
                insert attachList;
            }
            system.debug('attachList'+attachList);
            return attachList[0].Id;
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());  
        }
        return 'SUCCESS';
    }
}