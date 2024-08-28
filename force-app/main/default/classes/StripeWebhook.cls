@RESTResource(urlMapping='/webhooklistener/*')
global without sharing class StripeWebhook {
    public static final String api_key = label.Stripe_API_Key;
    @HttpPost
    global static string webhookListener(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        System.debug('Headers'+req.Headers);
        System.debug('REQ----'+req);
        System.debug('PARAMS----'+req.params.get('type'));
        System.debug('Body-----'+req.requestBody.toString());



        Map<String,Object> jsonBody = (Map<String,Object>) Json.deserializeUntyped(req.requestBody.toString());

        if(jsonBody.get('type')!=null && jsonBody.get('type')=='checkout.session.completed'){
            try{
                Map<String,Object> m2 =  (Map<String, Object>) jsonBody.get('data');
                Map<String,Object> m3 =  (Map<String, Object>) m2.get('object');
                Map<String,Object> m4 =  (Map<String, Object>) m3.get('metadata');
    
                String recId = m4.get('order_id').toString();
                String platform = m4.get('platform').toString();
                String accId = m4.get('account_id').toString();
                String oppId = m4.get('opportunity_id').toString();
 
                String pId = m3.get('payment_intent').toString();
    			String description = platform + ' customer: ' + accId + ', Invoice: ' + recId + ', Opportunity: ' + oppId;
                
                String payload = 'description=' + description;
                
                // updating the description in payment Intent
                
                HTTP http = new HTTP();
                HttpRequest updateReq = new HttpRequest();
        
                updateReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                updateReq.setEndpoint('https://api.stripe.com/v1/payment_intents/' + pId);
                updateReq.setHeader('Authorization', 'Bearer '+api_key);
                updateReq.setMethod('POST');
                updateReq.setBody(payload);
        
                http.send(updateReq);
                
                Invoice__c iv = new Invoice__c(Id=recId,Payment_Captured__c=true,Payment_Intent_Id__c=pId,Payment_Date__c=system.today());
                update iv;
            }catch(Exception e){
                System.debug('Error occuered here---'+e);
            }
        }

        if(jsonBody.get('type')!=null && jsonBody.get('type')=='charge.succeeded'){
            try{
                Map<String,Object> m2 =  (Map<String, Object>) jsonBody.get('data');
                Map<String,Object> m3 =  (Map<String, Object>) m2.get('object');
                String txnId = m3.get('balance_transaction').toString();
                String pId = m3.get('payment_intent').toString();
    
                Invoice__c iv = [Select Id,Paid_By_Name__c,Paid_By_Email__c,Paid_By_Phone__c,Transaction_Id__c,Failure_Balance_Txn__c,Payment_Failure_Code__c,Payment_Failure_Message__c From Invoice__c Where Payment_Intent_Id__c=:pId];
                if(iv!=null){
                    iv.Transaction_Id__c = txnId;
                    update iv;
                }
            }catch(Exception e){
                System.debug('Error occuered here---'+e);
            }
        }

        if(jsonBody.get('type')!=null && jsonBody.get('type')=='payment_intent.succeeded'){
            try{
                Map<String,Object> m2 =  (Map<String, Object>) jsonBody.get('data');
                Map<String,Object> m3 =  (Map<String, Object>) m2.get('object');
                Map<String,Object> m4 =  (Map<String, Object>) m3.get('charges');
                List<Object> m5 =  (List<Object>) m4.get('data');
                Map<String,Object> m6 = (Map<String, Object>) m5[0];

                Map<String,Object> m7 = (Map<String, Object>) m6.get('billing_details');

                String pId = m3.get('id').toString();
                String name = m7.get('name').toString();
                String email = m7.get('email').toString();
                String phone = m7.get('phone')!=null ? m7.get('phone').toString():null;
                String txnId = m6.get('balance_transaction').toString();
                String fbt = m6.get('failure_balance_transaction')!=null ? m6.get('failure_balance_transaction').toString():null;
                String fCode = m6.get('failure_code')!=null ? m6.get('failure_code').toString():null;
                String fMessage = m6.get('failure_message')!=null ? m6.get('failure_message').toString():null;


                Invoice__c iv = [Select Id,Paid_By_Name__c,Paid_By_Email__c,Paid_By_Phone__c,Transaction_Id__c,Failure_Balance_Txn__c,Payment_Failure_Code__c,Payment_Failure_Message__c From Invoice__c Where Payment_Intent_Id__c=:pId];

                iv.Paid_By_Name__c = name;
                iv.Paid_By_Email__c = email;
                iv.Paid_By_Phone__c = phone;
                iv.Transaction_Id__c = txnId;
                iv.Failure_Balance_Txn__c = fbt;
                iv.Payment_Failure_Code__c = fCode;
                iv.Payment_Failure_Message__c = fMessage;

                update iv;

                System.debug('PAYMENT INTENT----'+m6.toString());
            }catch(Exception e){
                System.debug('Error occuered here---'+e);
            }
        }
        return req.requestBody.toString();
    }
}