public class CreditNoteCompHelper {
    
    @AuraEnabled
    public static String attachFileToOppotunities(Id InvoiceId) {
        try{
            Invoice__c inv = [SELECT Id,Name,Opportunity__c FROM Invoice__c WHERE Id =: InvoiceId];
            Opportunity oppRec = [SELECT Id,Name FROM Opportunity WHERE ID =:inv.Opportunity__c];
            Id OpportunityId = oppRec.id;
            List<Attachment> attachList = new List<Attachment>();
            
            PageReference pdfPage = Page.CreditNoteVF;
            pdfPage.getParameters().put('id',InvoiceId);
            //Test.setCurrentPage(pref);
            blob pdfBody;
            pdfBody = (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('Fake content'));
            
            Attachment attach = new Attachment();
            attach.Body = pdfBody;
            attach.Name = 'Credit Note Pdf';
            attach.IsPrivate = false;
            attach.ParentId = inv.Id;
            attach.ContentType = 'application/pdf';
            
            attachList.add(attach);
            
            insert attachList;
            system.debug('attachList'+attachList);
            return attachList[0].Id;
            
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());  
        }
        return 'SUCCESS';
    }
    
}