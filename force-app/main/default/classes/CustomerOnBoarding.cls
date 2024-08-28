public without sharing  class CustomerOnBoarding {

    public static List<Account> acc;
    @AuraEnabled
    public static List<Account> getAccountDetails(Id accountId){
        CustomerOnBoarding.acc=[SELECT Id FROM Account WHERE Id=:accountId];
        return CustomerOnBoarding.acc;
    }
    
    @RemoteAction
    public static Boolean saveCustomerOnBoardingDetails(string cust){
        return saveCustomerOnBoarding(cust);
    }
    
    @RemoteAction
    public static String doCUploadAttachment(String attachmentBody, String attachmentName, string cvId, String udId) {
        system.debug('attachmentBody---'+attachmentName+'---attachmentId---'+cvId+'---cvId---'+udId);
        System.debug(attachmentBody);
        if(String.isBlank(attachmentBody) || String.isBlank(udId))
            return 'ERROR';
        if(String.isBlank(cvId)) {
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient = 'attachmentName'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = attachmentName; // Display name of the files
            
            conVer.VersionData = EncodingUtil.base64Decode(attachmentBody); // converting your binary string to Blog
            conVer.isMajorVersion = false;
            insert conVer;    //Insert ContentVersion
           System.debug(conVer.Id);
            ContentDistribution cdl = new ContentDistribution();
            cdl.ContentVersionId = conVer.Id;
            cdl.Name = 'PublicShare';
            cdl.RelatedRecordId = udId;
            insert cdl;
            system.debug('ContentDistribution----'+cdl);
            // First get the Content Document Id from ContentVersion Object
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            //create ContentDocumentLink  record
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = udId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
            conDocLink.shareType = 'V';
            insert conDocLink;
            System.debug(conDocLink);
            return conVer.Id;
        }else {
            List<ContentVersion> cvList = [SELECT Id, VersionData FROM ContentVersion WHERE Id = :cvId];
            if(!cvList.isEmpty()) {
                ContentVersion cVersion = cvList[0];
                if(cVersion.VersionData != null) {
                    String newBody = EncodingUtil.base64Encode(cVersion.VersionData);
                    newBody += attachmentBody;
                    cVersion.VersionData = EncodingUtil.base64Decode(newBody); // converting your binary string to Blog
                    update cVersion;
                    return cVersion.Id;
                }  
            }
        }
        return 'ERROR';
    }
    @AuraEnabled
    public static Boolean saveCustomerOnBoarding(string cust)
    {
        try
        {
            CustomerDetails details=(CustomerDetails)JSON.deserialize(cust, CustomerDetails.class);
            Customer_OnBoarding__c onBoard=new Customer_OnBoarding__c();
            onBoard.Account__c=details.accId;
            System.debug(details.oppId);
            if(details.oppId!=null){
                onBoard.Opportunity__c=details.oppId;
            }
                
            //onBoard.ownerId = '0059D000003s30RQAQ';
            insert onBoard;
            System.debug(onBoard);
            
            set<String> adminEmails;
            set<String> billingEmails;
           	if(onBoard.Id!=null)
            {
                List<OnBoarding_QAs__c> QasList=new List<OnBoarding_QAs__c>();
             
                for(Integer i=0;i<details.QAs.size();i++){
                    
                    OnBoarding_QAs__c data=new OnBoarding_QAs__c();
                    data.Question__c=details.QAs[i].get('qus');
                    data.Answer__c=details.QAs[i].get('value');
                    data.Customer_OnBoarding__c=onBoard.Id;
                    if(details.QAs[i].get('qus')=='Email addresses for anyone you\'d like to have "Admin" access to roster teachers on Quizizz'){
                        String [] strs= details.QAs[i].get('value').split(',');
                        adminEmails=new Set<String>(strs);
                    }
                    if(details.QAs[i].get('qus')=='Billing Contact email address (for your invoice):'){
                        String [] strs=details.QAs[i].get('value').split(',');
                        billingEmails = new set<string>(strs);
                    }
                    System.debug(adminEmails);
                    System.debug(billingEmails);
                    QasList.add(data);
                } 
                insert QasList;
                List<Contact> AdminContactList = [SELECT Id,Email,Admin_Contact__c FROM Contact WHERE AccountId = :onBoard.Account__c AND Email IN : adminEmails];
                for(Contact cont:AdminContactList){
                    cont.Admin_Contact__c=true;
                    adminEmails.remove(cont.Email);
                }
                update AdminContactList;
                List<Contact> BillingContactList = [SELECT Id,Email,Billing_Contact__c FROM Contact WHERE AccountId = :onBoard.Account__c AND Email IN : billingEmails];
                for(Contact cont: BillingContactList){
                    cont.Billing_Contact__c=true;
                    billingEmails.remove(cont.Email);
                }
                System.debug(adminEmails);
                System.debug(billingemails);
                update BillingContactList;
                List<Contact> newContacts= new List<Contact>();
                for(String adminEmail:adminEmails){
                    Contact cont= new Contact();
                    cont.AccountId=onBoard.Account__c;
                    cont.Email=adminEmail;
                    cont.LastName=adminEmail.split('@')[0];
                    cont.Admin_Contact__c=true;
                    newContacts.add(cont);
                }
                if(billingEmails.size()>0){
                    for(String billEmail:billingEmails){
                        Contact cont= new Contact();
                        cont.AccountId=onBoard.Account__c;
                        cont.Email=billEmail;
                        cont.LastName=billEmail.split('@')[0];
                        cont.Billing_Contact__c=true;
                        newContacts.add(cont);
                    }    
                }
                
                insert newContacts;
            	return true;
            }
            return false;
        }
        catch(Exception ex){
            System.debug(ex.getLineNumber());
            System.debug(ex.getCause());
            System.debug(ex.getMessage());
            return false;
        }
    }
    public class CustomerDetails
    {
        @AuraEnabled
        public string accId;
        
        @AuraEnabled
        public string oppId;
        
        @AuraEnabled
        public List<Map<string,string>> QAs;
       
    }
    public class CommentsInfo{
        @AuraEnabled
        public string oppId;
        
        @AuraEnabled
        public string comments;
    }
    @AuraEnabled
    public static Boolean saveComments(String comments){
        try{
            CommentsInfo details=(CommentsInfo)JSON.deserialize(comments, CommentsInfo.class);
            System.debug(details);
            if(details.oppId!=null){
                opportunity oppDet = new opportunity();
                oppDet.Rejection_Comments__c=details.comments;
                oppDet.Id = details.oppId;
                update oppDet;
                return true;    
            }
            return false;
            
        }
        catch(Exception ex){
            System.debug(ex.getCause());
            System.debug(ex.getLineNumber());
            System.debug(ex.getMessage());
            return false;
        }
    }
    
    @AuraEnabled
    public static List<Opportunity> getOpportunityDetails(Id oppId)
    {
        return [SELECT Id,SBQQ__PrimaryQuote__r.Name,Account.Name,Subscription_Start_Date__c,Contract_Length__c,Amount FROM Opportunity WHERE Id =:oppId];
    }
    class OnBoards{
        @AuraEnabled
        public List<OnBoarding_QAs__c> Qas;
        
        @AuraEnabled
        public Customer_OnBoarding__c board;
    }
    @AuraEnabled
    public static OnBoards getCustomerOnBoard(Id oppId){
        List<Customer_OnBoarding__c> onBoard=[SELECT Id FROM Customer_OnBoarding__c WHERE ( Opportunity__c=:oppId  OR Account__c=:oppId )LIMIT 1];
        System.debug(onBoard);
        if(onBoard.size()>0){
            List<OnBoarding_QAs__c> qas=[SELECT Id,Question__c,Answer__c FROM OnBoarding_QAs__c WHERE Customer_OnBoarding__c=:onBoard[0].Id];
            System.debug(qas);
            OnBoards boarding=new onBoards();
            boarding.Qas=qas;
            boarding.board=onBoard[0];
            return boarding;
        }
        return null;
    }
    
    @RemoteAction
    public static OnBoards getCustomerOnBoardDetails(Id oppId){
        
        List<Customer_OnBoarding__c> onBoard=[SELECT Id FROM Customer_OnBoarding__c WHERE ( Opportunity__c=:oppId  OR Account__c=:oppId )LIMIT 1];
        System.debug(onBoard);
        if(onBoard.size()>0){
            List<OnBoarding_QAs__c> qas=[SELECT Id,Question__c,Answer__c FROM OnBoarding_QAs__c WHERE Customer_OnBoarding__c=:onBoard[0].Id];
            System.debug(qas);
            OnBoards boarding=new onBoards();
            boarding.Qas=qas;
            boarding.board=onBoard[0];
            return boarding;
        }
        return null;
    }
    @AuraEnabled
    public static Boolean acceptTerms(Id oppId){
     	System.debug('oppId'+oppId);
        update new Opportunity(Id=oppId,Terms_Accepted__c=true);
        return true;
    }
    @AuraEnabled
    public static Boolean sendEmail(Id oppId)
    {
        try{
         	List<Opportunity> opps=[SELECT AccountId FROM Opportunity WHERE Id=:oppId AND AccountId!=null];
            if(opps.size()>0)
            {
            	List<Contact> contacts=[SELECT Id,Name,Email FROM Contact WHERE AccountId=:opps[0].AccountId AND Email!=null];
                List<Messaging.SingleEmailMessage> msg=new List<Messaging.SingleEmailMessage>();
                System.debug(contacts);
                for(Contact cont:contacts){
                    Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
                    email.toaddresses=new list<string>{cont.Email};
                    email.setSubject('Quizizz Order form');
                    string htmlContent='<p>Dear '+cont.Name+'</p><p>Please find digital order form on below mentioned link.</p>';
                    htmlContent+='<a href="https://quizizzdev-customer-onboard.cs76.force.com/Order?c='+oppId+'">Click here </a> ';
                    htmlContent+='<p>Thank you, <br/>Quizizz Team</p>';
                    email.setHtmlBody(htmlContent);
                    //email.setPlainTextBody('https://quizizz--quizizzdev--c.visualforce.com/apex/OrderForm?c='+oppId);
                    msg.add(email);
                }
                if(msg.size()>0){
                    List<Messaging.SendEmailResult> results =  Messaging.sendEmail(msg);
                    System.debug(results);
                    if (!results.get(0).isSuccess()) {
                        System.StatusCode statusCode = results.get(0).getErrors()[0].getStatusCode();
                        String errorMessage = results.get(0).getErrors()[0].getMessage();
                        return true;
                    }
                    else
                    {
                        return false;
                    }
                }
            }
            return false;
        }
        catch(Exception ex)
        {
            System.debug(ex.getLineNumber());
            System.debug(ex.getCause());
            System.debug(ex.getMessage());
            return false;   
        }
        
    }
}