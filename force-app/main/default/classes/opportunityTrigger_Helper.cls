public without sharing class opportunityTrigger_Helper {
    public static boolean beforeInsert = true;
    public static boolean afterInsert = true;
    public static boolean beforeUpdate = true;
    public static boolean afterUpdate = true;
    public static boolean isProductValueChange = false;
    
    
    public static void mapOpportunityWithPricebook(list<opportunity> newOpportunityList){
        for(opportunity opp : newOpportunityList){
            opp.Pricebook2Id = '01s5j000006twrLAAQ';
            opp.No_of_Invoices__c = 1;
        }
    }
    
    public static void assignedSubscriptionEndDate(list<opportunity> newOpportunityList){
        if(!newOpportunityList.isEmpty()){
            for(Opportunity oppDetails : newOpportunityList){
                if(oppDetails.Subscription_Start_Date__c != null && oppDetails.Contract_Length__c != null){
                    if(oppDetails.create_trial__c && oppDetails.Trial_Period_In_Month__c != null){
                        integer totalPeriod = Integer.valueOf(String.valueOf(oppDetails.Contract_Length__c)) + integer.valueOf(String.valueOf(oppDetails.Trial_Period_In_Month__c));
                        if(oppDetails.Add_Additional_Period__c && oppDetails.Additiona_Period_Date__c != null){
                            oppDetails.Subscription_End_Date__c = oppDetails.Additiona_Period_Date__c;
                        }else if(oppDetails.Promo_Free_Period__c && oppDetails.Promo_Free_Period_End_Date__c != null){
                            //Update 2023-03-15 by Iceberg RevOps: set end date from opp's Promo Free Period End Date
                            oppDetails.Subscription_End_Date__c = oppDetails.Promo_Free_Period_End_Date__c;
                        }else{
                            oppDetails.Subscription_End_Date__c = oppDetails.Subscription_Start_Date__c.addMonths(Integer.valueOf(String.valueOf(oppDetails.Contract_Length__c)) + integer.valueOf(String.valueOf(oppDetails.Trial_Period_In_Month__c))) - 1;
                        }
                    }else if(oppDetails.Create_Pilot__c && oppDetails.Pilot_Period__c != null){
                        oppDetails.Subscription_End_Date__c = oppDetails.Subscription_Start_Date__c.addMonths(Integer.valueOf(String.valueOf(oppDetails.Pilot_Period__c))) - 1;
                    }else{
                        if(oppDetails.Add_Additional_Period__c && oppDetails.Additiona_Period_Date__c != null){
                            oppDetails.Subscription_End_Date__c = oppDetails.Additiona_Period_Date__c;
                        }else if(oppDetails.Promo_Free_Period__c && oppDetails.Promo_Free_Period_End_Date__c != null){
                            //Update 2023-03-15 by Iceberg RevOps: set end date from opp's Promo Free Period End Date
                            oppDetails.Subscription_End_Date__c = oppDetails.Promo_Free_Period_End_Date__c;
                        }else{
                            oppDetails.Subscription_End_Date__c = oppDetails.Subscription_Start_Date__c.addMonths(Integer.valueOf(String.valueOf(oppDetails.Contract_Length__c))) - 1;
                        }
                        
                    }
                }
            }
        }
    }
    
    public static void updatePilotPeriodOnContractLenght(List<Opportunity> newOpportunity,map<id,Opportunity> mapOfOldOppDet){
        if(!newOpportunity.isEmpty()){
            for(Opportunity opp : newOpportunity){
                if(opp.Pilot_Period__c != null && opp.Create_Pilot__c && opp.Create_Pilot__c != mapOfOldOppDet.get(opp.Id).Create_Pilot__c){
                    opp.Contract_Length__c = Decimal.valueOf(String.valueOf(opp.Pilot_Period__c));
                    opp.Type = 'Pilot Bussiness';
                }
            }
        }
    }
    
    public static void handleRenewalOpportunityAndProduct(list<opportunity> renewalOpportunityList){
        if(!renewalOpportunityList.isEmpty()){
            system.debug('renewalOpportunityList'+renewalOpportunityList);
            list<opportunity> parentOpportunityList = new list<opportunity>();
            list<Contract> contractIdList = new list<Contract>();
            set<string> parentOpportunity = new set<string>();
            set<string> contractIdSet = new set<string>();
            map<string,string> mapofRenewContidByOldOppId = new map<string,string>();
            map<string,opportunity> mapofOldOppIdByopp = new map<string,opportunity>();
            Id devRecordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
            for(opportunity oppDetail : renewalOpportunityList){
                if(oppDetail.SBQQ__Renewal__c){
                    
                    contractIdSet.add(oppDetail.SBQQ__RenewedContract__c);
                }
            }
            if(!contractIdSet.isEmpty()){
                contractIdList = [select id,SBQQ__Opportunity__c from Contract where id in: contractIdSet];
                if(!contractIdList.isEmpty()){
                    for(Contract cont : contractIdList){
                        parentOpportunity.add(cont.SBQQ__Opportunity__c);
                        mapofRenewContidByOldOppId.put(cont.Id,cont.SBQQ__Opportunity__c);
                    }
                }
            }
            if(!parentOpportunity.isEmpty()){
                parentOpportunityList = [select Department_Count__c,Budget__c,Need__c,Authority__c,name,Contract_Terms__c,id,Onboarding_Complete__c,LMS_Activation__c,
                                         Contact_Verify_Status__c,Teacher_Rostering_Status__c,LMS_Account_Info__c,
                                         Parent_Opportunity__c,Standards_Name__c,Standards_Required__c,Account.customer_success__c,
                                         LMS__c,Onboarding_Notes__c,PO_Required__c,Form_Org_ID__c,Product_Org_ID__c,AccountId,Contract_Length__c,
                                         Subscription_End_Date__c,Subscription_Start_Date__c,Deal_Confirmed_Enrollment__c,Deal_Organization_Type__c,
                                         Create_Trial__c,Trial_Period_In_Month__c,Amount 
                                         from Opportunity 
                                         where id in: parentOpportunity];
                if(!parentOpportunityList.isEmpty()){
                    for(opportunity opp : parentOpportunityList){
                        mapofOldOppIdByopp.put(opp.Id,opp);
                    }
                }
                
                for(opportunity oppDetail : renewalOpportunityList){
                    oppDetail.Budget__c                         = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Budget__c;
                    oppDetail.Need__c                           = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Need__c;
                    oppDetail.Authority__c                      = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Authority__c;
                    oppDetail.Previous_Deal_Contract_Length__c  = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Contract_Length__c;
                    oppDetail.Previous_Deal_End_Date__c         = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Subscription_End_Date__c;
                    oppDetail.Previous_Deal_Enrollment__c       = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Deal_Confirmed_Enrollment__c;
                    oppDetail.Previous_Deal_Start_Date__c       = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Subscription_Start_Date__c;
                    oppDetail.Previous_Deal_Value__c            = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Amount;
                    oppDetail.Parent_Opportunity__c             = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Id;
                    oppDetail.Previous_PO_Required__c           = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).PO_Required__c;
                    oppDetail.Deal_Organization_Type__c         = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Deal_Organization_Type__c;
                    oppDetail.Deal_Confirmed_Enrollment__c      = oppDetail.Previous_Deal_Enrollment__c;
                    oppDetail.Product_Org_ID__c                 = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Product_Org_ID__c;
                    oppDetail.Form_Org_ID__c                    = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Form_Org_ID__c;
                    oppDetail.Onboarding_Notes__c               = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Onboarding_Notes__c;
                    oppDetail.LMS__c                            = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).LMS__c;
                    oppDetail.Standards_Required__c             = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Standards_Required__c;
                    oppDetail.Standards_Name__c                 = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Standards_Name__c;
                    oppDetail.Subscription_Start_Date__c        = oppDetail.Previous_Deal_End_Date__c.addDays(1);
                    oppDetail.OwnerId                           = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Account.customer_success__c;
                    oppDetail.RecordtypeId                      = devRecordTypeId;
                    oppDetail.CloseDate							= oppDetail.Subscription_Start_Date__c;
                    if(oppDetail.Deal_Organization_Type__c == 'Multi-school'){
                        oppDetail.Multi_Scholl_Created__c           = true;
                    }
                    if(oppDetail.Deal_Organization_Type__c == 'Department'){
                        oppDetail.Department_Count__c = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Department_Count__c;
                    }
                    if(mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Parent_Opportunity__c == null){
                        oppDetail.name = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Name+ '- Renewal-'+oppDetail.Subscription_Start_Date__c.year();
                        oppDetail.First_Renewal_Opportunity__c = true;
                        oppDetail.StageName                         = 'Onboarding';
                    }else{
                        oppDetail.First_Renewal_Opportunity__c = false;
                        oppDetail.StageName                         = 'LifeCycle Engagement';
                        oppDetail.Onboarding_Complete__c = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Onboarding_Complete__c;
                        oppDetail.LMS_Account_Info__c = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).LMS_Account_Info__c;
                        oppDetail.Teacher_Rostering_Status__c = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Teacher_Rostering_Status__c;
                        oppDetail.Contact_Verify_Status__c = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Contact_Verify_Status__c;
                        oppDetail.LMS_Activation__c = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).LMS_Activation__c;
                        if(mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Name.contains(String.valueOf(oppDetail.Subscription_Start_Date__c.year()- 1))){
                            oppDetail.name = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Name.replace(String.valueOf(oppDetail.Subscription_Start_Date__c.year()- 1),String.valueOf(oppDetail.Subscription_Start_Date__c.year()));
                        }else{
                            if(mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Name.contains('Renewal')){
                                oppDetail.name =mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Name.remove('Renewal');
                                oppDetail.name = oppDetail.name +  '- Renewal-'+oppDetail.Subscription_Start_Date__c.year();
                            }else{
                                oppDetail.name = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Name+ '- Renewal-'+oppDetail.Subscription_Start_Date__c.year();
                            }
                            
                        }
                        
                        
                    }
                    oppDetail.Contract_Terms__c = mapofOldOppIdByopp.get(mapofRenewContidByOldOppId.get(oppDetail.SBQQ__RenewedContract__c)).Contract_Terms__c;
                    oppDetail.Contract_Length__c = 12;
                }
            }
            
        }
    }
    
    public static void tagDeafultORGType(List<Opportunity> oppList){
        Set<Id> accIdSet = new Set<Id>();
        for(Opportunity opp : oppList){
            if(opp.AccountId != null){
                accIdSet.add(opp.AccountId);
            }
        }
        
        if(!accIdSet.isEmpty()){
            List<Account> accList = [select id,Recordtype.Developername from Account where id in: accIdSet];
            Map<Id,String> mapOfAccIdByRecTypeId = new Map<Id,String>();
            if(!accList.isEmpty()){
                for(Account acc : accList){
                    mapOfAccIdByRecTypeId.put(acc.Id,acc.Recordtype.Developername);
                }
            }
            
            for(Opportunity opp : oppList){
                if(mapOfAccIdByRecTypeId.get(opp.AccountId) == 'School' && opp.Deal_Organization_Type__c == null){
                    opp.Deal_Organization_Type__c = 'School';
                }else if(mapOfAccIdByRecTypeId.get(opp.AccountId) == 'District' && opp.Deal_Organization_Type__c == null){
                    opp.Deal_Organization_Type__c = 'District';
                }
                
            }
        }
    }
    
    public static void createOpportunityProduct(list<opportunity> newOpportunity,map<Id,Opportunity> mapofOldOpportunityDet){
        if(!newOpportunity.isEmpty()){
            Integer subscriptionPeriod = 0;
            Integer subscriptionYear = 0;
            boolean isPilotOportunity = false;
            list<OpportunityLineItem> oppProductTobeInsert = new list<OpportunityLineItem>();
            list<string> oppPaidProductCode = new list<string>();
            list<string> oppTrialProductCode = new list<string>();
            set<String> parentMultiOppDet = new set<String>();
            list<product2> productList = new list<product2>();
            map<string,list<string>> mapofProdCodeByOppId = new map<string,list<string>>();
            map<string,list<string>> mapofPaidProdCodeByOppId = new map<string,list<string>>();
            map<string,opportunity> maoofOppidByOpp = new map<string,opportunity>();
            
            for(opportunity opp : newOpportunity){
                maoofOppidByOpp.put(opp.Id,opp);
                System.debug('opp.Department_Count__c: ' + opp.Department_Count__c);
                if(mapofOldOpportunityDet == null && opp.SBQQ__Renewal__c == false){
                    calculateQuotation(opp.Id,0);
                }else if(!opp.Multi_School_opportunity__c && mapofOldOpportunityDet != null && opp.Deal_Organization_Type__c != null && opp.Deal_Organization_Type__c != ''&& opp.Deal_Organization_Type__c != mapofOldOpportunityDet.get(opp.Id).Deal_Organization_Type__c
                         ||(!opp.Multi_School_opportunity__c && mapofOldOpportunityDet != null && opp.Deal_Confirmed_Enrollment__c != mapofOldOpportunityDet.get(opp.Id).Deal_Confirmed_Enrollment__c ||
                            !opp.Multi_School_opportunity__c && mapofOldOpportunityDet!= null && opp.Contract_Length__c != null && opp.Contract_Length__c != mapofOldOpportunityDet.get(opp.Id).Contract_Length__c)){
                                calculateQuotation(opp.Id,0);
                                Break;
                            }else if(opp.Create_Pilot__c && opp.Create_Pilot__c != mapofOldOpportunityDet.get(opp.Id).Create_Pilot__c){
                                calculateQuotation(opp.Id,0);
                            }else if(opp.Create_Trial__c && opp.Create_Trial__c != mapofOldOpportunityDet.get(opp.Id).Create_Trial__c){
                                calculateQuotation(opp.Id,0);
                            }else {
                                if (mapofOldOpportunityDet != null) {
                                    if(opp.Department_Count__c != null && opp.Department_Count__c != mapofOldOpportunityDet.get(opp.Id).Department_Count__c){
                                        calculateQuotation(opp.Id,0);
                                    }
                                }
                            }
            }
        }
    }
    
    public static void tagDocumentAttachmentToRenewal(list<Opportunity> newOpportunityList){
        system.debug('tag:::'+newOpportunityList);
        if(!newOpportunityList.isEmpty()){
            map<String,String> mapofReoppIdbyParentId = new map<String,String>();
            list<ContentDocumentLink> conDocListTobeInsert = new list<ContentDocumentLink>();
            set<String> parentOppIdSet = new set<String>();
            for(Opportunity oppDet : newOpportunityList){
                system.debug('oppDet SBQQ__Renewal__c:::'+oppDet.SBQQ__Renewal__c);
                if(oppDet.SBQQ__Renewal__c){
                    if(oppDet.Parent_Opportunity__c != null){
                        mapofReoppIdbyParentId.put(oppDet.Parent_Opportunity__c,oppDet.Id);
                        parentOppIdSet.add(oppDet.Parent_Opportunity__c);
                    }
                    
                }
            }
            system.debug('parentOppIdSet::'+parentOppIdSet);
            if(!parentOppIdSet.isEmpty()){
                list<ContentDocumentLink > contentDocIdList = [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in: parentOppIdSet];
                system.debug('contentDocIdList::'+contentDocIdList);
                if(!contentDocIdList.isEmpty()){
                    for(ContentDocumentLink conDocLink : contentDocIdList){
                        ContentDocumentLink cdl = new ContentDocumentLink();
                        cdl.ContentDocumentId = conDocLink.ContentDocumentId;
                        cdl.LinkedEntityId = mapofReoppIdbyParentId.get(conDocLink.LinkedEntityId);
                        cdl.ShareType = 'V';
                        conDocListTobeInsert.add(cdl);
                    }
                }
                system.debug('conDocListTobeInsert::'+conDocListTobeInsert);
                if(!conDocListTobeInsert.isEmpty()){
                    INSERT conDocListTobeInsert;
                }
            }
        }
    }
    
    public static void createChildMultiSchoolOppProduct(list<opportunity> newOpportunity,map<Id,Opportunity> mapofOldOpportunityDet){
        if(!newOpportunity.isEmpty()){
            set<String> parentMultiIdSet = new set<String>();
            list<Opportunity> parentOppList = new list<Opportunity>();
            list<OpportunityLineItem> oppLineItemTobeCreate = new list<OpportunityLineItem>();
            list<Product2> childOppProductList = new list<Product2>();
            set<string> opportunityProductId = new set<String>();
            for(Opportunity opp : newOpportunity){
                if(opp.Multi_School_opportunity__c){
                    parentMultiIdSet.add(opp.Master_Opportunity__c);
                    opportunityProductId.add(opp.Deal_Organization_Type__c);
                }
                
            }
            system.debug('parentMultiIdSet::'+parentMultiIdSet);
            if(!parentMultiIdSet.isEmpty()){
                childOppProductList = [select id,ProductCode from Product2 where ProductCode in: opportunityProductId limit 1];
                parentOppList = [select id,Subscription_Start_Date__c,Contract_Length__c,Slab_Prize__c,Amount,Deal_Confirmed_Enrollment__c from Opportunity where id in: parentMultiIdSet];
                system.debug('parentOppList::'+parentOppList);
                if(!parentOppList.isEmpty()){
                    for(Opportunity opp : newOpportunity){
                        if(opp.Multi_School_W_O_Enrollment__c){
                            OpportunityLineItem oppLine = new OpportunityLineItem();
                            oppLine.UnitPrice = 0;
                            oppLine.Slab_Price__c = 0;
                            oppLine.Subscription_Start_Date__c = parentOppList[0].Subscription_Start_Date__c;
                            oppLine.Subscription_End_Date__c = oppLine.Subscription_Start_Date__c.addMonths(integer.valueOf(String.valueOf(parentOppList[0].Contract_Length__c))) - 1;
                            oppLine.quantity = 1;
                            oppLine.OpportunityId = opp.Id;
                            oppLine.Product2Id = childOppProductList[0].Id;
                            oppLineItemTobeCreate.add(oppLine);
                        }else{
                            OpportunityLineItem oppLine = new OpportunityLineItem();
                            system.debug('parentOppList[0].Amount::'+parentOppList[0].Amount);
                            system.debug('parentOppList[0].Deal_Confirmed_Enrollment__c::'+parentOppList[0].Deal_Confirmed_Enrollment__c);
                            oppLine.UnitPrice = parentOppList[0].Amount/parentOppList[0].Deal_Confirmed_Enrollment__c;
                            oppLine.Slab_Price__c = oppLine.UnitPrice * 12 /parentOppList[0].Contract_Length__c;
                            oppLine.Subscription_Start_Date__c = parentOppList[0].Subscription_Start_Date__c;
                            oppLine.Subscription_End_Date__c = oppLine.Subscription_Start_Date__c.addMonths(integer.valueOf(String.valueOf(parentOppList[0].Contract_Length__c))) - 1;
                            oppLine.quantity = opp.Deal_Confirmed_Enrollment__c;
                            oppLine.OpportunityId = opp.Id;
                            oppLine.Product2Id = childOppProductList[0].Id;
                            oppLineItemTobeCreate.add(oppLine);
                        }
                        
                    }
                    
                    system.debug('oppLineItemTobeCreate::'+oppLineItemTobeCreate);
                    insert oppLineItemTobeCreate;
                }
            }
            
            
        }
    }
    
    public static void mapAttchmentAndRolesForPilotWon(list<Opportunity> newOpportunity){
        set<Id> parentPilotId = new set<Id>(); 
        for(Opportunity opp : newOpportunity){
            if(opp.Pilot_Parent__c != null){
                parentPilotId.add(opp.Id);
            }
        }
        if(!parentPilotId.isEmpty()){
            Utility.PilotOpportunityContactRoles(parentPilotId);
        }
        
    }
    
    public static void createContactRole(list<Opportunity> newOpportunity){
        set<Id> oppId = new set<Id>();
        for(Opportunity opp : newOpportunity){
            if(opp.Parent_Opportunity__c == null && opp.Pilot_Parent__c == null){
                oppId.add(opp.Id);
            }
        }
        
        if(!oppId.isEmpty()){
            utility.addContactRoles(oppId);
        }
    }
    
    public static void validateMultischoolClosedWonOpportunity(list<Opportunity> newOpportunity,map<Id,Opportunity> mapofOldOpportunityDet){
        Set<Id> oppIdSet = new Set<Id>();
        for(Opportunity opp : newOpportunity){
            if(opp.Deal_Organization_Type__c == 'Multi-school' && (opp.Stagename == 'Closed Won' || opp.StageName == 'Closed/Won')){
                oppIdSet.add(opp.Id);
            }
        }
        
        if(!oppIdSet.isEmpty()){
            List<Opportunity> childMulOpp = [select id from opportunity where Master_Opportunity__c in: oppIdSet];
            
            if(childMulOpp.size() < 2){
                newOpportunity[0].StageName.addError('Please select atleast 2 schools to close the opportunity.');
            }
        }
    }
    
    public static void opportunityClosedWonActivity(list<Opportunity> newOpportunityList,map<Id,Opportunity> mapofOldOpportunityDet){
        try{
            Map<Id,Id> mapOfOppIdbyCSID = new Map<Id,Id>();
            for(Opportunity opp : newOpportunityList){
                if(opp.StageName != null && (opp.StageName == Constant.NEW_BUSSINESS_CLOSEDSTAGE || opp.StageName == Constant.EXISTING_BUSSINESS_CLOSEDSTAGE)
                   && opp.StageName != mapofOldOpportunityDet.get(opp.Id).StageName){
                       opp.CloseDate = System.today();
                       opp.Probability = 100;
                       opp.Mark_Closed_Won__c = true;
                       //Updated by Iceberg RevOps on 2023-02-10: CS Owner assignment is now handled by a flow
                       /*if(opp.Customer_Success_Member_id__c != null){
                           opp.CSOwner__c = opp.Customer_Success_Member_id__c;
                       }*/
                       if(opp.Parent_Opportunity__c == null){
                           opp.Customer_Success_Stage__c = Constant.CUSTOMER_SUCCESS_STAGE;
                       }
                   }
            }
        }catch(Exception e){
            system.debug('Exception::'+e.getStackTraceString());
        }
    }
    
    public static void tagTrialProduct(list<opportunity> newOpportunity,map<id,opportunity> oldOpportuityDetails){
        if(!newOpportunity.isEmpty()){
            list<OpportunityLineItem> oppProductTobeInsert = new list<OpportunityLineItem>();
            list<OpportunityLineItem> existingOpportunityProduct = new list<OpportunityLineItem>();
            list<string> oppTrialProductCode = new list<string>();
            map<string,string> mapofProdCodeByOppId = new map<string,string>();
            map<string,opportunity> maoofOppidByOpp = new map<string,opportunity>();
            set<string> oppIdSet = new set<string>();
            for(opportunity oppDetails : newOpportunity){
                maoofOppidByOpp.put(oppDetails.id,oppDetails);
                oppIdSet.add(oppDetails.id);
                if(oppDetails.create_trial__c && oppDetails.create_trial__c != oldOpportuityDetails.get(oppDetails.Id).create_trial__c){
                    oppTrialProductCode.add(oppDetails.Deal_Organization_Type__c+'Trial');
                    mapofProdCodeByOppId.put(oppDetails.Deal_Organization_Type__c+'Trial',oppDetails.Id);
                }
            }
            
            if(!oppIdSet.isEmpty()){
                existingOpportunityProduct = [select id,UnitPrice,Subscription_Start_Date__c,Subscription_End_Date__c,Quantity,opportunityId,Product2Id from OpportunityLineItem where opportunityId in: oppIdSet];
            }
            
            if(existingOpportunityProduct.size() <2){
                if(!oppTrialProductCode.isEmpty()){
                    list<Product2> trialProductList = [select id,ProductCode from Product2 where ProductCode in: oppTrialProductCode];
                    for(Product2 prodDetail :  trialProductList){
                        OpportunityLineItem oppLineItem = new OpportunityLineItem();
                        oppLineItem.OpportunityId = mapofProdCodeByOppId.get(prodDetail.ProductCode);
                        oppLineItem.Product2Id = prodDetail.Id;
                        oppLineItem.UnitPrice = 0;
                        if(maoofOppidByOpp.get(mapofProdCodeByOppId.get(prodDetail.ProductCode)).Deal_Organization_Type__c == '	Department'){
                            oppLineItem.Quantity = 1;
                        }else{
                            oppLineItem.Quantity = maoofOppidByOpp.get(mapofProdCodeByOppId.get(prodDetail.ProductCode)).Deal_Confirmed_Enrollment__c;
                        }
                        
                        oppLineItem.Subscription_Start_Date__c  =maoofOppidByOpp.get(mapofProdCodeByOppId.get(prodDetail.ProductCode)).Subscription_Start_Date__c;
                        oppLineItem.Subscription_End_Date__c = oppLineItem.Subscription_Start_Date__c.addMonths(integer.valueOf(string.valueOf(maoofOppidByOpp.get(mapofProdCodeByOppId.get(prodDetail.ProductCode)).Trial_Period_In_Month__c))) - 1;
                        oppProductTobeInsert.add(oppLineItem);
                    }
                    
                    if(!existingOpportunityProduct.isEmpty()){
                        for(OpportunityLineItem oppLineItem : existingOpportunityProduct){
                            oppLineItem.Subscription_Start_Date__c = maoofOppidByOpp.get(oppLineItem.opportunityId).Subscription_Start_Date__c.addMonths(Integer.valueOf(String.valueOf(maoofOppidByOpp.get(oppLineItem.opportunityId).Trial_Period_In_Month__c)));
                            oppLineItem.Subscription_End_Date__c = oppLineItem.Subscription_Start_Date__c.addMonths(Integer.valueOf(String.valueOf(maoofOppidByOpp.get(oppLineItem.opportunityId).Contract_Length__c))) - 1;
                            oppProductTobeInsert.add(oppLineItem);
                        }
                    }
                    
                    if(!oppProductTobeInsert.isEmpty()){
                        upsert oppProductTobeInsert;
                    }
                }
            }
        }
    }
    
    public static void completeVerifyClosedWonTask(list<opportunity> opportunityList,map<id,opportunity> oldOppDetails){
        if(!opportunityList.isEmpty()){
            set<string> opportunityIdSet = new set<string>();
            for(opportunity oppDetails : opportunityList){
                if(oppDetails.stageName == 'Closed Won' && oppDetails.stageName != oldOppDetails.get(oppDetails.Id).stageName){
                    opportunityIdSet.add(oppDetails.Id);
                }
                
            }
            if(!opportunityIdSet.isEmpty()){
                list<task> taskList = [select id,status from task where subject = 'Verify & Mark Closed Won' AND WhatId IN :opportunityIdSet AND Status != 'Completed'];
                for(task ts : taskList){
                    ts.status = 'Completed';
                }
                
                update taskList;
            }
        }
    }
    
    public static void createOpportunityFromPilotOpportunity(list<opportunity> newOppList,map<id,Opportunity> oldMapOpp){
        if(!newOppList.isEmpty()){
            list<opportunity> opportunityTobeInsert = new list<opportunity>();
            list<string> oppIdList = new list<string>();
            for(opportunity oppDetail : newOppList){
                if(oppDetail.Create_Pilot__c && oppDetail.StageName != oldMapOpp.get(oppDetail.Id).StageName && oppDetail.StageName == 'Closed Won'){
                    oppIdList.add(oppDetail.Id);
                }
            }
            
            if(!oppIdList.isEmpty()){
                mapPilotDetailsToOpp(oppIdList);
            }
            
        }
    }
    
    public static void createAdminContact(list<Opportunity> newOppList,map<Id,Opportunity> oldMapOpportunity){
        for(Opportunity opp : newOppList){
            if(opp.Billing_Accounts_Receivable_Email_Addres__c != null && opp.Billing_Accounts_Receivable_Email_Addres__c != oldMapOpportunity.get(opp.Id).Billing_Accounts_Receivable_Email_Addres__c){
                utility.CreateBillingContact(opp.Billing_Accounts_Receivable_Email_Addres__c,opp.AccountId);
            }
            if(opp.IT_Contact__c != null && opp.IT_Contact__c != oldMapOpportunity.get(opp.id).IT_Contact__c){
                utility.CreateItContact(opp.IT_Contact__c,opp.AccountId);
            }
            if(opp.Admin_User_Email_Address__c != null && opp.Admin_User_Email_Address__c !=oldMapOpportunity.get(opp.id).Admin_User_Email_Address__c){
                utility.CreateAdminContact(opp.Admin_User_Email_Address__c,opp.AccountId);
            }
        }
    }
    
    public static void postOnboardingActivity(list<Opportunity> newOpportunity,map<Id,Opportunity> oldMapOpp){
        list<OpportunityContactRole> oppConRole = new list<OpportunityContactRole>();
        list<contract> conList = new list<contract>();
        string renewalOpp = '';
        for(Opportunity opp : newOpportunity){
            if(opp.Customer_Success_Stage__c != null && opp.Customer_Success_Stage__c == 'Onboarding Complete' && opp.Customer_Success_Stage__c != oldMapOpp.get(opp.id).Customer_Success_Stage__c){
                oppConRole = [select Role,ContactId,OpportunityId from OpportunityContactRole where opportunityId =: opp.Id];
                conList = [select id,SBQQ__RenewalOpportunity__c from contract where SBQQ__Opportunity__c =: opp.Id];
            }
            
        }
        if(!conList.isEmpty()){
            renewalOpp = conList[0].SBQQ__RenewalOpportunity__c;
        }
        for(Opportunity opp : newOpportunity){
            if(renewalOpp != '' && opp.Customer_Success_Stage__c != null && opp.Customer_Success_Stage__c == 'Onboarding Complete' && opp.Customer_Success_Stage__c != oldMapOpp.get(opp.id).Customer_Success_Stage__c){
                utility.oppContactMapping(opp.Confirmed_Eligible_Teachers__c,renewalOpp,opp.IT_Contact__c,opp.Admin_User_Email_Address__c,opp.Billing_Accounts_Receivable_Email_Addres__c,opp.LMS__c,opp.LMS_Account_Info__c,oppConRole,opp.Contact_Verify_Status__c,opp.Teacher_Rostering_Status__c,opp.LMS_Activation__c,opp.Customer_Success_Stage__c);
            }
        }
    }
    
    public static void autoSyncProductToSub(List<Opportunity> newOppList,Map<Id,Opportunity> mapofOldOpportunity){
        Set<String> oppIdToSync = new Set<String>();
        for(Opportunity opp : newOppList){
            if(mapofOldOpportunity.get(opp.Id).Deal_Organization_Type__c != null && opp.Deal_Organization_Type__c != mapofOldOpportunity.get(opp.Id).Deal_Organization_Type__c){
                oppIdToSync.add(opp.Id);
            }
        }
        if(!oppIdToSync.isEmpty()){
            Utility.autoSyncProductWithSubscription(oppIdToSync);
        }
    }
    
    public static void updateContractWithPrimaryQuote(List<Opportunity> oppList,Map<Id,Opportunity> oppOldMap){
        Set<Id> oppIdSet = new Set<Id>();
        for(Opportunity opp : oppList){
            if(opp.SBQQ__PrimaryQuote__c != null && opp.SBQQ__PrimaryQuote__c != oppOldMap.get(opp.Id).SBQQ__PrimaryQuote__c){
                oppIdSet.add(opp.Id);
            }
        }
        
        if(!oppIdSet.isEmpty()){
            List<product2> productList = new List<product2>();
            productList = [select id,ProductCode from product2];
            Map<String,Id> mapofProdCodeByProdId = new Map<String,Id>();
            for(product2 prod : productList){
                mapofProdCodeByProdId.put(prod.ProductCode,prod.id); 
            }
            
            List<Contract> contractList = new List<Contract>();
            Set<Id> contractIdSet = new Set<Id>();
            contractList = [select id,SBQQ__Opportunity__c,SBQQ__Opportunity__r.SBQQ__PrimaryQuote__c from Contract where SBQQ__Opportunity__c in: oppIdSet];
            
            if(!contractList.isEmpty()){
                for(Contract con : contractList){
                    con.SBQQ__Quote__c = con.SBQQ__Opportunity__r.SBQQ__PrimaryQuote__c;
                    contractIdSet.add(con.Id);
                }
                
                if(!contractIdSet.isEmpty()){
                    List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
                    subList = [select id,SBQQ__Product__c,SBQQ__Contract__c,SBQQ__Contract__r.SBQQ__Opportunity__r.Deal_Organization_Type__c from SBQQ__Subscription__c where SBQQ__Contract__c in: contractIdSet];
                    if(!subList.isEmpty()){
                        for(SBQQ__Subscription__c sub : subList){
                            sub.SBQQ__Product__c = mapofProdCodeByProdId.get(sub.SBQQ__Contract__r.SBQQ__Opportunity__r.Deal_Organization_Type__c);
                        }
                        update subList;
                    }
                }
                update contractList;
            }
        }
    }
    
    public static void mapPilotDetailsToOpp(list<string> oppIdList){
        list<opportunity> oppList = [select id,Timing__c,LMS__c,CloseDate,StageName,AccountId,Name,Deal_Organization_Type__c,Deal_Confirmed_Enrollment__c,Subscription_Start_Date__c,Subscription_End_Date__c,Contract_Length__c from opportunity where id in: oppIdList];
        list<opportunity> opportunityTobeInsert = new list<opportunity>();
        if(!oppList.isEmpty()){
            for(opportunity oppDetail : oppList){
                opportunity oppDet = new opportunity();
                oppDet.AccountId = oppDetail.AccountId;
                oppDet.Name = oppDetail.Name + '- Pilot Closed';
                oppDet.Deal_Organization_Type__c = oppDetail.Deal_Organization_Type__c;
                oppDet.Deal_Confirmed_Enrollment__c = oppDetail.Deal_Confirmed_Enrollment__c;
                oppDet.Subscription_Start_Date__c = oppDetail.Subscription_End_Date__c + 1;
                oppDet.Subscription_End_Date__c = oppDet.Subscription_Start_Date__c.addMonths(12) - 1;
                oppDet.Contract_Length__c = 12;
                oppDet.CloseDate = oppDet.Subscription_Start_Date__c + 15;
                oppDet.StageName = 'Engaging';
                oppDet.Pilot_Parent__c = oppDetail.Id;
                oppDet.Timing__c = oppDetail.Timing__c;
                oppDet.LMS__c = oppDetail.LMS__c;
                opportunityTobeInsert.add(oppDet);
            }
            if(!opportunityTobeInsert.isEmpty()){
                insert opportunityTobeInsert;
            }
        }
    }
    
    public static void tagChildRenewal(List<Opportunity> newOpportunityList){
        Set<String> parentOpportunity = new Set<String>();
        Map<String,Opportunity> mapofParentOppIdByRenId = new Map<String,Opportunity>();
        map<String,String> mapofParentOppIdByRenStage = New Map<String,String>();
        for(Opportunity oppDet : newOpportunityList){
            if(oppDet.Multi_Scholl_Created__c){
                parentOpportunity.add(oppDet.Parent_Opportunity__c);
                mapofParentOppIdByRenId.put(oppDet.Parent_Opportunity__c,oppDet);
                mapofParentOppIdByRenStage.put(oppDet.Parent_Opportunity__c,oppDet.StageName);
            }
        }
        
        if(!parentOpportunity.isEmpty()){
            createChildMultiSchoolOpportunity(parentOpportunity,mapofParentOppIdByRenId);
        }
    }
    
    public static void createChildMultiSchoolOpportunity(set<string> parentOpportunity,Map<String,Opportunity> mapofParentOppIdByRenId){
        List<Opportunity> childOppList = new list<Opportunity>();
        List<Opportunity> childMulOppListTobeInsert = new List<Opportunity>();
        childOppList = [select id,Deal_Confirmed_Enrollment__c,AccountId,Name,StageName,CloseDate,Deal_Organization_Type__c,Subscription_Start_Date__c,
                        Subscription_End_Date__c,Contract_Length__c,Create_Trial__c,Trial_Period_In_Month__c,Multi_School_opportunity__c,Master_Opportunity__c,Multi_School_W_O_Enrollment__c
                        from Opportunity 
                        where Master_Opportunity__c in: parentOpportunity];
        
        if(!childOppList.isEmpty()){
            for(Opportunity oppDet : childOppList){
                Opportunity childMulOpp = new Opportunity();
                childMulOpp.Deal_Confirmed_Enrollment__c = oppDet.Deal_Confirmed_Enrollment__c;
                childMulOpp.Name = oppDet.Name + '- Renewal';
                childMulOpp.StageName = mapofParentOppIdByRenId.get(oppDet.Master_Opportunity__c).Stagename;
                childMulOpp.RecordtypeId = mapofParentOppIdByRenId.get(oppDet.Master_Opportunity__c).RecordtypeId;
                childMulOpp.CloseDate = System.today();
                childMulOpp.Deal_Organization_Type__c = oppDet.Deal_Organization_Type__c;
                childMulOpp.Subscription_Start_Date__c = oppDet.Subscription_Start_Date__c;
                childMulOpp.Subscription_End_Date__c = oppDet.Subscription_End_Date__c;
                childMulOpp.Contract_Length__c = oppDet.Contract_Length__c;
                childMulOpp.Create_Trial__c = oppDet.Create_Trial__c;
                childMulOpp.Trial_Period_In_Month__c = oppDet.Trial_Period_In_Month__c;
                childMulOpp.Multi_School_opportunity__c = oppDet.Multi_School_opportunity__c;
                childMulOpp.Master_Opportunity__c = mapofParentOppIdByRenId.get(oppDet.Master_Opportunity__c).Id;
                childMulOpp.Multi_School_W_O_Enrollment__c = oppDet.Multi_School_W_O_Enrollment__c;
                childMulOpp.AccountId = oppDet.AccountId;
                childMulOpp.OwnerId = mapofParentOppIdByRenId.get(oppDet.Master_Opportunity__c).OwnerId;
                childMulOppListTobeInsert.add(childMulOpp);
            }
            if(!childMulOppListTobeInsert.isEmpty()){
                Insert childMulOppListTobeInsert;
            }
        }
        
        
    }
    
    @AuraEnabled
    public static Boolean calculateQuotation(String oppId,decimal newSlabPrice){
        try{
            if(oppId != ''){
                list<opportunity> oppList = [select id,Additiona_Period_Date__c,Add_Additional_Period__c,Promo_Free_Period__c,Promo_Free_Period_End_Date__c,Department_Count__c,Slab_Prize__c,Create_Pilot__c,AccountId,Contract_Length__c,Subscription_End_Date__c,Subscription_Start_Date__c,Deal_Confirmed_Enrollment__c,Deal_Organization_Type__c,Create_Trial__c,Trial_Period_In_Month__c from opportunity where id =: oppId];
                product2 product = new product2();
                integer subscriptionPeriod = 0;
                integer totalSubscriptionPeriod = 0;
                string productId = '';
                string quoteId = '';
                Date subscriptionDate;
                Date subScriptionEndDate;
                map<string,OpportunityLineItem> mapofOppIdByOppProd = new map<string,OpportunityLineItem>();
                list<OpportunityLineItem> oppProducts = new list<OpportunityLineItem>();
                if(oppList != null && !oppList.isEmpty()){
                    oppProducts = [select id,UnitPrice,Subscription_Start_Date__c,Subscription_End_Date__c,Quantity,opportunityId,Product2Id from OpportunityLineItem where opportunityId =: oppList[0].Id];
                    System.debug('1');
                    for(OpportunityLineItem oppLine : oppProducts){
                        mapofOppIdByOppProd.put(oppList[0].Id,oppLine);
                    }
                    if(oppList[0].Contract_Length__c != null && oppList[0].Contract_Length__c >=0 && oppList[0].Contract_Length__c <= 23){
                        subscriptionPeriod = 12;
                    }
                    else if(oppList[0].Contract_Length__c != null && oppList[0].Contract_Length__c >=24 && oppList[0].Contract_Length__c <= 35){
                        subscriptionPeriod = 24;
                    }
                    else if(oppList[0].Contract_Length__c != null && oppList[0].Contract_Length__c >35){
                        subscriptionPeriod = 36;
                    }
                    
                    if(oppList[0].Contract_Length__c != null){
                        if(oppList[0].Create_Trial__c){
                            totalSubscriptionPeriod = Integer.valueOf(String.valueOf(oppList[0].Trial_Period_In_Month__c)) + Integer.valueOf(String.valueOf(oppList[0].Contract_Length__c));
                        }
                        else{
                            totalSubscriptionPeriod = Integer.valueOf(oppList[0].Trial_Period_In_Month__c);
                        }
                    }
                    list<SBQQ__BlockPrice__c> prodBlockPriceList = [select id,SBQQ__LowerBound__c,SBQQ__UpperBound__c,SBQQ__Price__c,SBQQ__OriginalBlockPrice__r.SBQQ__Product__c,SBQQ__OriginalBlockPrice__r.SBQQ__Product__r.Quote_Line_Types__c,SBQQ__OriginalBlockPrice__r.SBQQ__Product__r.ProductCode from SBQQ__BlockPrice__c where SBQQ__OriginalBlockPrice__r.SBQQ__Product__r.ProductCode =: oppList[0].Deal_Organization_Type__c and SBQQ__OriginalBlockPrice__r.Pricing_Period__c =: subscriptionPeriod];
                    
                    if(oppList[0].Create_Trial__c){
                        string prodCode = oppList[0].Deal_Organization_Type__c+'Trial';
                        product = [select id from product2 where ProductCode =:prodCode limit 1];
                    }
                    else if(oppList[0].Create_Pilot__c){
                        string prodCode = oppList[0].Deal_Organization_Type__c+'Pilot';
                        product = [select id from product2 where ProductCode =:prodCode limit 1];
                    }
                    
                    if(oppList[0].Create_Trial__c && oppList[0].Trial_Period_In_Month__c > 0){
                        subscriptionDate = Date.newInstance( oppList[0].Subscription_Start_Date__c.Year(), oppList[0].Subscription_Start_Date__c.Month(), oppList[0].Subscription_Start_Date__c.Day());
                        
                        subscriptionDate = subscriptionDate.addMonths(Integer.valueOf(string.valueOf(oppList[0].Trial_Period_In_Month__c)));
                        subScriptionEndDate = subscriptionDate.addMonths(Integer.valueOf(string.valueOf(oppList[0].Contract_Length__c)));
                    }
                    else{
                        subScriptionEndDate = Date.newInstance( oppList[0].Subscription_Start_Date__c.Year(), oppList[0].Subscription_Start_Date__c.Month(), oppList[0].Subscription_Start_Date__c.Day());
                        subScriptionEndDate = subScriptionEndDate.addMonths(Integer.valueOf(string.valueOf(oppList[0].Contract_Length__c)));
                    }
                    
                    List<SBQQ__QuoteLine__c> quoteLinesTobeInsert = new List<SBQQ__QuoteLine__c>();
                    map<string,SBQQ__BlockPrice__c> mapofBlockIdByBlockPrice = new map<string,SBQQ__BlockPrice__c>();
                    string quoteLineTypes = '';
                    if(prodBlockPriceList != null && !prodBlockPriceList.isEmpty()){
                        for(SBQQ__BlockPrice__c blockPrice : prodBlockPriceList){
                            productId = blockPrice.SBQQ__OriginalBlockPrice__r.SBQQ__Product__c;//SBQQ__OriginalBlockPrice__r.SBQQ__Product__c
                            quoteLineTypes = blockPrice.SBQQ__OriginalBlockPrice__r.SBQQ__Product__r.Quote_Line_Types__c; //SBQQ__OriginalBlockPrice__r.SBQQ__Product__r.Quote_Line_Types__c
                            if(oppList[0].Deal_Confirmed_Enrollment__c >= blockPrice.SBQQ__LowerBound__c && oppList[0].Deal_Confirmed_Enrollment__c < blockPrice.SBQQ__UpperBound__c){
                                mapofBlockIdByBlockPrice.put(blockPrice.Id,blockPrice);
                            }
                        }
                    }
                    SBQQ__Quote__c quote = new SBQQ__Quote__c();
                    
                    quote.SBQQ__Opportunity2__c = oppList[0].Id;
                    quote.SBQQ__SubscriptionTerm__c = totalSubscriptionPeriod;
                    quote.SBQQ__Account__c = oppList[0].AccountId;
                    quote.SBQQ__Primary__c = true;
                    if(oppList[0].Create_Trial__c){
                        quote.SBQQ__StartDate__c = oppList[0].Subscription_Start_Date__c;//Subscription_End_Date__c
                        if(oppList[0].Add_Additional_Period__c && oppList[0].Additiona_Period_Date__c != null){
                            quote.SBQQ__EndDate__c = oppList[0].Additiona_Period_Date__c;
                        }else if(oppList[0].Promo_Free_Period__c && oppList[0].Promo_Free_Period_End_Date__c != null){
                            //Update 2023-03-15 by Iceberg RevOps: set quote end date from opp's Promo Free Period End Date
                            quote.SBQQ__EndDate__c = oppList[0].Promo_Free_Period_End_Date__c;
                        }
                        else{
                            quote.SBQQ__EndDate__c = oppList[0].Subscription_Start_Date__c.addMonths(Integer.valueOf(String.valueOf(oppList[0].Contract_Length__c + oppList[0].Trial_Period_In_Month__c))) - 1;
                        }
                    }else{
                        quote.SBQQ__StartDate__c = oppList[0].Subscription_Start_Date__c;
                        if(oppList[0].Add_Additional_Period__c && oppList[0].Additiona_Period_Date__c != null){
                            quote.SBQQ__EndDate__c= oppList[0].Additiona_Period_Date__c;
                        }else if(oppList[0].Promo_Free_Period__c && oppList[0].Promo_Free_Period_End_Date__c != null){
                            //Update 2023-03-15 by Iceberg RevOps: set quote end date from opp's Promo Free Period End Date
                            quote.SBQQ__EndDate__c = oppList[0].Promo_Free_Period_End_Date__c;
                        }else{
                            quote.SBQQ__EndDate__c= subScriptionEndDate - 1;
                        }
                        
                    }
                    
                    insert quote;
                    quoteId = quote.Id;
                    system.debug('quoteId::'+quoteId);
                    if(!mapofBlockIdByBlockPrice.isEmpty() && !oppList[0].Create_Pilot__c){
                        if(oppList[0].Deal_Organization_Type__c == 'Department'){
                            Utility.createDepartmentQuoteLineItem(oppList[0],quoteId,mapofBlockIdByBlockPrice,productId,newSlabPrice);
                        }else{
                            for(string key : mapofBlockIdByBlockPrice.keySet()){
                                System.debug('3');
                                SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                                quoteLine.SBQQ__Product__c = productId;
                                if(oppList[0].Deal_Organization_Type__c == 'Department'){
                                    quoteLine.SBQQ__Quantity__c = 1;
                                }else{
                                    quoteLine.SBQQ__Quantity__c = oppList[0].Deal_Confirmed_Enrollment__c;
                                }
                                
                                quoteLine.SBQQ__PricingMethod__c = quoteLineTypes;
                                quoteLine.SBQQ__ProductSubscriptionType__c = 'Renewable';
                                quoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                                quoteLine.SBQQ__DefaultSubscriptionTerm__c = totalSubscriptionPeriod;
                                quoteLine.SBQQ__SubscriptionType__c = 'Renewable';
                                system.debug('mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c::'+mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c);
                                system.debug('oppList[0].Deal_Confirmed_Enrollment__c * mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c::'+oppList[0].Deal_Confirmed_Enrollment__c * mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c);
                                system.debug('oppList[0].Slab_Prize__c::'+oppList[0].Slab_Prize__c);
                                if(oppList[0].Deal_Organization_Type__c == 'Department'){
                                    if(oppList[0].Deal_Confirmed_Enrollment__c <= 1500 && newSlabPrice != 0){
                                        System.debug('4');
                                        quoteLine.SBQQ__ListPrice__c = newSlabPrice;
                                        quoteLine.Slab_Price__c = newSlabPrice;
                                        quoteLine.Slab_Discount__c = ((mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c - newSlabPrice)/mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c)*100;
                                        if(quoteLine.Slab_Discount__c == 100){
                                            quoteLine.Slab_Discount__c = 0;
                                        }
                                        quoteLine.Actual_Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                    }else if(oppList[0].Deal_Confirmed_Enrollment__c <= 1500){
                                        quoteLine.SBQQ__ListPrice__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                        quoteLine.Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                        quoteLine.Slab_Discount__c = ((mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c - newSlabPrice)/mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c)*100;
                                        if(quoteLine.Slab_Discount__c == 100){
                                            quoteLine.Slab_Discount__c = 0;
                                        }
                                        quoteLine.Actual_Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                    }else if(oppList[0].Deal_Confirmed_Enrollment__c > 1500 && newSlabPrice != 0){
                                        quoteLine.SBQQ__ListPrice__c = newSlabPrice;
                                        quoteLine.Slab_Price__c = newSlabPrice;
                                        quoteLine.Slab_Discount__c = ((mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c - newSlabPrice)/mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c)*100;
                                        if(quoteLine.Slab_Discount__c == 100){
                                            quoteLine.Slab_Discount__c = 0;
                                        }
                                        quoteLine.Actual_Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                    }else if(oppList[0].Deal_Confirmed_Enrollment__c > 1500){
                                        quoteLine.SBQQ__ListPrice__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                        quoteLine.Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                        quoteLine.Slab_Discount__c = ((mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c - newSlabPrice)/mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c)*100;
                                        if(quoteLine.Slab_Discount__c == 100){
                                            quoteLine.Slab_Discount__c = 0;
                                        }
                                        quoteLine.Actual_Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                    }
                                }else if(newSlabPrice != 0){
                                    quoteLine.SBQQ__ListPrice__c = ((newSlabPrice * oppList[0].Contract_Length__c)/12) * 1;
                                    quoteLine.Slab_Price__c = newSlabPrice;
                                    quoteLine.Slab_Discount__c = ((mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c - newSlabPrice)/mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c)*100;
                                    if(quoteLine.Slab_Discount__c == 100){
                                        quoteLine.Slab_Discount__c = 0;
                                    }    
                                    quoteLine.Actual_Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                }else if(oppList[0].Deal_Organization_Type__c != 'Department'){
                                    quoteLine.SBQQ__ListPrice__c = ((mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c * oppList[0].Contract_Length__c)/12) * 1;
                                    quoteLine.Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                    oppList[0].Slab_Prize__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                    quoteLine.Slab_Discount__c = ((mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c - newSlabPrice)/mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c)*100;
                                    if(quoteLine.Slab_Discount__c == 100){
                                        quoteLine.Slab_Discount__c = 0;
                                    }    
                                    quoteLine.Actual_Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                }
                                quoteLine.SBQQ__Quote__c = quote.Id;
                                quoteLinesTobeInsert.add(quoteLine);
                            }
                        }
                        
                    }
                    
                    if(oppList[0].Create_Pilot__c){
                        system.debug('Inside Pilot product::');
                        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                        system.debug('product.Id::'+product.Id);
                        quoteLine.SBQQ__Product__c = product.Id;
                        if(oppList[0].Deal_Organization_Type__c == 'Department'){
                            quoteLine.SBQQ__Quantity__c = 1;
                        }else{
                            quoteLine.SBQQ__Quantity__c = oppList[0].Deal_Confirmed_Enrollment__c;
                        }
                        //quoteLine.SBQQ__Quantity__c = oppList[0].Deal_Confirmed_Enrollment__c;
                        quoteLine.SBQQ__PricingMethod__c = 'Custom';
                        quoteLine.SBQQ__ProductSubscriptionType__c = 'Renewable';
                        quoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                        quoteLine.SBQQ__SubscriptionType__c = 'Renewable';
                        quoteLine.SBQQ__DefaultSubscriptionTerm__c = totalSubscriptionPeriod;
                        quoteLine.SBQQ__ListPrice__c = 0;
                        quoteLine.Slab_Price__c = 0;
                        quoteLine.SBQQ__Quote__c = quoteId;
                        system.debug('quoteLine::'+quoteLine);
                        quoteLinesTobeInsert.add(quoteLine);
                    }
                    
                    if(oppList[0].Create_Trial__c){
                        System.debug('5');
                        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                        quoteLine.SBQQ__Product__c = product.Id;
                        if(oppList[0].Deal_Organization_Type__c == 'Department'){
                            quoteLine.SBQQ__Quantity__c = 1;
                        }else{
                            quoteLine.SBQQ__Quantity__c = oppList[0].Deal_Confirmed_Enrollment__c;
                        }
                        
                        quoteLine.SBQQ__PricingMethod__c = 'Custom';
                        quoteLine.SBQQ__ListPrice__c = 0;
                        quoteLine.Slab_Price__c = 0;
                        quoteLine.SBQQ__Quote__c = quoteId;
                        system.debug('quoteLine::'+quoteLine);
                        quoteLinesTobeInsert.add(quoteLine);
                    }
                    system.debug('quoteLinesTobeInsert::'+quoteLinesTobeInsert);
                    if(!quoteLinesTobeInsert.isEmpty()){
                        insert quoteLinesTobeInsert;
                        return true;
                    }
                }
            }    
            return false;
        }
        catch(Exception ex)
        {
            System.debug(ex.getCause());
            System.debug(ex.getLineNumber());
            System.debug(ex.getMessage());
            return false;
        }
        
    }

    public static Boolean calculateQuotationOpportunity(Opportunity opp,decimal newSlabPrice){
        Boolean returnValue = true;
        try{
            if(opp != null){
                list<opportunity> oppList = new List<Opportunity>();
                oppList.add(opp);
                returnValue = calculateQuotationSteps(oppList, newSlabPrice);
            }
                   
            return returnValue;
        }
        catch(Exception ex)
        {
            System.debug(ex.getCause());
            System.debug(ex.getLineNumber());
            System.debug(ex.getMessage());
            return false;
        }
        
    }
    
    public static Boolean calculateQuotationSteps(List<Opportunity> oppList,decimal newSlabPrice){
        try{
            if (!oppList.isEmpty()) {
                product2 product = new product2();
                integer subscriptionPeriod = 0;
                integer totalSubscriptionPeriod = 0;
                string productId = '';
                string quoteId = '';
                Date subscriptionDate;
                Date subScriptionEndDate;
                map<string,OpportunityLineItem> mapofOppIdByOppProd = new map<string,OpportunityLineItem>();
                list<OpportunityLineItem> oppProducts = new list<OpportunityLineItem>();
                if(oppList != null && !oppList.isEmpty()){
                    oppProducts = [select id,UnitPrice,Subscription_Start_Date__c,Subscription_End_Date__c,Quantity,opportunityId,Product2Id from OpportunityLineItem where opportunityId =: oppList[0].Id];
                    System.debug('1');
                    for(OpportunityLineItem oppLine : oppProducts){
                        mapofOppIdByOppProd.put(oppList[0].Id,oppLine);
                    }
                    if(oppList[0].Contract_Length__c != null && oppList[0].Contract_Length__c >=0 && oppList[0].Contract_Length__c <= 23){
                        subscriptionPeriod = 12;
                    }
                    else if(oppList[0].Contract_Length__c != null && oppList[0].Contract_Length__c >=24 && oppList[0].Contract_Length__c <= 35){
                        subscriptionPeriod = 24;
                    }
                    else if(oppList[0].Contract_Length__c != null && oppList[0].Contract_Length__c >35){
                        subscriptionPeriod = 36;
                    }
                    
                    if(oppList[0].Contract_Length__c != null){
                        if(oppList[0].Create_Trial__c){
                            totalSubscriptionPeriod = Integer.valueOf(String.valueOf(oppList[0].Trial_Period_In_Month__c)) + Integer.valueOf(String.valueOf(oppList[0].Contract_Length__c));
                        }
                        else{
                            totalSubscriptionPeriod = Integer.valueOf(oppList[0].Trial_Period_In_Month__c);
                        }
                    }
                    list<SBQQ__BlockPrice__c> prodBlockPriceList = [select id,SBQQ__LowerBound__c,SBQQ__UpperBound__c,SBQQ__Price__c,SBQQ__OriginalBlockPrice__r.SBQQ__Product__c,SBQQ__OriginalBlockPrice__r.SBQQ__Product__r.Quote_Line_Types__c,SBQQ__OriginalBlockPrice__r.SBQQ__Product__r.ProductCode from SBQQ__BlockPrice__c where SBQQ__OriginalBlockPrice__r.SBQQ__Product__r.ProductCode =: oppList[0].Deal_Organization_Type__c and SBQQ__OriginalBlockPrice__r.Pricing_Period__c =: subscriptionPeriod];
                    
                    if(oppList[0].Create_Trial__c){
                        string prodCode = oppList[0].Deal_Organization_Type__c+'Trial';
                        product = [select id from product2 where ProductCode =:prodCode limit 1];
                    }
                    else if(oppList[0].Create_Pilot__c){
                        string prodCode = oppList[0].Deal_Organization_Type__c+'Pilot';
                        product = [select id from product2 where ProductCode =:prodCode limit 1];
                    }
                    
                    if(oppList[0].Create_Trial__c && oppList[0].Trial_Period_In_Month__c > 0){
                        subscriptionDate = Date.newInstance( oppList[0].Subscription_Start_Date__c.Year(), oppList[0].Subscription_Start_Date__c.Month(), oppList[0].Subscription_Start_Date__c.Day());
                        
                        subscriptionDate = subscriptionDate.addMonths(Integer.valueOf(string.valueOf(oppList[0].Trial_Period_In_Month__c)));
                        subScriptionEndDate = subscriptionDate.addMonths(Integer.valueOf(string.valueOf(oppList[0].Contract_Length__c)));
                    }
                    else{
                        subScriptionEndDate = Date.newInstance( oppList[0].Subscription_Start_Date__c.Year(), oppList[0].Subscription_Start_Date__c.Month(), oppList[0].Subscription_Start_Date__c.Day());
                        subScriptionEndDate = subScriptionEndDate.addMonths(Integer.valueOf(string.valueOf(oppList[0].Contract_Length__c)));
                    }
                    
                    List<SBQQ__QuoteLine__c> quoteLinesTobeInsert = new List<SBQQ__QuoteLine__c>();
                    map<string,SBQQ__BlockPrice__c> mapofBlockIdByBlockPrice = new map<string,SBQQ__BlockPrice__c>();
                    string quoteLineTypes = '';
                    if(prodBlockPriceList != null && !prodBlockPriceList.isEmpty()){
                        for(SBQQ__BlockPrice__c blockPrice : prodBlockPriceList){
                            productId = blockPrice.SBQQ__OriginalBlockPrice__r.SBQQ__Product__c;//SBQQ__OriginalBlockPrice__r.SBQQ__Product__c
                            quoteLineTypes = blockPrice.SBQQ__OriginalBlockPrice__r.SBQQ__Product__r.Quote_Line_Types__c; //SBQQ__OriginalBlockPrice__r.SBQQ__Product__r.Quote_Line_Types__c
                            if(oppList[0].Deal_Confirmed_Enrollment__c >= blockPrice.SBQQ__LowerBound__c && oppList[0].Deal_Confirmed_Enrollment__c < blockPrice.SBQQ__UpperBound__c){
                                mapofBlockIdByBlockPrice.put(blockPrice.Id,blockPrice);
                            }
                        }
                    }
                    SBQQ__Quote__c quote = new SBQQ__Quote__c();
                    
                    quote.SBQQ__Opportunity2__c = oppList[0].Id;
                    quote.SBQQ__SubscriptionTerm__c = totalSubscriptionPeriod;
                    quote.SBQQ__Account__c = oppList[0].AccountId;
                    quote.SBQQ__Primary__c = true;
                    if(oppList[0].Create_Trial__c){
                        quote.SBQQ__StartDate__c = oppList[0].Subscription_Start_Date__c;//Subscription_End_Date__c
                        if(oppList[0].Add_Additional_Period__c && oppList[0].Additiona_Period_Date__c != null){
                            quote.SBQQ__EndDate__c = oppList[0].Additiona_Period_Date__c;
                        }else if(oppList[0].Promo_Free_Period__c && oppList[0].Promo_Free_Period_End_Date__c != null){
                            //Update 2023-03-15 by Iceberg RevOps: set quote end date from opp's Promo Free Period End Date
                            quote.SBQQ__EndDate__c = oppList[0].Promo_Free_Period_End_Date__c;
                        }
                        else{
                            quote.SBQQ__EndDate__c = oppList[0].Subscription_Start_Date__c.addMonths(Integer.valueOf(String.valueOf(oppList[0].Contract_Length__c + oppList[0].Trial_Period_In_Month__c))) - 1;
                        }
                    }else{
                        quote.SBQQ__StartDate__c = oppList[0].Subscription_Start_Date__c;
                        if(oppList[0].Add_Additional_Period__c && oppList[0].Additiona_Period_Date__c != null){
                            quote.SBQQ__EndDate__c= oppList[0].Additiona_Period_Date__c;
                        }else if(oppList[0].Promo_Free_Period__c && oppList[0].Promo_Free_Period_End_Date__c != null){
                            //Update 2023-03-15 by Iceberg RevOps: set quote end date from opp's Promo Free Period End Date
                            quote.SBQQ__EndDate__c = oppList[0].Promo_Free_Period_End_Date__c;
                        }else{
                            quote.SBQQ__EndDate__c= subScriptionEndDate - 1;
                        }
                        
                    }
                    
                    insert quote;
                    quoteId = quote.Id;
                    system.debug('quoteId::'+quoteId);
                    if(!mapofBlockIdByBlockPrice.isEmpty() && !oppList[0].Create_Pilot__c){
                        if(oppList[0].Deal_Organization_Type__c == 'Department'){
                            Utility.createDepartmentQuoteLineItem(oppList[0],quoteId,mapofBlockIdByBlockPrice,productId,newSlabPrice);
                        }else{
                            for(string key : mapofBlockIdByBlockPrice.keySet()){
                                System.debug('3');
                                SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                                quoteLine.SBQQ__Product__c = productId;
                                if(oppList[0].Deal_Organization_Type__c == 'Department'){
                                    quoteLine.SBQQ__Quantity__c = 1;
                                }else{
                                    quoteLine.SBQQ__Quantity__c = oppList[0].Deal_Confirmed_Enrollment__c;
                                }
                                
                                quoteLine.SBQQ__PricingMethod__c = quoteLineTypes;
                                quoteLine.SBQQ__ProductSubscriptionType__c = 'Renewable';
                                quoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                                quoteLine.SBQQ__DefaultSubscriptionTerm__c = totalSubscriptionPeriod;
                                quoteLine.SBQQ__SubscriptionType__c = 'Renewable';
                                system.debug('mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c::'+mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c);
                                system.debug('oppList[0].Deal_Confirmed_Enrollment__c * mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c::'+oppList[0].Deal_Confirmed_Enrollment__c * mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c);
                                system.debug('oppList[0].Slab_Prize__c::'+oppList[0].Slab_Prize__c);
                                if(oppList[0].Deal_Organization_Type__c == 'Department'){
                                    if(oppList[0].Deal_Confirmed_Enrollment__c <= 1500 && newSlabPrice != 0){
                                        System.debug('4');
                                        quoteLine.SBQQ__ListPrice__c = newSlabPrice;
                                        quoteLine.Slab_Price__c = newSlabPrice;
                                        quoteLine.Slab_Discount__c = ((mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c - newSlabPrice)/mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c)*100;
                                        if(quoteLine.Slab_Discount__c == 100){
                                            quoteLine.Slab_Discount__c = 0;
                                        }
                                        quoteLine.Actual_Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                    }else if(oppList[0].Deal_Confirmed_Enrollment__c <= 1500){
                                        quoteLine.SBQQ__ListPrice__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                        quoteLine.Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                        quoteLine.Slab_Discount__c = ((mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c - newSlabPrice)/mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c)*100;
                                        if(quoteLine.Slab_Discount__c == 100){
                                            quoteLine.Slab_Discount__c = 0;
                                        }
                                        quoteLine.Actual_Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                    }else if(oppList[0].Deal_Confirmed_Enrollment__c > 1500 && newSlabPrice != 0){
                                        quoteLine.SBQQ__ListPrice__c = newSlabPrice;
                                        quoteLine.Slab_Price__c = newSlabPrice;
                                        quoteLine.Slab_Discount__c = ((mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c - newSlabPrice)/mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c)*100;
                                        if(quoteLine.Slab_Discount__c == 100){
                                            quoteLine.Slab_Discount__c = 0;
                                        }
                                        quoteLine.Actual_Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                    }else if(oppList[0].Deal_Confirmed_Enrollment__c > 1500){
                                        quoteLine.SBQQ__ListPrice__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                        quoteLine.Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                        quoteLine.Slab_Discount__c = ((mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c - newSlabPrice)/mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c)*100;
                                        if(quoteLine.Slab_Discount__c == 100){
                                            quoteLine.Slab_Discount__c = 0;
                                        }
                                        quoteLine.Actual_Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                    }
                                }else if(newSlabPrice != 0){
                                    quoteLine.SBQQ__ListPrice__c = ((newSlabPrice * oppList[0].Contract_Length__c)/12) * 1;
                                    quoteLine.Slab_Price__c = newSlabPrice;
                                    quoteLine.Slab_Discount__c = ((mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c - newSlabPrice)/mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c)*100;
                                    if(quoteLine.Slab_Discount__c == 100){
                                        quoteLine.Slab_Discount__c = 0;
                                    }    
                                    quoteLine.Actual_Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                }else if(oppList[0].Deal_Organization_Type__c != 'Department'){
                                    quoteLine.SBQQ__ListPrice__c = ((mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c * oppList[0].Contract_Length__c)/12) * 1;
                                    quoteLine.Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                    oppList[0].Slab_Prize__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                    quoteLine.Slab_Discount__c = ((mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c - newSlabPrice)/mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c)*100;
                                    if(quoteLine.Slab_Discount__c == 100){
                                        quoteLine.Slab_Discount__c = 0;
                                    }    
                                    quoteLine.Actual_Slab_Price__c = mapofBlockIdByBlockPrice.get(key).SBQQ__Price__c;
                                }
                                quoteLine.SBQQ__Quote__c = quote.Id;
                                quoteLinesTobeInsert.add(quoteLine);
                            }
                        }
                        
                    }
                    
                    if(oppList[0].Create_Pilot__c){
                        system.debug('Inside Pilot product::');
                        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                        system.debug('product.Id::'+product.Id);
                        quoteLine.SBQQ__Product__c = product.Id;
                        if(oppList[0].Deal_Organization_Type__c == 'Department'){
                            quoteLine.SBQQ__Quantity__c = 1;
                        }else{
                            quoteLine.SBQQ__Quantity__c = oppList[0].Deal_Confirmed_Enrollment__c;
                        }
                        //quoteLine.SBQQ__Quantity__c = oppList[0].Deal_Confirmed_Enrollment__c;
                        quoteLine.SBQQ__PricingMethod__c = 'Custom';
                        quoteLine.SBQQ__ProductSubscriptionType__c = 'Renewable';
                        quoteLine.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                        quoteLine.SBQQ__SubscriptionType__c = 'Renewable';
                        quoteLine.SBQQ__DefaultSubscriptionTerm__c = totalSubscriptionPeriod;
                        quoteLine.SBQQ__ListPrice__c = 0;
                        quoteLine.Slab_Price__c = 0;
                        quoteLine.SBQQ__Quote__c = quoteId;
                        system.debug('quoteLine::'+quoteLine);
                        quoteLinesTobeInsert.add(quoteLine);
                    }
                    
                    if(oppList[0].Create_Trial__c){
                        System.debug('5');
                        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
                        quoteLine.SBQQ__Product__c = product.Id;
                        if(oppList[0].Deal_Organization_Type__c == 'Department'){
                            quoteLine.SBQQ__Quantity__c = 1;
                        }else{
                            quoteLine.SBQQ__Quantity__c = oppList[0].Deal_Confirmed_Enrollment__c;
                        }
                        
                        quoteLine.SBQQ__PricingMethod__c = 'Custom';
                        quoteLine.SBQQ__ListPrice__c = 0;
                        quoteLine.Slab_Price__c = 0;
                        quoteLine.SBQQ__Quote__c = quoteId;
                        system.debug('quoteLine::'+quoteLine);
                        quoteLinesTobeInsert.add(quoteLine);
                    }
                    system.debug('quoteLinesTobeInsert::'+quoteLinesTobeInsert);
                    if(!quoteLinesTobeInsert.isEmpty()){
                        insert quoteLinesTobeInsert;
                        return true;
                    }
                }
            }    
            return false;
        }
        catch(Exception ex)
        {
            System.debug(ex.getCause());
            System.debug(ex.getLineNumber());
            System.debug(ex.getMessage());
            return false;
        }
        
    }
    
    public static void postOpportunityClosedWonActivity(list<Opportunity> newOpportunityList,map<Id,Opportunity> mapofOldOpportunityDet){
        Set<Id> accIdSet							= new Set<Id>();
        Set<Id> oppIdSet 							= new Set<Id>();
        Set<Id> mulOppIdSet							= new Set<Id>();
        Set<String> conIdSet						= new Set<String>();
        Set<Id> subIdSet							= new Set<Id>();
        Set<Id> departmentOppidSet					= new Set<Id>();
        Id oppId;
        
        List<SBQQ__Subscription__c> subList			= new List<SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> subTobeDelete 	= new List<SBQQ__Subscription__c>();
        
        Map<Id,Id> mapofoppIdbyCSId		 			= new Map<Id,Id>();
        Map<Id,String> mapofAccIDByOppOrgType 		= new map<Id,String>();
        
        for(Opportunity opp : newOpportunityList){
            if((opp.StageName == Constant.NEW_BUSSINESS_CLOSEDSTAGE || opp.StageName == Constant.EXISTING_BUSSINESS_CLOSEDSTAGE)
               && opp.StageName != mapofOldOpportunityDet.get(opp.Id).StageName){
                   oppId = opp.Id;
                   oppIdSet.add(opp.Id);
                   accIdSet.add(opp.AccountId);
                   mapofAccIDByOppOrgType.put(opp.AccountId,opp.Deal_Organization_Type__c);
                   if(opp.CSOwner__c != null){
                       mapofoppIdbyCSId.put(opp.Id,opp.CSOwner__c);
                   }
                   if(opp.Deal_Organization_Type__c == 'Multi-School'){
                       mulOppIdSet.add(opp.Id);
                   }
                   if(opp.Deal_Organization_Type__c == 'Department'){
                       departmentOppidSet.add(opp.Id);
                   }
               }
        }
        
        if(!oppIdSet.isEmpty()){
            List<Contract> conList = [select id,(select id from SBQQ__Subscriptions__r limit 1) from contract where SBQQ__Opportunity__c in: oppIdSet];
            
            if(!conList.isEmpty()){
                for(Contract con : conList){
                    conIdSet.add(con.id);
                }
            }
        }
        
        if(!mulOppIdSet.isEmpty()){
            List<SBQQ__Subscription__c> subScriptionList = new List<SBQQ__Subscription__c>();
            
            subScriptionList = [select id from SBQQ__Subscription__c where SBQQ__Contract__r.SBQQ__Opportunity__c in: mulOppIdSet];
            
            if(!subScriptionList.isEmpty()){
                for(SBQQ__Subscription__c sub : subScriptionList){
                    subIdSet.add(sub.id);
                }
            }
        }
        
        if(!departmentOppidSet.isEmpty()){
            
            subList = [select id from SBQQ__Subscription__c where SBQQ__Contract__r.SBQQ__Opportunity__c =: departmentOppidSet];
            
            if(subList.size() > 1){
                for(integer i =0; i< subList.size();i++){
                    if(i != 0){
                        subTobeDelete.add(subList[i]);
                    }
                }
                system.debug('subTobeDelete::'+subTobeDelete.size());
                if(!subTobeDelete.isEmpty()){
                    delete subTobeDelete;
                }
            }
        }
        
        if(!mapofoppIdbyCSId.isEmpty()){
            Utility.createOnboardingTaskOnClosedWon(mapofoppIdbyCSId);
        }
        
        if(!accIdSet.isEmpty()){
            Utility.changeContactOwnerTOCS(accIdSet);
        }
        
        if(!accIdSet.isEmpty()){
            Utility.updateAccountSubscriptionType(accIdSet,mapofAccIDByOppOrgType);
        }
        
        if(!conIdSet.isEmpty()){
            ContractTriggerHelper.createRenewalOpportunity(conIdSet);
        }
        
        if(!subIdSet.isEmpty()){
            SubscriptionTriggerHandler.tagsubScriptiontoSchool(subIdSet);
        }
        if(label.Enable_Schedule_Invoice == 'true'){
            createInvoiceSchedule(oppId);
        }
    }
    
    public static void createInvoiceSchedule(Id oppId){
        Set<Id> oppIdSet = new Set<Id>{oppId};
            OpportunityInvoiceCreation.createInvoices(oppIdSet);
    }
    
    
    public Static void onchangeMapDettoMulOppo(list<Opportunity> newOpportunityList,Map<Id,Opportunity> oldOpportunityMap){
        set<String> changeOppId = new set<String>();
        map<String,Opportunity> mapofParentOppidByOpp = new map<String,Opportunity>();
        list<Opportunity> mulopportunityTobeUpdate = new list<Opportunity>();
        for(Opportunity newOpp : newOpportunityList){
            if(newOpp.Subscription_Start_Date__c != null && newOpp.Subscription_Start_Date__c != oldOpportunityMap.get(newOpp.id).Subscription_Start_Date__c || 
               newOpp.Contract_Length__c != null && newOpp.Contract_Length__c != oldOpportunityMap.get(newOpp.id).Contract_Length__c || 
               newOpp.StageName != null && newOpp.StageName != oldOpportunityMap.get(newOpp.id).StageName){
                   changeOppId.add(newOpp.Id);
                   mapofParentOppidByOpp.put(newOpp.Id,newOpp);
               }
        }
        
        if(!changeOppId.isEmpty()){
            mulopportunityTobeUpdate = [select id,StageName,Subscription_Start_Date__c,Master_Opportunity__c,Contract_Length__c from opportunity where Master_Opportunity__c in: changeOppId];
            if(!mulopportunityTobeUpdate.isEmpty()){
                for(Opportunity oppDet : mulopportunityTobeUpdate){
                    oppDet.Subscription_Start_Date__c = mapofParentOppidByOpp.get(oppDet.Master_Opportunity__c).Subscription_Start_Date__c;
                    oppDet.Contract_Length__c = mapofParentOppidByOpp.get(oppDet.Master_Opportunity__c).Contract_Length__c;
                    system.debug('oppDet.StageName::'+oppDet.StageName);
                    if(mapofParentOppidByOpp.get(oppDet.Master_Opportunity__c).StageName == 'Closed Won' || mapofParentOppidByOpp.get(oppDet.Master_Opportunity__c).StageName == 'Closed/Won'){
                        oppDet.StageName = 'Multi-school Closed Won';
                    }else{
                        oppDet.StageName = mapofParentOppidByOpp.get(oppDet.Master_Opportunity__c).StageName;
                    }
                    
                }
                system.debug('mulopportunityTobeUpdate::'+mulopportunityTobeUpdate);
                update mulopportunityTobeUpdate;
            }
        }
    }
    
    public static void validateAdditionalPeriod(list<Opportunity> newOpportunityList,map<Id,Opportunity> mapofOldOpp){
        for(Opportunity opp : newOpportunityList){
            if(opp.Additiona_Period_Date__c != null && opp.Create_Pilot__c){
                opp.Additiona_Period_Date__c.addError('You can not add Additional period in Pilot Product.');
            }
            if(opp.Additiona_Period_Date__c != null && mapofOldOpp.get(opp.Id).Additiona_Period_Date__c != opp.Additiona_Period_Date__c){
                if(opp.Subscription_End_Date__c.daysBetween(opp.Additiona_Period_Date__c) > 45){
                    opp.Additiona_Period_Date__c.addError('You can not add more than 45 days as extension period.');
                }
            }
        }
    }
    
    public static void validateDepartmentProductOnClosedwon(List<Opportunity> newOpportunity){
        set<String> oppIdSet = new set<String>();
        map<String,Opportunity> mapofOppIdByOpp = new map<String,Opportunity>();
        for(Opportunity oppDet : newOpportunity){
            if(oppDet.StageName == 'Closed Won' || oppDet.StageName == 'Closed/Won'){
                oppIdSet.add(oppDet.id);
                mapofOppIdByOpp.put(oppDet.id,oppDet);
            }
        }
        
        if(!oppIdSet.isEmpty()){
            list<OpportunityLineItem> opportunityLineItemList = new list<OpportunityLineItem>();
            opportunityLineItemList = [select id,Department_Type__c,OpportunityId,ProductCode from OpportunityLineItem where OpportunityId in: oppIdSet];
            
            for(OpportunityLineItem oppLineItem : opportunityLineItemList){
                if(oppLineItem.Department_Type__c == null && oppLineItem.ProductCode == 'Department'){
                    mapofOppIdByOpp.get(oppLineItem.OpportunityId).StageName.addError('Please select department type in each Product Line Item.');
                }
            }
        }
    }
    
    public static void validateDepartmentCount(List<Opportunity> OpportunityList){
        for(Opportunity opp : OpportunityList){
            if(opp.Deal_Organization_Type__c == 'Department' && opp.Department_Count__c == null){
                opp.Department_Count__c.addError('Please provide department Count.');
            }
        }
    }
    
    public static void syncStartDateEndDate(List<Opportunity> oppList,Map<Id,Opportunity> mapofOldOpportunity){
        List<Opportunity> oppListTobeShare = new List<Opportunity>();
        for(Opportunity opp : oppList){
            if(opp.Subscription_Start_Date__c != null && (opp.Subscription_Start_Date__c != mapofOldOpportunity.get(opp.Id).Subscription_Start_Date__c) || opp.Contract_Length__c != mapofOldOpportunity.get(opp.Id).Contract_Length__c){
                oppListTobeShare.add(opp);
            }else if(opp.Add_Additional_Period__c != mapofOldOpportunity.get(opp.Id).Add_Additional_Period__c){
                oppListTobeShare.add(opp);
            }else if(opp.Promo_Free_Period__c != mapofOldOpportunity.get(opp.Id).Promo_Free_Period__c){
                oppListTobeShare.add(opp);
            }
        }
        
        if(!oppListTobeShare.isEmpty()){
            mapStartDateOnChange1(oppListTobeShare);
        }
    }
    
    public static void mapStartDateOnChange1(List<Opportunity> oppListTobeShare){
        String quoteid = '';
        boolean isContractCreated = false;
        boolean startDateChange = false;
        Map<Id,Opportunity> mapofNewOppDet = new Map<Id,Opportunity>();
        map<String,Decimal> mapofoppIdbyTrialPeriod = new map<String,Decimal>();
        map<string,List<OpportunityLineItem>> mapofOppidByOppLineItem = new map<String,List<OpportunityLineItem>>();
        
        for(Opportunity opp : oppListTobeShare){
            mapofNewOppDet.put(opp.id,opp);
            if(opp.SBQQ__PrimaryQuote__c != null){
                quoteid = opp.SBQQ__PrimaryQuote__c;
            }
            if(opp.SBQQ__Contracted__c){
                isContractCreated = true;
            }
        }
        
        List<OpportunityLineItem> oppLineItemList = [select id,Subscription_Start_Date__c,unitprice,OpportunityId
                                                     from opportunitylineitem where opportunityId in: mapofNewOppDet.keySet()];
        
        for(OpportunityLineItem oppLine : oppLineItemList){
            if(mapofOppidByOppLineItem.containsKey(oppLine.OpportunityId)){
                mapofOppidByOppLineItem.get(oppLine.OpportunityId).add(oppLine);
            }else{
                mapofOppidByOppLineItem.put(oppLine.OpportunityId,new list<OpportunityLineItem>{oppLine});
            }
            
        }
        
        if(!mapofOppidByOppLineItem.isEmpty()){
            list<OpportunityLineItem> oppLineItemTobeUpdate = new list<OpportunityLineItem>();
            for(String mapKey : mapofOppidByOppLineItem.keySet()){
                for(OpportunityLineItem oppLine : mapofOppidByOppLineItem.get(mapKey)){
                    if(mapofNewOppDet.get(mapKey).create_trial__c && mapofNewOppDet.get(mapKey).Trial_Period_In_Month__c > 0){
                        if(oppLine.unitprice == 0){
                            oppLine.Subscription_Start_Date__c = mapofNewOppDet.get(mapKey).Subscription_Start_Date__c;
                            oppLine.Subscription_End_Date__c = mapofNewOppDet.get(mapKey).Subscription_Start_Date__c.addMonths(integer.valueOf(String.valueOf(mapofNewOppDet.get(mapKey).Trial_Period_In_Month__c))) - 1;
                            oppLineItemTobeUpdate.add(oppLine);
                            
                        }
                    }
                    
                }
                system.debug('oppLineItemTobeUpdate::'+oppLineItemTobeUpdate);
                for(OpportunityLineItem oppLine : mapofOppidByOppLineItem.get(mapKey)){
                    if(mapofNewOppDet.get(mapKey).Create_Pilot__c){
                        if(oppLine.unitprice == 0){
                            oppLine.Subscription_Start_Date__c = mapofNewOppDet.get(mapKey).Subscription_Start_Date__c;
                            oppLine.Subscription_End_Date__c = mapofNewOppDet.get(mapKey).Subscription_Start_Date__c.addMonths(integer.valueOf(String.valueOf(mapofNewOppDet.get(mapKey).Pilot_Period__c))) - 1;
                            oppLineItemTobeUpdate.add(oppLine);
                        }
                    }
                }
                for(OpportunityLineItem oppLine : mapofOppidByOppLineItem.get(mapKey)){
                    if(oppLine.unitprice != 0){
                        if(mapofNewOppDet.get(mapKey).create_trial__c){
                            oppLine.Subscription_Start_Date__c = mapofNewOppDet.get(mapKey).Subscription_Start_Date__c.addMonths(integer.valueOf(String.valueOf(mapofNewOppDet.get(mapKey).Trial_Period_In_Month__c)));
                            oppLine.Subscription_End_Date__c = mapofNewOppDet.get(mapKey).Subscription_Start_Date__c.addMonths(integer.valueOf(String.valueOf(mapofNewOppDet.get(mapKey).Contract_Length__c)) + integer.valueOf(String.valueOf(mapofNewOppDet.get(mapKey).Trial_Period_In_Month__c))) - 1;
                            
                            oppLineItemTobeUpdate.add(oppLine);
                        }else{
                            oppLine.Subscription_Start_Date__c = mapofNewOppDet.get(mapKey).Subscription_Start_Date__c;
                            oppLine.Subscription_End_Date__c = mapofNewOppDet.get(mapKey).Subscription_Start_Date__c.addMonths(integer.valueOf(String.valueOf(mapofNewOppDet.get(mapKey).Contract_Length__c))) - 1;
                            if((mapofNewOppDet.get(mapKey).Slab_Prize__c != null)){
                                //oppLine.UnitPrice = ((mapofNewOppDet.get(mapKey).Slab_Prize__c * mapofNewOppDet.get(mapKey).Contract_Length__c) / 12);
                            }
                            oppLineItemTobeUpdate.add(oppLine);
                        }
                        
                        //oppLine.Subscription_End_Date__c = oppDetails.Subscription_Start_Date__c.addMonths(integer.valueOf(String.valueOf(oppDetails.Contract_Length__c))) - 1;
                    }
                }
            }
            system.debug('oppLineItemTobeUpdate::'+oppLineItemTobeUpdate);
            if(!oppLineItemTobeUpdate.isEmpty()){
                update oppLineItemTobeUpdate;
            }
            system.debug('quoteid::'+quoteid);
            if(quoteid != ''){
                SBQQ__Quote__c quoteDet = [select Id,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Opportunity2__c from SBQQ__Quote__c where id =: quoteid];
                system.debug('Start Date::'+mapofNewOppDet.get(quoteDet.SBQQ__Opportunity2__c).Subscription_Start_Date__c);
                system.debug('End Date::'+mapofNewOppDet.get(quoteDet.SBQQ__Opportunity2__c).Subscription_End_Date__c);
                quoteDet.SBQQ__StartDate__c = mapofNewOppDet.get(quoteDet.SBQQ__Opportunity2__c).Subscription_Start_Date__c;
                quoteDet.SBQQ__EndDate__c = mapofNewOppDet.get(quoteDet.SBQQ__Opportunity2__c).Subscription_End_Date__c;
                if(mapofNewOppDet.get(quoteDet.SBQQ__Opportunity2__c).create_Trial__c){
                    quoteDet.SBQQ__SubscriptionTerm__c = mapofNewOppDet.get(quoteDet.SBQQ__Opportunity2__c).Contract_Length__c + Integer.valueOf(String.valueOf(mapofNewOppDet.get(quoteDet.SBQQ__Opportunity2__c).Trial_Period_In_Month__c));
                }else{
                    quoteDet.SBQQ__SubscriptionTerm__c = mapofNewOppDet.get(quoteDet.SBQQ__Opportunity2__c).Contract_Length__c;
                }
                update quoteDet;
                
            }
            system.debug('isContractCreated::'+isContractCreated);
            if(isContractCreated){
                Set<Id> contractIdSet = new Set<Id>();
                Map<Id,Id> mapofConIdByOppId = new Map<Id,Id>();
                List<Contract> contractList = new list<Contract>();
                contractList = [select id,StartDate,EndDate,SBQQ__Opportunity__c from contract where SBQQ__Opportunity__c in: mapofNewOppDet.keySet()];
                
                if(!contractList.isEmpty()){
                    for(Contract conDet : contractList){
                        mapofConIdByOppId.put(conDet.Id,conDet.SBQQ__Opportunity__c);
                        conDet.StartDate = mapofNewOppDet.get(conDet.SBQQ__Opportunity__c).Subscription_Start_Date__c;
                        conDet.EndDate = mapofNewOppDet.get(conDet.SBQQ__Opportunity__c).Subscription_End_Date__c;
                        system.debug('conDet.StartDate::'+conDet.StartDate);
                        system.debug('conDet.EndDate::'+conDet.EndDate);
                        if(mapofNewOppDet.get(conDet.SBQQ__Opportunity__c).create_Trial__c){
                            conDet.ContractTerm = Integer.valueOf(String.valueOf(mapofNewOppDet.get(conDet.SBQQ__Opportunity__c).Contract_Length__c)) + Integer.valueOf(String.valueOf(mapofNewOppDet.get(conDet.SBQQ__Opportunity__c).Trial_Period_In_Month__c));
                        }else{
                            conDet.ContractTerm = Integer.valueOf(String.valueOf(mapofNewOppDet.get(conDet.SBQQ__Opportunity__c).Contract_Length__c));
                        }
                        
                        //conDet.EndDate = mapofNewOppDet.get(conDet.SBQQ__Opportunity__c).Subscription_End_Date__c;
                    }
                    
                    if(!mapofConIdByOppId.isEmpty()){
                        list<SBQQ__Subscription__c> subListTobeUpdate = new List<SBQQ__Subscription__c>();
                        subListTobeUpdate = [select id,SBQQ__Contract__c from SBQQ__Subscription__c where SBQQ__Contract__c in : mapofConIdByOppId.keySet()];
                        if(!subListTobeUpdate.isEmpty()){
                            for(SBQQ__Subscription__c sub : subListTobeUpdate){
                                sub.SBQQ__SubscriptionStartDate__c = mapofNewOppDet.get(mapofConIdByOppId.get(sub.SBQQ__Contract__c)).Subscription_Start_Date__c;
                                sub.SBQQ__SubscriptionEndDate__c = mapofNewOppDet.get(mapofConIdByOppId.get(sub.SBQQ__Contract__c)).Subscription_End_Date__c;
                            }
                            update subListTobeUpdate; 
                        }
                    }
                    system.debug('contractList::'+contractList);
                    if(!contractList.isEmpty()){
                        update contractList; 
                        system.debug('contractList::'+contractList);
                    }
                }
            }
        }
    }
}