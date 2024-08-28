public class StripePaymentModule {
    
    public static void generateStripePaymentLink(Set<Id> parentObjIdSet){
        List<Invoice__c> invList = [Select Id,Name,Amount__c,Generate_Invoice_Number__c,Opportunity__c,
                                    Opportunity__r.AccountId,Over_Due_Amount__c 
                                    From 
                                    Invoice__c 
                                    Where Id in: parentObjIdSet];
        Map<Id,Map<String,String>> mapOfInvIdByURL = new Map<Id,Map<String,String>>();
        if(!invList.isEmpty()){
            for(Invoice__c inv : invList){
                String priceId = StripePaymentHandler.createProductAndPrice(String.valueOf(inv.Generate_Invoice_Number__c),inv.Over_Due_Amount__c*100,inv.Id,inv.Opportunity__c,inv.Opportunity__r.AccountId);
                system.debug('priceId::'+priceId);
                Map<String,String> resMap = StripePaymentHandler.createPaymentLink(priceId,inv.Id,inv.Opportunity__c,inv.Opportunity__r.AccountId);
               
                mapOfInvIdByURL.put(inv.id,resMap);
            }
        }
        List<Invoice__c> invoiceListTobeUpdate = new List<Invoice__c>();
        for(Id invId : mapOfInvIdByURL.keySet()){
            Invoice__c inv = new Invoice__c();
            inv.Id = invId;
            inv.Payment_URL__c = mapOfInvIdByURL.get(invId).get('url');
            inv.PaymentID__c = mapOfInvIdByURL.get(invId).get('id');
            invoiceListTobeUpdate.add(inv);
        }
        if(invoiceListTobeUpdate.size() > 0){
            update invoiceListTobeUpdate;
        }
        
        
    }
}