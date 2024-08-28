public without sharing class MultiSelectSchoolHanlder {
    public static String parentOppMultiPartitionName = '';
    
    
    
    
    
    
    
    @AuraEnabled(cacheable=true)
    public static Opportunity getRecord(String oppId){
        try {
            for(Opportunity opp:[Select Id, Name, Account.Name,Account.Total_Enrollments__c,Account.Enrollment_Count__c from Opportunity Where Id=:oppId And Account.ParentId=null]){
                System.debug(opp.Account);
            }
            return [Select Id, Name, Deal_Confirmed_Enrollment__c,Account.Name,Account.Total_Enrollments__c,Account.Enrollment_Count__c from Opportunity Where Id=:oppId And Account.ParentId=null];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static ResponseWrapper getMainData(String oppId){
        try {
            Opportunity parentOpp = [Select Id, Account.Total_Enrollments__c,Account.Enrollment_Count__c, Name,AccountId, Account.Name,Account.External_NCES_ID_Parent__c,Account.External_NCES_ID__c from Opportunity Where Id=:oppId And Account.ParentId=null];
            System.debug(parentOpp.Account.External_NCES_ID_Parent__c);
            System.debug(parentOpp.Account.External_NCES_ID__c);
            System.debug(parentOpp.AccountId);
            System.debug(parentOpp.Account.Total_Enrollments__c);
            // List<Account> taggedList = [Select Id, Name,Enrollment_Count__c,Total_Enrollments__c,Enrollments__c From Account Where ParentId=:parentOpp.AccountId];
            List<Account> taggedList=[Select Id, Name,Enrollment_Count__c,Total_Enrollments__c,Enrollments__c From Account Where ParentId=:parentOpp.AccountId];//External_NCES_ID_Parent__c//External_NCES_ID_Parent__c=:parentOpp.Account.External_NCES_ID__c
            System.debug(taggedList);
            List<Opportunity> childOppList = [SELECT Id,Name,AccountId From Opportunity WHERE Master_Opportunity__c =:parentOpp.Id];
            List<String> childAccIdList = new List<String>();
            
            for(Opportunity childOpp : childOppList){
                childAccIdList.add(childOpp.AccountId);
                
            }
            System.debug('ChildAccList'+childAccIdList);
            
            List<Account> selectedAccList = [Select Id, Name, Enrollment_Count__c,Enrollments__c From Account Where Id In : childAccIdList];
            System.debug('SelectedAccList ----'+selectedAccList);
            return new ResponseWrapper(taggedList,selectedAccList,parentOpp);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //@AuraEnabled
    public static String deleteOppChildAccounts(set<String> accIdsLists,integer finalCount,Map<String,String> mapofOppIdByOppName,string parentOppId){
        system.debug('accIdsLists::'+accIdsLists);
        system.debug('mapofOppIdByOppName::'+mapofOppIdByOppName);
        system.debug('Value::'+mapofOppIdByOppName.values());
        if(parentOppId != null){
            Opportunity opp = [select id,MultiSchool_Partition__c from Opportunity where id =: parentOppId];
            for(String str : mapofOppIdByOppName.keySet()){
                if(opp.MultiSchool_Partition__c.contains(mapofOppIdByOppName.get(str))){
                    opp.MultiSchool_Partition__c = opp.MultiSchool_Partition__c.replace(mapofOppIdByOppName.get(str),'');
                }
            }
            
            system.debug('Multischool Partiotion::'+opp.MultiSchool_Partition__c);
            if(accIdsLists!=null){
                delete [SELECT Id,Master_Opportunity__c FROM Opportunity WHERE AccountId IN : accIdsLists AND Master_Opportunity__c!=null AND Master_Opportunity__c =: parentOppId];
                update opp;
                return 'deleted';
            }
            
        }
        
        
        
        
        //updateParentOpportunity(opportunityId,finalCount);
        return null;
    }
    
    //using by first tab
    @AuraEnabled
    public static String updateOppChildAccounts(string oppId,List<OppChildAccWrapper> oppChildAccWrapperList,String accIdtoUpdate,Integer totalEnrollements){
        System.debug(oppId);
        
        if(accIdtoUpdate!=null && totalEnrollements!=null){
            Account acc=[select id,Enrollment_Count__c,Subscription_Type__c from Account where Id=:accIdtoUpdate];
            if(acc!=null){
                acc.Enrollment_Count__c=totalEnrollements;
                acc.Subscription_Type__c='Partial District';
            }
            update acc;
        }
        if(oppChildAccWrapperList!=null && oppId!=null){
            //update list
            Opportunity oppDetailList = [select id,MultiSchool_Partition__c,Multi_Scholl_Created__c,CloseDate,StageName,AccountId,Name,Deal_Organization_Type__c,Deal_Confirmed_Enrollment__c,Subscription_Start_Date__c,Subscription_End_Date__c,Contract_Length__c,Create_Trial__c,Trial_Period_In_Month__c from opportunity where id =: oppId];     
            List<Opportunity> opps=new List<Opportunity>();
            integer finalCount = 0;
            if(oppDetailList.Deal_Confirmed_Enrollment__c != null && !oppDetailList.Multi_Scholl_Created__c){
                finalCount = 0;
            }else{
                finalCount = Integer.valueOf(String.valueOf(oppDetailList.Deal_Confirmed_Enrollment__c));
            }
            set<Id> accId= new set<Id>();
            set<Id> MasterOpp= new set<Id>();
            List<Account> childAccounts = new List<Account>();
            if(oppDetailList.MultiSchool_Partition__c != null){
                parentOppMultiPartitionName = oppDetailList.MultiSchool_Partition__c+'\n';
                System.debug('the Line 89---->'+parentOppMultiPartitionName);
            }
            
            
            for(OppChildAccWrapper oppAcc:oppChildAccWrapperList){
                Opportunity opp= new Opportunity();
                opp.AccountId=oppAcc.accId;
                accId.add(oppAcc.accId);
                opp.Deal_Confirmed_Enrollment__c=oppAcc.enrollNum;
                opp.Name=oppAcc.OppName+ '- Multischool Deal';
                opp.StageName=oppDetailList.StageName;
                opp.CloseDate=Date.today();
                opp.Deal_Organization_Type__c = oppDetailList.Deal_Organization_Type__c;
                opp.Subscription_Start_Date__c = oppDetailList.Subscription_Start_Date__c;
                opp.Subscription_End_Date__c = oppDetailList.Subscription_End_Date__c;
                opp.Contract_Length__c = oppDetailList.Contract_Length__c;
                opp.Create_Trial__c = oppDetailList.Create_Trial__c;
                opp.Trial_Period_In_Month__c = oppDetailList.Trial_Period_In_Month__c;
                opp.Multi_School_opportunity__c = true;
                opp.Master_Opportunity__c = oppDetailList.Id;
                
                MasterOpp.add(opp.Master_Opportunity__c);
                childAccounts.add(new Account(Id=oppAcc.accId,Enrollment_Count__c=oppAcc.enrollNum,Subscription_Type__c='Multi-School'));
                finalCount = finalCount + oppAcc.enrollNum;
                opps.add(opp);
                
                parentOppMultiPartitionName+=oppAcc.OppName+'\n';
            }
            if(finalCount != 0){
                Opportunity oppDet = new opportunity();
                oppDet.Id = oppDetailList.Id;
                oppDet.Deal_Confirmed_Enrollment__c = finalCount;
                oppDet.Multi_Scholl_Created__c=true;
                oppDet.MultiSchool_Partition__c = parentOppMultiPartitionName.Substring(0,parentOppMultiPartitionName.length()-4);
                System.debug('the Line 123---->'+oppDet.MultiSchool_Partition__c);
                update oppDet;
                update childAccounts;
            }
            insert opps;
            return JSON.serialize(opps); 
        }
        return null;
    }
    
    
    public static string updateOpportunity(Map<Id,Integer> accEnrolls,integer finalCount){
        system.debug('accEnrolls::'+accEnrolls);
        List<Account> accounts=[SELECT Id,Enrollment_Count__c FROM Account  WHERE Id IN : accEnrolls.keySet()];
        List<Opportunity> accOpps=[SELECT Id,Deal_Confirmed_Enrollment__c,AccountId,Master_Opportunity__c FROM Opportunity WHERE AccountId IN : accEnrolls.keyset() and Master_Opportunity__c != null];
        string opportunityId = '';
        System.debug(accounts);
        if(accounts.size()>0 && accEnrolls.isEmpty()==false){
            for(Account accs:accounts){
                System.debug(accEnrolls.get(accs.Id));
                accs.Enrollment_Count__c=accEnrolls.get(accs.Id);
            }
            update accounts;
            integer totalNagativeDif = 0;
            integer totalPositiveDif = 0;
            for(Opportunity opp:accOpps){
                if(opp.Master_Opportunity__c != null)
                    opportunityId = opp.Master_Opportunity__c;
                System.debug(accEnrolls.get(opp.Id));
                system.debug('opp::'+opp.Deal_Confirmed_Enrollment__c);
                system.debug('accEnrolls.get(opp.AccountId)::'+accEnrolls.get(opp.AccountId));
                opp.Deal_Confirmed_Enrollment__c=accEnrolls.get(opp.AccountId);
            }
            update accOpps;
            updateParentOpportunity(opportunityId,finalCount);
            return 'TRUE';
            
        }
        return null;
    }
    
    public static void updateParentOpportunity(string opportunityId,Integer finalEnrollCount){
        if(opportunityId != ''){
            Opportunity oppDet = new opportunity();
            oppDet.Id = opportunityId;
            oppDet.Deal_Confirmed_Enrollment__c = finalEnrollCount;
            oppDet.Multi_Scholl_Created__c=true;
            
            update oppDet;
        }
    }
    
    @AuraEnabled
    public static string updateAndDeleteAcc(List<RequestChildAccWrapper> requestChildWrapper,list<RequestChildAccWrapper> allSchoolWrp,string oppId){
        try {
            system.debug('requestChildWrapper::'+requestChildWrapper);
            system.debug('allSchoolWrp::'+allSchoolWrp);
            set<string> deleted=new set<string>();
            set<String> updated=new set<String>();
            Map<Id,Integer> oppEnrollments=new Map<Id,Integer>();
            map<string,integer> mapofOppIdByScore = new map<string,integer>();
            Map<String,String> mapofOppIdByOppName = new Map<String,String>();
            if(!allSchoolWrp.isEmpty()){
                for(RequestChildAccWrapper reqChild:allSchoolWrp){
                    mapofOppIdByScore.put(reqChild.Id,reqChild.enrollment);
                }
            }
            for(RequestChildAccWrapper reqChild:requestChildWrapper){
                if(reqChild.isDeleted){
                    mapofOppIdByScore.put(reqChild.Id,0);
                    deleted.add(reqChild.Id);
                    mapofOppIdByOppName.put(reqChild.Id,reqChild.Name);
                }
                system.debug('deleted::'+deleted);
                if(reqChild.isEdit){
                    mapofOppIdByScore.put(reqChild.Id,reqChild.enrollment);
                    updated.add(reqChild.Id);
                    oppEnrollments.put(reqChild.Id,reqChild.enrollment);
                }
            }
            integer finalCount = 0;
            system.debug('mapofOppIdByScore::'+mapofOppIdByScore);
            for(String mapKey : mapofOppIdByScore.keySet()){
                if(mapofOppIdByScore.get(mapKey) > 0){
                    finalCount = finalCount + mapofOppIdByScore.get(mapKey);
                }
            }
            system.debug('finalCount::'+finalCount);
            MultiSelectSchoolHanlder.deleteOppChildAccounts(deleted,finalCount,mapofOppIdByOppName,oppId);
            System.debug(oppEnrollments);
            MultiSelectSchoolHanlder.updateOpportunity(oppEnrollments,finalCount);
            return JSON.serialize(requestChildWrapper);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string createOpportunityWithoutEnrollment(string oppId,List<OppChildAccWrapper> oppChildAccWrapperList,String accIdtoUpdate,Integer totalEnrollements){
        try {
            system.debug('oppId::'+oppId);
            system.debug('oppChildAccWrapperList::'+oppChildAccWrapperList);
            system.debug('accIdtoUpdate::'+accIdtoUpdate);
            system.debug('totalEnrollements::'+totalEnrollements);
            List<Opportunity> opps=new List<Opportunity>();
            if(oppChildAccWrapperList!=null && oppId!=null){
                //update list
                Opportunity oppDetailList = [select id,MultiSchool_Partition__c,RecordtypeId,Multi_Scholl_Created__c,CloseDate,StageName,AccountId,Name,Deal_Organization_Type__c,Deal_Confirmed_Enrollment__c,Subscription_Start_Date__c,Subscription_End_Date__c,Contract_Length__c,Create_Trial__c,Trial_Period_In_Month__c from opportunity where id =: oppId];     
                if(oppDetailList.Deal_Confirmed_Enrollment__c == null){
                    return 'Please provide enrollment count.';
                }
                oppDetailList.Multi_School_W_O_Enrollment__c = true;
                update oppDetailList;
                integer finalCount = 0;
                
                if(oppDetailList.Deal_Confirmed_Enrollment__c != null && !oppDetailList.Multi_Scholl_Created__c){
                    finalCount = 0;
                }else if(oppDetailList.Deal_Confirmed_Enrollment__c != null){
                    finalCount = Integer.valueOf(String.valueOf(oppDetailList.Deal_Confirmed_Enrollment__c));
                }
                set<Id> accId= new set<Id>();
                set<Id> MasterOpp= new set<Id>();
                List<Account> childAccounts = new List<Account>();
                if(oppDetailList.MultiSchool_Partition__c != null){
                    parentOppMultiPartitionName = oppDetailList.MultiSchool_Partition__c+'\n';
                    System.debug('the Line 123---->'+parentOppMultiPartitionName);
                }
                
                
                for(OppChildAccWrapper oppAcc:oppChildAccWrapperList){
                    Opportunity opp= new Opportunity();
                    opp.AccountId=oppAcc.accId;
                    accId.add(oppAcc.accId);
                    opp.Deal_Confirmed_Enrollment__c=oppAcc.enrollNum;
                    opp.Name=oppAcc.OppName+ '- Multischool Deal';
                    opp.StageName=oppDetailList.StageName;
                    opp.CloseDate=Date.today();
                    opp.Deal_Organization_Type__c = oppDetailList.Deal_Organization_Type__c;
                    opp.Subscription_Start_Date__c = oppDetailList.Subscription_Start_Date__c;
                    opp.Subscription_End_Date__c = oppDetailList.Subscription_End_Date__c;
                    opp.Contract_Length__c = oppDetailList.Contract_Length__c;
                    opp.Create_Trial__c = oppDetailList.Create_Trial__c;
                    opp.Trial_Period_In_Month__c = oppDetailList.Trial_Period_In_Month__c;
                    opp.Multi_School_opportunity__c = true;
                    opp.Master_Opportunity__c = oppDetailList.Id;
                    opp.Multi_School_W_O_Enrollment__c = true;
                    opp.RecordtypeId = oppDetailList.RecordtypeId;
                    MasterOpp.add(opp.Master_Opportunity__c);
                    childAccounts.add(new Account(Id=oppAcc.accId,Enrollment_Count__c=oppAcc.enrollNum,Subscription_Type__c='Multi-School'));
                    finalCount = finalCount + oppAcc.enrollNum;
                    opps.add(opp);
                    
                    parentOppMultiPartitionName+=oppAcc.OppName+'\n';
                }
                if(finalCount != 0){
                    Opportunity oppDet = new opportunity();
                    oppDet.Id = oppDetailList.Id;
                    //oppDet.Deal_Confirmed_Enrollment__c = finalCount;
                    oppDet.Multi_Scholl_Created__c=true;
                    oppDet.MultiSchool_Partition__c = parentOppMultiPartitionName;
                    System.debug('the Line 278---->'+oppDet.MultiSchool_Partition__c);
                    update oppDet;
                    update childAccounts;
                }
                insert opps;
                
            }
            return JSON.serialize(opps); 
        } catch (Exception e) {
            system.debug('Error Message::'+e.getMessage());
            system.debug('trace::'+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
            
        }
    }
    
    public class OppChildAccWrapper{
        @AuraEnabled public String accId{get;set;}
        @AuraEnabled public Integer enrollNum{get;set;}
        @AuraEnabled public String OppName{get;set;}
    }
    
    
    public class ResponseWrapper{
        @AuraEnabled public List<Account> taggedAccList;
        @AuraEnabled public List<Account> selectedAccList;
        @AuraEnabled public Opportunity opp;
        
        public ResponseWrapper(List<Account> taggedAccList, List<Account> selectedAccList,Opportunity opp){
            this.taggedAccList = taggedAccList;
            this.selectedAccList = selectedAccList;
            this.opp=opp;
        }
    }
    
    public class RequestChildAccWrapper{
        @AuraEnabled public String Id{get;set;}
        @AuraEnabled public Integer enrollment{get;set;}
        @AuraEnabled public String Name{get;set;}
        @AuraEnabled public boolean isEdit{get;set;}
        @AuraEnabled public boolean isDeleted{get;set;}
    }
}