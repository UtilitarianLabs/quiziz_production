public with sharing class StripePaymentHandler {
    
    public static final String api_key = label.Stripe_API_Key;//'sk_test_51JGIo1SBpHKZJ9YR3S6ZddcbJnmL7vhbFkH6v3razColNsgqKJAG7TQnKDHypfXtQFvjQgr0DpYCdUJxegIPf64X00NHpx1296';
    
    public StripePaymentHandler() {
    }
    
    
    
    @AuraEnabled
    public static String initiatePayment(String recordId){  // Method 1
        //String url = null;
        
        Invoice__c inv = [Select Id,Name,Amount__c,Generate_Invoice_Number__c,Opportunity__c,Opportunity__r.AccountId From Invoice__c Where Id=:recordId];
        
        String priceId = createProductAndPrice(String.valueOf(inv.Generate_Invoice_Number__c),inv.Amount__c*100,recordId,inv.Opportunity__c,inv.Opportunity__r.AccountId);
        system.debug('priceId::'+priceId);
        Map<String,String> MapOfPaymentlink_PaymentId = createPaymentLink(priceId,recordId,inv.Opportunity__c,inv.Opportunity__r.AccountId);  
        String url = MapOfPaymentlink_PaymentId.get('url');
        String paymentId = MapOfPaymentlink_PaymentId.get('id');
        //return url;
        system.debug('url::'+url);
        if(!String.isBlank(recordId)){
            Invoice__c inv1 = new Invoice__c();
            inv1.Id = recordId;
            inv1.Payment_URL__c = URL;
            inv1.Payment_Status__c = 'Draft';
             inv1.PaymentID__c = paymentId;
            update inv1;
            //updateUrlLinkToInvoice(recordId,url);
        }
        return url;
    }
    
    @AuraEnabled
    public static string updateURL(String ivId,String url){
        try {
            updateUrlLinkToInvoice(ivId,url);
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @future
    public static void updateUrlLinkToInvoice(string invId,string URL){
        Invoice__c inv = new Invoice__c();
        inv.Id = invId;
        inv.Payment_URL__c = URL;
        inv.Payment_Status__c = 'Draft';
        update inv;
    }
    
    @AuraEnabled(cacheable=true)
    public static String createProductAndPrice(String oppName, Decimal amount,String recId,String AccId,String OppId){
        
        String priceId = null;
        
        String payload = 'name='+'Invoice Number : '+oppName+'&metadata[order_id]='+recId;
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setEndpoint('https://api.stripe.com/v1/products');
        req.setHeader('Authorization', 'Bearer '+api_key);
        req.setMethod('POST');
        req.setBody(payload);
        
        HTTPResponse res = http.send(req);
        Map<String,Object> jsonBody = (Map<String,Object>) Json.deserializeUntyped(res.getBody());
        
        if(jsonBody.get('id')!=null){
            priceId = createPrice(amount,jsonBody.get('id').toString(),recId);
        }
        System.debug('Response------'+jsonBody.toString());
        
        return priceId;
    }
    
    @AuraEnabled(cacheable=true)
    public static String createPrice(Decimal amount, String productId,String recId){
        String priceId = null;
        
        String payload = 'currency=USD'+'&product='+productId+'&unit_amount='+Integer.valueOf(amount)+'&metadata[order_id]='+recId;
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setEndpoint('https://api.stripe.com/v1/prices');
        req.setHeader('Authorization', 'Bearer '+api_key);
        req.setMethod('POST');
        req.setBody(payload);
        
        HTTPResponse res = http.send(req);
        Map<String,Object> jsonBody = (Map<String,Object>) Json.deserializeUntyped(res.getBody());
        
        
        if(jsonBody.get('id')!=null){
            priceId = jsonBody.get('id').toString();
        }
        System.debug('Response------'+jsonBody.toString());
        
        return priceId;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,String> createPaymentLink(String priceId,String recId,Id oppId,Id accId){
        Map<String,String> paymentLink_paymentIdMap = new  Map<String,String>();
        String paymentLink = null;
        String paymentId = null;
        
        String payload = 'line_items[0][price]='+priceId+'&line_items[0][quantity]=1'+'&metadata[order_id]='+recId+'&metadata[opportunity_id]='+oppId+'&metadata[account_id]='+accId+'&metadata[platform]=salesforce';
        
        
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setEndpoint('https://api.stripe.com/v1/payment_links');
        req.setHeader('Authorization', 'Bearer '+api_key);
        req.setMethod('POST');
        req.setBody(payload);
        
        HTTPResponse res = http.send(req);
        Map<String,Object> jsonBody = (Map<String,Object>) Json.deserializeUntyped(res.getBody());
        System.debug('JSON Body ==>'+jsonBody);
        
        if(jsonBody.get('url')!=null){
            paymentLink = jsonBody.get('url').toString();
        }
        
        
        if(jsonBody.get('id')!=null){
            paymentId = jsonBody.get('id').toString();
        }
        paymentLink_paymentIdMap.put('id',paymentId);
        paymentLink_paymentIdMap.put('url',paymentLink);
        
        system.debug('paymentLink::'+paymentLink);
        system.debug('paymentId::'+paymentId);
        
        createCheckoutSession(priceId);
        
        
        return paymentLink_paymentIdMap;
    }
    
    public static void createCheckoutSession(String priceId){
        String paymentLink = null;
        
        String payload = 'line_items[0][price]='+priceId+'&line_items[0][quantity]=1'+'&success_url=https://quizizz--quizizzuat.sandbox.lightning.force.com/lightning/r/Invoice__c/a1i1y000000KciDAAS/view&mode=payment&cancel_url=https://quizizz--quizizzuat.sandbox.lightning.force.com/lightning/r/Invoice__c/a1i1y000000KciDAAS/view';
        
        
        HTTP http = new HTTP();
        HttpRequest req = new HttpRequest();
        
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setEndpoint('https://api.stripe.com/v1/checkout/sessions');
        req.setHeader('Authorization', 'Bearer '+api_key);
        req.setMethod('POST');
        req.setBody(payload);
        
        HTTPResponse res = http.send(req);
        Map<String,Object> jsonBody = (Map<String,Object>) Json.deserializeUntyped(res.getBody());
    }
    
    public class PaymentLinkWrapper{
        public List<LineItems> line_items;
        public MetadataWrapper metadata;
    }
    
    public class MetadataWrapper{
        public String rec_id;
    }
    
    public class LineItems{
        public String price;
        public Integer quantity;
    }
}