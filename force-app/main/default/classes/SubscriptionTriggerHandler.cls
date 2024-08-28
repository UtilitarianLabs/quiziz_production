public class SubscriptionTriggerHandler {
    
    public static void tagsubScriptiontoSchool(Set<Id> subScriptionId){
        list<SBQQ__Subscription__c> subScriptionList = [select id,SBQQ__EndDate__c,SBQQ__Product__c,Product_Type__c,SBQQ__QuoteLine__c,SBQQ__RenewalPrice__c,SBQQ__SubscriptionEndDate__c,SBQQ__SubscriptionStartDate__c,Grace_Period_In_days__c,Subscription_Type__c,Contract_Length__c,SBQQ__StartDate__c,Opportunity__c,SBQQ__Contract__c from SBQQ__Subscription__c where id in : subScriptionId];
        if(!subScriptionList.isEmpty()){
            set<string> opportunityIdSet = new set<string>();
            map<string,SBQQ__Subscription__c> mapofOppIdBySubscriptionDetails = new map<string,SBQQ__Subscription__c>();
            list<Multischool_Subscription__c> mulSubtobeInsert = new list<Multischool_Subscription__c>();
            list<String> contractIdList = new list<String>();
            for(SBQQ__Subscription__c subScription : subScriptionList){
                if(subScription.Opportunity__c != null){
                    mapofOppIdBySubscriptionDetails.put(subScription.Opportunity__c,subScription);
                    opportunityIdSet.add(subScription.Opportunity__c);
                    contractIdList.add(subScription.SBQQ__Contract__c);
                }
                system.debug('contractIdList::'+contractIdList);
                if(!opportunityIdSet.isEmpty()){
                    list<opportunity> opportunityList = [select id,Master_Opportunity__c,Multi_School_opportunity__c,Deal_Confirmed_Enrollment__c,AccountId from opportunity where Master_Opportunity__c in: opportunityIdSet];
                    if(!opportunityList.isEmpty()){
                        for(opportunity oppDetail : opportunityList){
                            Multischool_Subscription__c mulSchoolSub = new Multischool_Subscription__c();
                            mulSchoolSub.Account__c = oppDetail.AccountId;
                            
                            if(mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).SBQQ__EndDate__c !=null){
                                mulSchoolSub.End_Date__c = mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).SBQQ__EndDate__c;
                            }
                            if(mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).SBQQ__Product__c !=null){
                                mulSchoolSub.Product__c = mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).SBQQ__Product__c;
                            }
                            if(oppDetail.Deal_Confirmed_Enrollment__c !=null){
                                mulSchoolSub.Quantity__c = oppDetail.Deal_Confirmed_Enrollment__c;
                            }
                            if(mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).SBQQ__StartDate__c !=null){
                                mulSchoolSub.Start_Date__c = mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).SBQQ__StartDate__c;
                            }
                            if(mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).SBQQ__QuoteLine__c !=null){
                                mulSchoolSub.Quote_Line__c =  mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).SBQQ__QuoteLine__c;
                            }
                            if(mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).Product_Type__c !=null){
                                mulSchoolSub.Product_Type__c =  mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).Product_Type__c;
                            }
                            if(mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).Contract_Length__c !=null){
                                mulSchoolSub.Contract_Length__c = mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).Contract_Length__c;
                            }
                            if(mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).Subscription_Type__c !=null){
                                mulSchoolSub.Subscription_Type__c =  mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).Subscription_Type__c;
                            }
                            if(mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).Grace_Period_In_days__c !=null){
                                mulSchoolSub.Grace_Period_In_days__c = mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).Grace_Period_In_days__c;
                            }
                            /*if(mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).SBQQ__Contract__c !=null){
mulSchoolSub.Contract__c = mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).SBQQ__Contract__c;
}*/
                            if(mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).SBQQ__StartDate__c !=null){
                                mulSchoolSub.Start_Date__c = mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).SBQQ__StartDate__c;
                            }
                            if(mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).SBQQ__EndDate__c !=null){
                                mulSchoolSub.End_Date__c = mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).SBQQ__EndDate__c;
                            }
                            if(mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).SBQQ__SubscriptionEndDate__c !=null){
                                mulSchoolSub.Subscription_End_Date__c = mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).SBQQ__SubscriptionEndDate__c;
                            }
                            if(mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).SBQQ__RenewalPrice__c !=null){
                                mulSchoolSub.Renewal_Price__c = mapofOppIdBySubscriptionDetails.get(oppDetail.Master_Opportunity__c).SBQQ__RenewalPrice__c;
                            }
                            mulSchoolSub.Opportunity__c = oppDetail.Id;
                            mulSubtobeInsert.add(mulSchoolSub);
                        }
                        
                        if(!mulSubtobeInsert.isEmpty()){
                            insert mulSubtobeInsert;
                        }
                    }
                }
            }
        }
    }
    
    public static void triggerBackendAPI(List<SBQQ__Subscription__c> subScriptionList){
        Set<Id> oppIdSet = new Set<Id>();
        for(SBQQ__Subscription__c subDet : subScriptionList){
            if(subDet.Opportunity__c != null){
                oppIdSet.add(subDet.Opportunity__c);
            }
        }
        
        if(!oppIdSet.isEmpty()){
            CallOut_SubscriptionDetail.subscriptionCallOutToQuizizz(oppIdSet);
        }
    }
    
    public static void triggerBackendAPIForMultiSchool(List<Multischool_Subscription__c> subScriptionList){
        Set<Id> oppIdSet = new Set<Id>();
        for(Multischool_Subscription__c subDet : subScriptionList){
            if(subDet.Opportunity__c != null){
                oppIdSet.add(subDet.Opportunity__c);
            }
        }
        
        if(!oppIdSet.isEmpty()){
            CallOut_SubscriptionDetail.subscriptionCallOutToQuizizz(oppIdSet);
        }
    }
}