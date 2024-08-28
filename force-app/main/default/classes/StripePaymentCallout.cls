public without sharing class StripePaymentCallout {
	public static final String api_key = label.Stripe_API_Key;
    @future (callout=true)
    public static void updatePaymentLink(String paymentId, boolean activated){
        try{
        	HTTP http = new HTTP();
        	HttpRequest req = new HttpRequest();    
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setEndpoint('https://api.stripe.com/v1/payment_links/'+paymentId);
            req.setHeader('Authorization', 'Bearer '+api_key);
            req.setMethod('POST');
            
            String payload = 'active='+activated;
            req.setBody(payload);

        	HTTPResponse res = http.send(req);
            Map<String,Object> jsonBody = (Map<String,Object>) Json.deserializeUntyped(res.getBody());
            
            if(jsonBody.get('active')!=null){
             	System.debug('SELECTEDBODY---'+jsonBody.get('active').toString());
        	}
            String Result = res.getStatusCode() == 200 ? 'Success':'Failure';
            system.debug('Result ===> '+Result);
          //  return res.getStatusCode() == 200 ? 'Success':'Failure';
        }catch(Exception e){
         //	return e.getMessage();   
        }
    }
}