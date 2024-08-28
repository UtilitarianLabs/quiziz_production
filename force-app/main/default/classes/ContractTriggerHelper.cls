public class ContractTriggerHelper {
    
    public static void createNewSubscriprion(list<contract> contractList,map<id,contract> mapofOldContract){
        map<String,Contract> mapofConIdByCon = new map<String,Contract>();
        list<SBQQ__Subscription__c> subScriptionListTobeUpdate = new list<SBQQ__Subscription__c>();
        list<Opportunity> opprtunityList = new list<Opportunity>();
        map<String,String> mapofConIdByOppId = new map<String,String>();
        map<String,Opportunity> mapOfOppIdByOpp = new map<String,Opportunity>();
        set<String> oppIdSet = new set<String>();
        if(!contractList.isEmpty()){
            for(Contract conDet : contractList){
                if(conDet.Status == 'Activated'){
                    mapofConIdByCon.put(conDet.Id,conDet);
                mapofConIdByOppId.put(conDet.Id,conDet.SBQQ__Opportunity__c);
                oppIdSet.add(conDet.SBQQ__Opportunity__c);
                }
                
            }
            if(!oppIdSet.isEmpty()){
                opprtunityList = [select id,Deal_Organization_Type__c,Contract_Length__c,Create_Pilot__c,Create_Trial__c,Trial_Period_In_Month__c from opportunity where id in: oppIdSet];
                if(!opprtunityList.isEmpty()){
                    for(Opportunity opp : opprtunityList){
                        mapOfOppIdByOpp.put(opp.Id,Opp);
                    }
                }
            }
            subScriptionListTobeUpdate = [select id,SBQQ__SubscriptionStartDate__c,SBQQ__Product__c,SBQQ__Quantity__c,SBQQ__Account__c,SBQQ__Contract__c,SBQQ__SubscriptionType__c,SBQQ__ListPrice__c,SBQQ__SpecialPrice__c,SBQQ__CustomerPrice__c,SBQQ__RegularPrice__c,SBQQ__NetPrice__c,SBQQ__RenewalPrice__c,SBQQ__ProrateMultiplier__c,SBQQ__RenewalQuantity__c from SBQQ__Subscription__c where SBQQ__Contract__c in: mapofConIdByCon.keySet()];
            if(!subScriptionListTobeUpdate.isEmpty()){
                for(SBQQ__Subscription__c subScription : subScriptionListTobeUpdate){
                    subScription.Opportunity__c = mapofConIdByOppId.get(subScription.SBQQ__Contract__c);
                    subScription.SBQQ__SubscriptionStartDate__c = mapofConIdByCon.get(subScription.SBQQ__Contract__c).StartDate;
                    subScription.Product_Type__c = mapOfOppIdByOpp.get(mapofConIdByOppId.get(subScription.SBQQ__Contract__c)).Deal_Organization_Type__c;
                    if(mapOfOppIdByOpp.get(mapofConIdByOppId.get(subScription.SBQQ__Contract__c)).Create_Trial__c){
                        subScription.Contract_Length__c = mapOfOppIdByOpp.get(mapofConIdByOppId.get(subScription.SBQQ__Contract__c)).Contract_Length__c + mapOfOppIdByOpp.get(mapofConIdByOppId.get(subScription.SBQQ__Contract__c)).Trial_Period_In_Month__c;
                    }else{
                        subScription.Contract_Length__c = mapOfOppIdByOpp.get(mapofConIdByOppId.get(subScription.SBQQ__Contract__c)).Contract_Length__c; 
                    }
                    
                    if(mapOfOppIdByOpp.get(mapofConIdByOppId.get(subScription.SBQQ__Contract__c)).Create_Pilot__c){
                        subScription.Subscription_Type__c = 'Pilot';
                    }else{
                        subScription.Subscription_Type__c = 'Paid';
                    }
                }
                UPDATE subScriptionListTobeUpdate;
            }
            
        }
        /*if(!contractList.isEmpty()){
set<string> conIdSet = new set<string>();
map<string,string> mapofContractIdByOppId = new map<String,String>();
for(contract conDet : contractList){
if(conDet.StartDate != null){
//conDet.SBQQ__RenewalForecast__c = true;
conIdSet.add(conDet.Id);
mapofContractIdByOppId.put(conDet.Id,conDet.SBQQ__Opportunity__c);
//SBQQ__Opportunity__c
}
}
list<SBQQ__Subscription__c> subScriptionList = new list<SBQQ__Subscription__c>();
if(!conIdSet.isEmpty()){
list<SBQQ__Subscription__c> subScriptionListTobeInsert = new list<SBQQ__Subscription__c>();
subScriptionList = [select id,SBQQ__Product__c,SBQQ__Quantity__c,SBQQ__Account__c,SBQQ__Contract__c,SBQQ__SubscriptionType__c,SBQQ__ListPrice__c,SBQQ__SpecialPrice__c,SBQQ__CustomerPrice__c,SBQQ__RegularPrice__c,SBQQ__NetPrice__c,SBQQ__RenewalPrice__c,SBQQ__ProrateMultiplier__c,SBQQ__RenewalQuantity__c from SBQQ__Subscription__c where SBQQ__Contract__c in: conIdSet];
//SBQQ__Subscription__c latestSubscription  = subScriptionList[0].clone(false, false, false, false);


for(SBQQ__Subscription__c subScrip : subScriptionList){
SBQQ__Subscription__c newSubScription = new SBQQ__Subscription__c();
newSubScription.SBQQ__Quantity__c  = subScrip.SBQQ__Quantity__c;
newSubScription.SBQQ__RenewalQuantity__c =subScrip.SBQQ__RenewalQuantity__c;
newSubScription.SBQQ__ProrateMultiplier__c =subScrip.SBQQ__ProrateMultiplier__c;
newSubScription.SBQQ__RenewalPrice__c =subScrip.SBQQ__RenewalPrice__c;
newSubScription.SBQQ__NetPrice__c =subScrip.SBQQ__NetPrice__c;
newSubScription.SBQQ__RegularPrice__c =subScrip.SBQQ__RegularPrice__c;
newSubScription.SBQQ__CustomerPrice__c =subScrip.SBQQ__CustomerPrice__c;
newSubScription.SBQQ__SpecialPrice__c =subScrip.SBQQ__SpecialPrice__c;
newSubScription.SBQQ__ListPrice__c =subScrip.SBQQ__ListPrice__c;
//newSubScription.SBQQ__SubscriptionType__c ='Renewable';
newSubScription.SBQQ__Contract__c =subScrip.SBQQ__Contract__c;
newSubScription.SBQQ__Account__c =subScrip.SBQQ__Account__c;
newSubScription.SBQQ__Product__c = subScrip.SBQQ__Product__c;
newSubScription.Opportunity__c = mapofContractIdByOppId.get(newSubScription.SBQQ__Contract__c);
subScriptionListTobeInsert.add(newSubScription);
}
if(!subScriptionList.isEmpty()){
//delete subScriptionList;
}

system.debug('subScriptionListTobeInsert::'+subScriptionListTobeInsert);
//insert subScriptionListTobeInsert;
}
}*/
    }
    
    public static void syncStartDateWithOpportunity(list<contract> contractList,map<id,contract> oldMapContract){
        set<string> opportunityIdTobeUpdate = new set<string>();
        map<string,contract> mapofOppIdByContract = new map<string,contract>();
        for(contract conDetail : contractList){
            if(conDetail.StartDate != null && conDetail.StartDate != oldMapContract.get(conDetail.Id).StartDate){
                opportunityIdTobeUpdate.add(conDetail.SBQQ__Opportunity__c);
                mapofOppIdByContract.put(conDetail.SBQQ__Opportunity__c,conDetail);
            }
        }
        
        if(!opportunityIdTobeUpdate.isEmpty()){
            list<opportunity> oppList = [select id,Subscription_Start_Date__c from opportunity where id in: opportunityIdTobeUpdate];
            
            if(!oppList.isEmpty()){
                for(opportunity oppDetail : oppList){
                    oppDetail.Subscription_Start_Date__c = mapofOppIdByContract.get(oppDetail.Id).StartDate;
                }
                
                update oppList;
            }
        }
    }
    
    public static void createRenewalOpportunity(set<string> contractIdList){
        if(!contractIdList.isEmpty()){
            list<Contract> conTobeUpdate = new list<Contract>();
            for(String conId : contractIdList){
                contract conDet = new Contract();
                conDet.Id = conId;
                conDet.SBQQ__RenewalForecast__c = true;
                conDet.Status = 'Activated';
                conDet.Status = 'Activated';
                conDet.SBQQ__RenewalTerm__c = 12;
                conTobeUpdate.add(conDet);
            }
            
            if(!conTobeUpdate.isEmpty()){
                update conTobeUpdate;
            }
        }
    }
    
    public static void createRenewalQuote(List<contract> contractList,map<Id,Contract> contractOldmap){
        for(Contract con : contractList){
            if(con.SBQQ__RenewalOpportunity__c != null && con.SBQQ__RenewalOpportunity__c != contractOldmap.get(con.Id).SBQQ__RenewalOpportunity__c){
                con.SBQQ__RenewalQuoted__c = true;
            }
        }
    }
    
    public static void regenrateQuote(List<contract> contractList,map<Id,Contract> contractOldmap){
        set<string> renewalOppId = new set<String>();
        for(contract con : contractList){
            if(con.SBQQ__RenewalQuoted__c && con.SBQQ__RenewalQuoted__c != contractOldmap.get(con.id).SBQQ__RenewalQuoted__c){
                renewalOppId.add(con.SBQQ__RenewalOpportunity__c);
            }
        }
        if(!renewalOppId.isEmpty()){
            List<Opportunity> renewalOppoList = [select id,Deal_Organization_Type__c from opportunity where id in: renewalOppId];
            
            for(opportunity opp : renewalOppoList){
                //if(opp.Deal_Organization_Type__c == 'Department'){
                opportunityTrigger_Helper.calculateQuotation(opp.Id,0);
                //}
            }
        }
    }
    
    public static void mapMulChildOpportunity(List<Contract> contractList,Map<Id,Contract> oldContractMap){
        Set<String> renewalOppIdSet = new Set<String>();
        List<Opportunity> renealOpportunityList = new List<Opportunity>();
        for(Contract con : contractList){
            if(Con.SBQQ__RenewalQuoted__c && con.SBQQ__RenewalQuoted__c != oldContractMap.get(con.Id).SBQQ__RenewalQuoted__c){
                renewalOppIdSet.add(con.SBQQ__RenewalOpportunity__c);
            }
        }
        if(!renewalOppIdSet.isEmpty()){
            renealOpportunityList = [Select id,Multi_Scholl_Created__c,Parent_Opportunity__c,StageName,RecordtypeId,ownerId from Opportunity where id in: renewalOppIdSet];
            
            if(!renealOpportunityList.isEmpty()){
                opportunityTrigger_Helper.tagChildRenewal(renealOpportunityList);
            }
        }
    }
    
    public static void validateContractCreation(List<Contract> newContractList){
        List<Opportunity> oppListTobeUpdate = new List<Opportunity>();
        Set<String> oppIdSet = new Set<String>();
        for(Contract con : newContractList){
            oppIdSet.add(con.SBQQ__Opportunity__c);
        }
        
        for(String str : oppIdSet){
            Opportunity oppDet = new Opportunity();
            oppDet.Id = str;
            oppDet.Is_Contract_Created__c = true;
            oppListTobeUpdate.add(oppDet);
        }
        
        if(!oppListTobeUpdate.isEmpty()){
            update oppListTobeUpdate;
        }
    }
    
    public static void tagRenewalOppToParent(List<Contract> contractList,Map<Id,Contract> oldContractMap){
        Map<String,String> mapofParentOppIdByRenewalId = new Map<String,String>();
        for(Contract con : contractList){
            if(con.SBQQ__RenewalOpportunity__c != null && con.SBQQ__RenewalOpportunity__c != oldContractMap.get(con.Id).SBQQ__RenewalOpportunity__c){
                mapofParentOppIdByRenewalId.put(con.SBQQ__Opportunity__c,con.SBQQ__RenewalOpportunity__c);
            }
        }
        
        if(!mapofParentOppIdByRenewalId.isEmpty()){
            Utility.tagOppportunityToParentId(mapofParentOppIdByRenewalId);
        }
    }
    
    public static void mapContractEndDate(List<Contract> conList){
        set<String> conIdSet = New set<String>();
        for(Contract con : conList){
            conIdSet.add(con.Id);
        }
        if(!conIdSet.isEmpty()){
            List<Contract> conListTobeUpdate = [select id,SBQQ__Opportunity__r.Subscription_End_Date__c from Contract where id in: conIdSet];
            Map<String,Contract> mapofConIdByContract = New Map<String,Contract>();
            for(Contract con : conListTobeUpdate){
                mapofConIdByContract.put(con.id,con);
            }
            
            for(contract con : conList){
                if(mapofConIdByContract.get(con.Id) != null && mapofConIdByContract.get(con.Id).SBQQ__Opportunity__r.Subscription_End_Date__c != null){
                    con.EndDate = mapofConIdByContract.get(con.Id).SBQQ__Opportunity__r.Subscription_End_Date__c;
                }
                
            }
            
        }
    }
}