public class CreditNoteAuraPDFController {
    @AuraEnabled
    public Static String insertCreditNote(String recordId){
        System.debug('recordId CreditNote ::'+recordId);
        try{
            List<Attachment> attList = new List<Attachment>();
            Credit_Note__c credit = [SELECT Id,Name,Invoice__c,Credit_Note__c,Credit_Note_Amount__c FROM Credit_Note__c WHERE Id=:recordId LIMIT 1];
            PageReference pdfPage = Page.CreditNoteVF;
            pdfPage.getParameters().put('id',credit.id);
            blob pdfBody;
            pdfBody = pdfPage.getContent();
            
            Attachment att = new Attachment();
            att.Body = pdfBody;
            att.ParentId = credit.id;
            att.Name ='CreditNote PDF.pdf';
            att.IsPrivate = false;
            att.ContentType = 'application/pdf';
            attList.add(att);
            if(!attList.isEmpty()){
                insert attList;
            }
            System.debug('attList[0].id ::'+attList[0].id);
            return attList[0].id;
        }catch(Exception e){
            System.debug('Error ::'+e.getMessage() + 'AND Error Line ::'+e.getLineNumber());
        }
        return null;
    }
}