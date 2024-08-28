global class CallOut_SubscriptionDetail {
    
    @future(callout = true)
    global static void subscriptionCallOutToQuizizz(Set<Id> oppIdList){
        try{
            list<Quizizz_Backend_Auth_Details__mdt> quizizzBackAuth = new list<Quizizz_Backend_Auth_Details__mdt>();
            quizizzBackAuth = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, API_Method__c, Content_Type__c, End_Point__c, Password__c, Username__c FROM Quizizz_Backend_Auth_Details__mdt ORDER BY DeveloperName ASC];
            
            List<SBQQ__Subscription__c> subList = [Select Id, SBQQ__Account__c 
                                                   From SBQQ__Subscription__c
                                                   Where  Opportunity__c in: oppIdList];
            
            List<Multischool_Subscription__c> multiSubList = [Select Id, Account__c 
                                                   From Multischool_Subscription__c
                                                   Where  Opportunity__c in: oppIdList];
            
            if(!subList.isEmpty()){
                for(SBQQ__Subscription__c subscriptionOnOpp : subList){
                    Requestwrapper ReqWrap = new Requestwrapper();
                    ReqWrap.subscriptionId = subscriptionOnOpp.id;
                    ReqWrap.accountId = subscriptionOnOpp.SBQQ__Account__c;
                    ReqWrap.subType = 'SBQQ_Subs';
                    String endpoint = quizizzBackAuth[0].End_Point__c;
                    string username = quizizzBackAuth[0].Username__c;
                    string password = quizizzBackAuth[0].Password__c;
                    Blob headerValue = Blob.valueOf(username + ':' + password);
                    String authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(headerValue);
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(endpoint);
                    request.setMethod('POST');
                    request.setHeader('Authorization', authorizationHeader);
                    request.setHeader('Content-Type', 'application/json');
                    string jsonReq = JSON.serialize(ReqWrap);
                    
                    request.setBody(jsonReq);
                    HttpResponse response = http.send(request);
                    system.debug('response::'+response.getBody());
                }
            }
            
            if(!multiSubList.isEmpty()){
                for(Multischool_Subscription__c subscriptionOnOpp : multiSubList){
                    Requestwrapper ReqWrap = new Requestwrapper();
                    ReqWrap.subscriptionId = subscriptionOnOpp.id;
                    ReqWrap.accountId = subscriptionOnOpp.Account__c;
                    ReqWrap.subType = 'Multischool_Subs';
                    String endpoint = quizizzBackAuth[1].End_Point__c;
                    string username = quizizzBackAuth[1].Username__c;
                    string password = quizizzBackAuth[1].Password__c;
                    Blob headerValue = Blob.valueOf(username + ':' + password);
                    String authorizationHeader = 'Basic ' +EncodingUtil.base64Encode(headerValue);
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(endpoint);
                    request.setMethod('POST');
                    request.setHeader('Authorization', authorizationHeader);
                    request.setHeader('Content-Type', 'application/json');
                    string jsonReq = JSON.serialize(ReqWrap);
                    
                    request.setBody(jsonReq);
                    HttpResponse response = http.send(request);
                    system.debug('response::'+response.getBody());
                }
            }
            
        }catch(Exception e){
            system.debug('exception::'+e.getStackTraceString());
        }
    }
    
    global class Requestwrapper{
        global String subscriptionId;			
        global String orgType ;
        global Date startDate ;
        global Date endDate ;
        global integer length;
        global String orgId;
        global String status;
        global decimal gracePeriod;
        global string PlanType;
        global string accountId;
        global string subType;
    }
}