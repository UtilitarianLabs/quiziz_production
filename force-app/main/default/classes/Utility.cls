public class Utility {
    
    public static void PilotOpportunityContactRoles(set<Id> pilotOpportunityIds){
        List<Id> idList = new List<Id>(pilotOpportunityIds);
        Id pilotOppId = idList[0];
        List<Opportunity> pilotsOpportunities=[SELECT Id,Pilot_Parent__c FROM Opportunity WHERE Id IN : pilotOpportunityIds];
        set<Id> pilots=new set<Id>();
        for(Opportunity pilot:pilotsOpportunities){
            if(pilot.Pilot_Parent__c!=null){
                pilots.add(pilot.Pilot_Parent__c);
            }
        }
        List<OpportunityContactRole> contactRoles=[SELECT Id,OpportunityId,ContactId,Role from OpportunityContactRole WHERE OpportunityId = : pilots];
        system.debug('contactRoles::'+contactRoles);
        List<OpportunityContactRole> oppContacts=new List<OpportunityContactRole>();
        
        for(Opportunity opp:pilotsOpportunities){
            for(OpportunityContactRole oppCont:contactRoles ){
                if(oppCont.OpportunityId==opp.Pilot_Parent__c){
                    OpportunityContactRole oppContactRole= new OpportunityContactRole();
                    oppContactRole.ContactId=oppCont.ContactId;
                    oppContactRole.Role=oppCont.Role;
                    oppContactRole.OpportunityId=pilotOppId;
                    oppContacts.add(oppContactRole);
                }
            }
        }
        system.debug('oppContacts::'+oppContacts);
        //insert oppContacts;
        list<ContentDocumentLink> conDocTobeInsert = new list<ContentDocumentLink>();
        List<ContentDocumentLink> contentDocs= [SELECT ContentDocumentId, ContentDocument.CreatedDate,ContentDocument.Title, sharetype, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId in : pilots];
        system.debug('contentDocs::'+contentDocs);
        if(!contentDocs.isEmpty()){
            for(ContentDocumentLink conDoc : contentDocs){
                ContentDocumentLink con = new ContentDocumentLink();
                con.ContentDocumentId = conDoc.ContentDocumentId;
                con.sharetype = conDoc.sharetype;
                con.LinkedEntityId = pilotOppId;
                conDocTobeInsert.add(con);
            }
            if(!conDocTobeInsert.isEmpty()){
                insert conDocTobeInsert;
            }
            
        }
        
        
    }
    
    public static void createOnboardingTaskOnClosedWon(Map<Id,Id> mapofOppIdByCSId){
        List<Task> createOnboardingTask = new List<Task>();
        for(Id oppId:mapofOppIdByCSId.keyset()){
            Task createTask= new Task();
            createTask.WhatId		= 	oppId;
            createTask.Priority		=	'Normal';
            createTask.Status		=	'Open';
            createTask.Subject		=	'Onboarding task for customer';
            createTask.ActivityDate	=	Date.today().addDays(15);
            createTask.OwnerId		=	mapofOppIdByCSId.get(oppId);
            createOnboardingTask.add(createTask);
        }
        
        if(!createOnboardingTask.isEmpty()){
            insert createOnboardingTask;
        }
    }
    
    public static void changeContactOwnerTOCS(set<Id> accountIdList){
        if(!accountIdList.isEmpty()){
            list<Contact> contcatListTobeUpdate = new list<Contact>();
            contcatListTobeUpdate = [select id,ownerId,accountid,account.Customer_Success__c,account.ownerId from contact where accountId in: accountIdList];
            
            if(!contcatListTobeUpdate.isEmpty()){
                for(Contact con : contcatListTobeUpdate){
                    if(con.account.Customer_Success__c != null)
                        con.OwnerId = con.account.Customer_Success__c;
                    con.Sales_Owner__c = con.account.ownerId;
                }
                
                update contcatListTobeUpdate;
            }
        }
    }
    public static void updateAccountSubscriptionType(Set<Id> accIdSet,Map<Id,String> mapofAccIDByOppOrgType){
        List<Account> accListTobeUpdate = new List<Account>();
        for(Id accId : accIdSet){
            Account acc = new Account();
            acc.Id = accId;
            acc.Subscription_Type__c = mapofAccIDByOppOrgType.get(accId);
            accListTobeUpdate.add(acc);
        }
        
        if(!accListTobeUpdate.isEmpty()){
            update accListTobeUpdate;
        }
    }
    
    public static void updateSubscriptionDates(set<Id> opportunityIds){
        map<String,Integer> mapOfConIdByConLength = new map<String,Integer>();
        map<String,Opportunity> mapOfOppidbyOpp = new map<String,Opportunity>();
        List<Opportunity> opps=[SELECT Id,Subscription_End_Date__c,Additiona_Period_Date__c FROM Opportunity WHERE Id=:opportunityIds];
        list<OpportunityLineItem> oppLineItem = [select id,Subscription_End_Date__c,UnitPrice,OpportunityId,ProductCode from opportunityLineItem where opportunityId in: opportunityIds];
        System.debug('opps::'+opps);
        for(Opportunity opp:opps){
            //opp.Subscription_End_Date__c=opp.Additiona_Period_Date__c;
            mapOfOppidbyOpp.put(opp.id,opp);
        }
        //update opps;
        if(!oppLineItem.isEmpty()){
            for(OpportunityLineItem oppLine : oppLineItem){
                if(oppLine.UnitPrice > 0 || oppLine.ProductCode.contains('Pilot')){
                    oppLine.Subscription_End_Date__c = mapOfOppidbyOpp.get(oppLine.OpportunityId).Additiona_Period_Date__c;
                }
            }
            
            update oppLineItem;
        }
        
        
        List<SBQQ__Quote__c> quotes= [SELECT Id,SBQQ__EndDate__c,SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c IN : opportunityIds AND SBQQ__Primary__c=true];
        System.debug(quotes);
        if(!quotes.isEmpty()){
            for(SBQQ__Quote__c quote:quotes){
                for(Opportunity opp:opps){
                    
                    if(quote.SBQQ__Opportunity2__c==opp.Id){
                        System.debug(quote.SBQQ__EndDate__c);
                        quote.SBQQ__EndDate__c=opp.Additiona_Period_Date__c;
                        System.debug(quote.SBQQ__EndDate__c);
                    }
                }
            }
            update quotes;
        }
        
        List<Contract> oppContracts=[SELECT Id,StartDate,EndDate,SBQQ__Opportunity__c,ContractTerm from Contract WHERE SBQQ__Opportunity__c=:opportunityIds];
        if(!oppContracts.isEmpty()){
            for(Contract oppConts:oppContracts){
                for(Opportunity opp:opps){
                    if(oppConts.SBQQ__Opportunity__c==opp.Id){
                        oppConts.EndDate=opp.Additiona_Period_Date__c;
                        oppConts.ContractTerm = oppConts.StartDate.monthsBetween(oppConts.EndDate) + 1;
                        mapOfConIdByConLength.put(oppConts.Id,oppConts.ContractTerm);
                    }
                }
            }
            update oppContracts;            
        }
        
        List<SBQQ__Subscription__c> subscriptions=[SELECT Id,Contract_Length__c,SBQQ__SubscriptionEndDate__c,SBQQ__SubscriptionStartDate__c,Opportunity__c,SBQQ__Contract__c from SBQQ__Subscription__c where Opportunity__c IN : opportunityIds];
        if(!subscriptions.isEmpty()){
            for(SBQQ__Subscription__c subscribe:subscriptions){
                for(Opportunity opp:opps){
                    if(subscribe.Opportunity__c==opp.Id){
                        subscribe.SBQQ__SubscriptionEndDate__c=opp.Additiona_Period_Date__c;
                        subscribe.Contract_Length__c = mapOfConIdByConLength.get(subscribe.SBQQ__Contract__c);
                    }
                }
            }
            update subscriptions;
        }
        
    }
    
    public static void addContactRoles(set<Id> oppIds){
        
        set<Id> accId=new set<Id>();
        List<Opportunity> opps= [SELECT Id,AccountId FROM Opportunity WHERE Id=: oppIds];
        for(Opportunity opp:[SELECT Id,AccountId FROM Opportunity WHERE Id=: oppIds]){
            accId.add(opp.AccountId);
        }
        List<Contact> contacts=[SELECT Id,AccountId FROM Contact WHERE AccountId=:accId];
        List<OpportunityContactRole> oppConts=new List<OpportunityContactRole>();
        
        if(!contacts.isEmpty()){
            for(Contact cont:contacts){
                for(Opportunity opp:opps){
                    if(opp.AccountId==cont.AccountId){
                        OpportunityContactRole oppCont=new OpportunityContactRole();
                        oppCont.ContactId =cont.Id;
                        oppCont.OpportunityId=opp.Id;
                        oppCont.Role = 'Business User';
                        oppConts.add(oppCont);    
                    }
                }
            }
            if(!oppConts.isEmpty()){
                //insert oppConts;
            }
        }
        
        
    }
    
    public static void createDepartmentQuoteLineItem(Opportunity oppDetails,String quoteId,map<string,SBQQ__BlockPrice__c> mapofBlockIdByBlockPrice,string prodId,decimal newSlabPrice){
        integer subscriptionPeriod = 0;
        integer totalSubscriptionPeriod = 0;
        system.debug('oppDetails::'+oppDetails);
        list<SBQQ__QuoteLine__c> quoteLinesTobeInsert = new list<SBQQ__QuoteLine__c>();
        
        if(oppDetails.Contract_Length__c != null && oppDetails.Contract_Length__c >=0 && oppDetails.Contract_Length__c <= 23){
            subscriptionPeriod = 12;
        }else if(oppDetails.Contract_Length__c != null && oppDetails.Contract_Length__c >=24 && oppDetails.Contract_Length__c <= 35){
            subscriptionPeriod = 24;
        }else if(oppDetails.Contract_Length__c != null && oppDetails.Contract_Length__c >35){
            subscriptionPeriod = 36;
        }
        if(oppDetails.Contract_Length__c != null){
            if(oppDetails.Create_Trial__c){
                totalSubscriptionPeriod = Integer.valueOf(String.valueOf(oppDetails.Trial_Period_In_Month__c)) + Integer.valueOf(String.valueOf(oppDetails.Contract_Length__c));
            }else{
                totalSubscriptionPeriod = Integer.valueOf(oppDetails.Trial_Period_In_Month__c);
            }
        }
        for(string key : mapofBlockIdByBlockPrice.keySet()){
            for(Integer count = 0; count < Integer.valueOf(oppDetails.Department_Count__c);count++){
                SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                quoteLine.SBQQ__Product__c = prodId;
                quoteLine.SBQQ__Quantity__c = 1;
                quoteLine.SBQQ__PricingMethod__c = 'Block';
                quoteLine.SBQQ__ProductSubscriptionType__c = 'Renewable';
                quoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                quoteLine.SBQQ__DefaultSubscriptionTerm__c = totalSubscriptionPeriod;
                quoteLine.SBQQ__SubscriptionType__c = 'Renewable';
                system.debug('mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c::'+mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c);
                
                if(oppDetails.Deal_Organization_Type__c == 'Department'){
                    if(oppDetails.Deal_Confirmed_Enrollment__c <= 1500 && newSlabPrice != 0){
                        quoteLine.SBQQ__ListPrice__c = newSlabPrice;
                        quoteLine.Slab_Price__c = newSlabPrice;
                    }else if(oppDetails.Deal_Confirmed_Enrollment__c <= 1500){
                        quoteLine.SBQQ__ListPrice__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                        quoteLine.Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                    }else if(oppDetails.Deal_Confirmed_Enrollment__c > 1500 && newSlabPrice != 0){
                        quoteLine.SBQQ__ListPrice__c = newSlabPrice;
                        quoteLine.Slab_Price__c = newSlabPrice;
                    }else if(oppDetails.Deal_Confirmed_Enrollment__c > 1500){
                        quoteLine.SBQQ__ListPrice__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                        quoteLine.Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                    }
                }else if(newSlabPrice != 0){
                    quoteLine.SBQQ__ListPrice__c = ((newSlabPrice * oppDetails.Contract_Length__c)/12) * 1;
                    quoteLine.Slab_Price__c = newSlabPrice;
                }
                
                //update oppList;
                quoteLine.SBQQ__Quote__c = quoteId;
                system.debug('quoteLine::'+quoteLine);
                quoteLinesTobeInsert.add(quoteLine);
            }
            
            
        }
        
        if(!quoteLinesTobeInsert.isEmpty()){
            insert quoteLinesTobeInsert;
        }
    }
    
    public static void CreateAdminContact(String adminEmails,Id accountId){
        String [] strs= adminEmails.split(',');
        set<String> adminEmailset=new Set<String>(strs);
        List<Contact> AdminContactList = [SELECT Id,Email,Admin_Contact__c FROM Contact WHERE AccountId = :accountId AND Email IN : adminEmailset];
        for(Contact cont:AdminContactList){
            cont.Admin_Contact__c=true;
            adminEmailset.remove(cont.Email);
        }
        update AdminContactList;
        List<Contact> newContacts= new List<Contact>();
        for(String adminEmail:adminEmailset){
            Contact cont= new Contact();
            cont.AccountId=accountId;
            cont.Email=adminEmail;
            cont.LastName=adminEmail.split('@')[0];
            cont.Admin_Contact__c=true;
            newContacts.add(cont);
        }
        insert newContacts;
    }
    public static void CreateItContact(String ITContacts,Id AccountId){
        String [] strs= ITContacts.split(',');
        set<String> ITEmailset=new Set<String>(strs);
        
        List<Contact> ITContactsList = [SELECT Id,Email,IT_Contact__c FROM Contact WHERE AccountId = :AccountId AND Email IN : ITEmailset];
        for(Contact cont: ITContactsList){
            cont.IT_Contact__c =true;
            ITEmailset.remove(cont.Email);
        }
        List<Contact> newContacts=new List<Contact>();
        for(String billEmail:ITEmailset){
            Contact cont= new Contact();
            cont.AccountId=AccountId;
            cont.Email=billEmail;
            cont.LastName=billEmail.split('@')[0];
            cont.IT_Contact__c=true;
            newContacts.add(cont);
        }    
        insert newContacts;
    }
    public static void CreateBillingContact(String BillingEmails,Id AccountId){
        String [] strs= BillingEmails.split(',');
        set<String> BillingEmailSet=new Set<String>(strs);
        
        List<Contact> BillingContactList = [SELECT Id,Email,Billing_Contact__c FROM Contact WHERE AccountId = :AccountId AND Email IN : billingEmailSet];
        for(Contact cont: BillingContactList){
            cont.Billing_Contact__c=true;
            billingEmailSet.remove(cont.Email);
        }
        List<Contact> newContacts=new List<Contact>();
        for(String billEmail:billingEmailSet){
            Contact cont= new Contact();
            cont.AccountId=AccountId;
            cont.Email=billEmail;
            cont.LastName=billEmail.split('@')[0];
            cont.Billing_Contact__c=true;
            newContacts.add(cont);
        }    
        insert newContacts;
    }
    
    public static void oppContactMapping(Decimal eligibleTeacherCount,String oppId,String ITContact,String AdminUser,String BillingEmail,string lms,string lmsAccountInfo,List<OpportunityContactRole> oppContactRoles,String conVerifyStatus,String teacheRoastReason,String lmsActivation,String customerSuccessStage){
        system.debug('oppContactRoles::'+oppContactRoles);
        if(oppId!=null){
            Opportunity opps = new Opportunity();
            if(ITContact != null)
                opps.IT_Contact__c = ITContact;
            if(AdminUser != null)
                opps.Admin_User_Email_Address__c = AdminUser;
            if(BillingEmail != null)
                opps.Billing_Accounts_Receivable_Email_Addres__c = BillingEmail;
            opps.Id = oppId;
            if(lms != null)
                opps.lms__C = lms;
            if(lmsAccountInfo != null)
                opps.LMS_Account_Info__c = lmsAccountInfo;
            if(conVerifyStatus != null)
                opps.Contact_Verify_Status__c = conVerifyStatus;
            if(lmsActivation != null)
                opps.LMS_Activation__c = lmsActivation;
            if(teacheRoastReason != null)
                opps.Teacher_Rostering_Status__c = teacheRoastReason;
            if(eligibleTeacherCount != null){
                opps.Confirmed_Eligible_Teachers__c = eligibleTeacherCount;
            }
            if(customerSuccessStage != null){
                opps.Customer_Success_Stage__c = customerSuccessStage;
                opps.StageName = 'LifeCycle Engagement';
            }
            update opps;
            List<OpportunityContactRole> oppContact=new List<OpportunityContactRole>();
            /*for(OpportunityContactRole oppCont:oppContactRoles){
OpportunityContactRole contRole=new OpportunityContactRole();
contRole.OpportunityId=oppCont.OpportunityId;
contRole.Role=oppCont.Role;
contRole.ContactId = oppCont.ContactId;
oppContact.add(contRole);
system.debug('oppContact::'+oppContact);
}*/
            //insert oppContact;
        }
    }
    
    
    
    public static void oppContatsMapping(List<Contact> newContact,List<Contact> existingContacts,Id accountId,Id oppId){
        List<contact> newCont=new list<contact>();
        for(Contact cont:newContact){
            cont.AccountId=accountId;
            newCont.add(cont);
        }
        insert newCont;
        Map<Id,Contact> accContact=new Map<Id,Contact>([select id from contact where accountId=:accountId]);
        List<OpportunityContactRole> oppContactRole=[SELECT  Id,ContactId FROM OpportunityContactRole WHERE OpportunityId=:oppId];
        
        for(OpportunityContactRole oppCont:oppContactRole){
            if(accContact.containsKey(oppCont.ContactId)){
                accContact.remove(oppCont.ContactId);
            }
        }
        List<OpportunityContactRole> newOppContacts=new List<OpportunityContactRole>();
        for(Id accCon:accContact.keyset()){
            OpportunityContactRole oppCon=new OpportunityContactRole();
            oppCon.ContactId=accCon;
            oppCon.OpportunityId=oppId;
            newOppContacts.add(oppCon);
        }
        insert newOppContacts;
    }
    
    Public Static void tagOppportunityToParentId(Map<String,String> mapofParentOppIdByRenewalId){
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        
        // try{
        //     for(String parentId : mapofParentOppIdByRenewalId.keySet()){
        //         Opportunity opp = new Opportunity();
        //         opp.Id = parentId;
        //         opp.Renewal_Opportunity__c = mapofParentOppIdByRenewalId.get(parentId);
        //         oppListToUpdate.add(opp);
        //     }
            
            // if(!oppListToUpdate.isEmpty()){
            //     update oppListToUpdate;
            // }
        // }catch(Exception e){
        //     System.debug('The Error:'+e.getMessage() + 'The Error Line:'+ e.getLineNumber());
        // }
    }
    
    public static void autoSyncProductWithSubscription(Set<String> oppIdSet){
        system.debug('oppIdSet::'+oppIdSet);
        List<SBQQ__Subscription__c>  subscriptionListTobeUpdate = [select id,SBQQ__Product__c,opportunity__r.Deal_Organization_Type__c,SBQQ__ProductName__c from SBQQ__Subscription__c where opportunity__c in: oppIdSet];
        
        List<Product2> productList = [select id,name,ProductCode from product2];
        Map<String,String> mapofProdNameByProdId = New Map<String,String>();
        if(!productList.isEmpty()){
            for(Product2 prod : productList){
                mapofProdNameByProdId.put(prod.ProductCode,prod.Id);
            }
        }
        system.debug('mapofProdNameByProdId::'+mapofProdNameByProdId);
        system.debug('subscriptionListTobeUpdate::'+subscriptionListTobeUpdate);
        if(!subscriptionListTobeUpdate.isEmpty()){
            for(SBQQ__Subscription__c sub : subscriptionListTobeUpdate){
                system.debug('sub::'+sub);
                if(sub.opportunity__r.Deal_Organization_Type__c != sub.SBQQ__ProductName__c){
                    system.debug('Inside If condition');
                    system.debug('Id:::'+mapofProdNameByProdId.get(sub.opportunity__r.Deal_Organization_Type__c));
                    sub.SBQQ__Product__c = mapofProdNameByProdId.get(sub.opportunity__r.Deal_Organization_Type__c);
                    sub.Product_Type__c = sub.opportunity__r.Deal_Organization_Type__c;
                }
            }
            update subscriptionListTobeUpdate;
        }
    }
    
    // Code to implement
    
    public Static void getInociceContactBasedonInvoiceId(List<Id> InvoiceIdList){
        List<Invoice__c> invRecordList = [SELECT Id,Name,Opportunity__c FROM Invoice__c WHERE ID IN:InvoiceIdList];
        Set<Id> invIdSet = new Set<Id>();
        for(Invoice__c inv : invRecordList){
            invIdSet.add(inv.id);
        }
        List<Invoice_Contact__c> getinvContactList = [SELECT Id,Name,Invoice__c,Contact__c FROM Invoice_Contact__c WHERE Invoice__c IN: invIdSet AND Contact__c = null];
        System.debug('getinvContactList ::'+getinvContactList.size());
        //   Set<Id> invContRelatedContact = new Set<Id>();
        // for(Invoice_Contact__c invcon : getinvContactList){
        //  invContRelatedContact.add(invcon.Contact__c);
        // }
        
        //  List<Contact> invContRelatedContactList = [SELECT Id,Name,Email FROM Contact WHERE ID IN:invContRelatedContact];
        
    }
    
    
    public static void copyInvoiceContact(List<Invoice_Contact__c> invoiceContactList,Set<Id> invoiceIdSet){
        List<Invoice_Contact__c> incListTobeInsert = new List<Invoice_Contact__c>();
        for(Id invoiceId : invoiceIdSet){
            for(Invoice_Contact__c inc : invoiceContactList){
                Invoice_Contact__c newInc = new Invoice_Contact__c();
                newInc.Contact__c = inc.Contact__c;
                newInc.Invoice__c = invoiceId;
                incListTobeInsert.add(newInc);
            }
        }
        
        if(!incListTobeInsert.isEmpty()){
            InvoiceContactTriggerHandler.blockContactInvoiceCreation = true;
            insert incListTobeInsert;
        }
    }
    
    Public Static void updateCnNumber(Map<Id,String> mapinvString){
        Set<String> invIdSet = new Set<String>();
        List<String> invString = new List<String>();
    }
    
    public static Account createAccount(String name){
        Account acc = new Account();
        acc.Name = name;
        insert acc;
        return acc;
    }
    
    public Static Contact createContact(String lastname, String email,String accountId){
        Contact con = new Contact();
        con.lastname = lastname;
        con.Email = email;
        con.OwnerId = UserInfo.getUserId();
        con.AccountId = accountId;
        insert con;
        return con;
    }
    
    public Static Invoice__c createInvoice(String invstatus, date Invduedate, Decimal invAmount, String oppId){
        Invoice__c inv = new Invoice__c();
        inv.Invoice_Status__c = invstatus;
        inv.Invoice_Date__c = Invduedate;
        inv.Amount__c = invAmount;
        inv.Opportunity__c = oppId;
        insert inv;
        return inv;
    }
    
    public Static Opportunity createOpportunity(String name, String Leadsource, Date Closedate,String stagename, String accountId){
        Opportunity opp = new Opportunity();
        opp.Name = name;
        opp.LeadSource = Leadsource;
        opp.CloseDate = Closedate;
        opp.StageName = stagename;
        opp.AccountId = accountId;
        insert opp;
        return opp;
    }
    
}