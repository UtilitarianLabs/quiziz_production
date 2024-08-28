public class InvoicePDFCmpHelper_1 {
    @AuraEnabled
    public static String attachFileToOppotunities(Id InvoiceId) {
        try{
            system.debug('inId'+InvoiceId);
            Invoice__c inv = [SELECT Id,Name,Opportunity__c,Generate_Invoice_Number__c FROM Invoice__c WHERE Id =: InvoiceId];
            Opportunity oppRec = [SELECT Id,Name FROM Opportunity WHERE ID =:inv.Opportunity__c];
            Id OpportunityId = oppRec.id;
            List<Attachment> attachList = new List<Attachment>();
            
            PageReference pdfPage = Page.InvoicePDF_1;
            pdfPage.getParameters().put('id',InvoiceId);
            
            List<Attachment> attList = [Select id,name from Attachment where parentId =:InvoiceId AND Name LIKE '%_Invoice.Pdf%' ];
            System.debug('attList Size ::'+attList.size());
            if(attList.size()>0){
                System.debug('Invoice Deleted Successfully');
              delete attList;
            }
            
            blob pdfBody;
          // pdfBody = pdfPage.getContent();
            pdfBody = (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('Fake content'));
            Attachment attach = new Attachment(); 
            attach.Body = pdfBody;
            attach.Name = inv.Generate_Invoice_Number__c+'_Invoice.Pdf';
            attach.IsPrivate = false;
            attach.ParentId = inv.Id;
            attach.ContentType = 'application/pdf';
            //if(attList.size() > 0){
                //system.debug('Already Invoices are there');
                //attach.Name = inv.Generate_Invoice_Number__c+'_OverdueInvoice.Pdf';
            //}else{
                attach.Name = inv.Generate_Invoice_Number__c+'_Invoice.Pdf';
            //}
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