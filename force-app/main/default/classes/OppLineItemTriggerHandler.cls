public class OppLineItemTriggerHandler {
    //public static decimal slabPrice = '';
    public static boolean isBeforeInsertTrigger = true;
    public static boolean isAfterInsertTrigger = true;
    public static boolean isBeforeUpdateTrigger = true;
    public static boolean isAfterUpdateTrigger = true;
    
    
    
    
    
    public static void recalculateOppItemStatDate(list<OpportunityLineItem> oppLineItems){
        set<string> opportunityIdSet = new set<string>();
        Set<Id> productIdSet = new Set<Id>();
        map<string,list<OpportunityLineItem>> mapofOppByOppItem = new map<string,list<OpportunityLineItem>>();
        for(OpportunityLineItem oppLineItem : oppLineItems){
            system.debug('oppLineItem::'+oppLineItem);
            system.debug('oppLineItem.Subscription_Start_Date__c::'+oppLineItem.Subscription_Start_Date__c);
            productIdSet.add(oppLineItem.Product2Id);
            if(oppLineItem.Subscription_Start_Date__c == null){
                opportunityIdSet.add(oppLineItem.opportunityId);
                if(mapofOppByOppItem.containsKey(oppLineItem.opportunityId)){
                    mapofOppByOppItem.get(oppLineItem.opportunityId).add(oppLineItem);
                }else{
                    mapofOppByOppItem.put(oppLineItem.opportunityId,new list<OpportunityLineItem>{oppLineItem});
                }
            }
        }
        
        if(!opportunityIdSet.isEmpty()){
            opportunity oppDetails = [select id,Add_Additional_Period__c,Additiona_Period_Date__c,Promo_Free_Period__c,Promo_Free_Period_End_Date__c,Deal_Confirmed_Enrollment__c,Slab_Prize__c,Subscription_Start_Date__c,Create_Pilot__c,Pilot_Period__c,create_trial__c,Trial_Period_In_Month__c,Contract_Length__c from opportunity where id in:opportunityIdSet];
            system.debug('oppDetails::'+oppDetails);
            Map<Id,Product2> productDetailsMap = new Map<Id,Product2>([SELECT Id, SBQQ__SubscriptionType__c FROM Product2 WHERE Id IN :productIdSet]);
            if(oppDetails != null){
                for(OpportunityLineItem oppLine : mapofOppByOppItem.get(oppDetails.Id)){
                    //Update by Iceberg RevOps 2023-01-09: Quantity is not set to Deal Confirmed Enrollment if the product's Subscription Type = One-time
                    Product2 productDetails = productDetailsMap.get(oppLine.Product2Id);
                    if(oppDetails.Deal_Confirmed_Enrollment__c != oppLine.quantity /*&& productDetails.SBQQ__SubscriptionType__c != 'One-time'*/){
                        oppLine.quantity = oppDetails.Deal_Confirmed_Enrollment__c;
                    }
                    if(oppDetails.create_trial__c && oppDetails.Trial_Period_In_Month__c > 0){
                        if(oppLine.unitprice == 0){
                            oppLine.Subscription_Start_Date__c = oppDetails.Subscription_Start_Date__c;
                            oppLine.Subscription_End_Date__c = oppDetails.Subscription_Start_Date__c.addMonths(integer.valueOf(String.valueOf(oppDetails.Trial_Period_In_Month__c))) - 1;
                            oppLine.Slab_Price__c = 0;
                        }
                    }
                }
                for(OpportunityLineItem oppLine : mapofOppByOppItem.get(oppDetails.Id)){
                    //Update by Iceberg RevOps 2023-01-09: Quantity is not set to Deal Confirmed Enrollment if the product's Subscription Type = One-time
                    Product2 productDetails = productDetailsMap.get(oppLine.Product2Id);
                    if(oppDetails.Deal_Confirmed_Enrollment__c != oppLine.quantity /*&& productDetails.SBQQ__SubscriptionType__c != 'One-time'*/){
                        oppLine.quantity = oppDetails.Deal_Confirmed_Enrollment__c;
                    }
                    if(oppDetails.Create_Pilot__c){
                        if(oppLine.unitprice == 0){
                            oppLine.Slab_Price__c = 0;
                            oppLine.Subscription_Start_Date__c = oppDetails.Subscription_Start_Date__c;
                            oppLine.Subscription_End_Date__c = oppDetails.Subscription_Start_Date__c.addMonths(integer.valueOf(String.valueOf(oppDetails.Pilot_Period__c))) - 1;
                        }
                    }
                }
                for(OpportunityLineItem oppLine : mapofOppByOppItem.get(oppDetails.Id)){
                    //Update by Iceberg RevOps 2023-01-09: Quantity is not set to Deal Confirmed Enrollment if the product's Subscription Type = One-time
                    Product2 productDetails = productDetailsMap.get(oppLine.Product2Id);
                    if(oppDetails.Deal_Confirmed_Enrollment__c != oppLine.quantity /*&& productDetails.SBQQ__SubscriptionType__c != 'One-time'*/){
                        oppLine.quantity = oppDetails.Deal_Confirmed_Enrollment__c;
                    }
                    if(oppLine.unitprice != 0){
                        if(oppDetails.Slab_Prize__c != null && oppDetails.Slab_Prize__c != oppLine.Slab_Price__c){
                            oppLine.Slab_Price__c = oppLine.Slab_Price__c;
                        }
                        if(oppDetails.create_trial__c){
                            oppLine.Subscription_Start_Date__c = oppDetails.Subscription_Start_Date__c.addMonths(integer.valueOf(String.valueOf(oppDetails.Trial_Period_In_Month__c)));
                            oppLine.Subscription_End_Date__c = oppDetails.Subscription_Start_Date__c.addMonths(integer.valueOf(String.valueOf(oppDetails.Contract_Length__c)) + integer.valueOf(String.valueOf(oppDetails.Trial_Period_In_Month__c))) - 1;
                        }else if(oppDetails.Add_Additional_Period__c && oppDetails.Additiona_Period_Date__c != null){
                            oppLine.Subscription_Start_Date__c = oppDetails.Subscription_Start_Date__c;
                            oppLine.Subscription_End_Date__c = oppDetails.Additiona_Period_Date__c;
                        }else if(oppDetails.Promo_Free_Period__c && oppDetails.Promo_Free_Period_End_Date__c != null){
                            //Update 2023-03-15 by Iceberg RevOps: set subscription end date from opp's Promo Free Period End Date
                            oppLine.Subscription_Start_Date__c = oppDetails.Subscription_Start_Date__c;
                            oppLine.Subscription_End_Date__c = oppDetails.Promo_Free_Period_End_Date__c;
                        }else{
                            oppLine.Subscription_Start_Date__c = oppDetails.Subscription_Start_Date__c;
                            oppLine.Subscription_End_Date__c = oppDetails.Subscription_Start_Date__c.addMonths(integer.valueOf(String.valueOf(oppDetails.Contract_Length__c))) - 1;
                        }
                        
                        //oppLine.Subscription_End_Date__c = oppDetails.Subscription_Start_Date__c.addMonths(integer.valueOf(String.valueOf(oppDetails.Contract_Length__c))) - 1;
                    }
                }
            }
        }
    }
    
    public static void recalculateUnitPrizeOnSlabPrizeChange(List<OpportunityLineItem> newOppLineItem,map<Id,OpportunityLineItem> oldMapOpportunity){
        Integer subScriptionYear = 0;
        list<Opportunity> oppDetailsTobeUpdate = new list<Opportunity>();
        for(OpportunityLineItem oppDet : newOppLineItem){
            if((oppDet.Slab_Price__c != null && oppDet.Slab_Price__c != oldMapOpportunity.get(oppDet.Id).Slab_Price__c)){
                system.debug('oppProd.Slab_Price__c::'+oppDet.Slab_Price__c);
                opportunityTrigger_Helper.calculateQuotation(oppDet.OpportunityId,oppDet.Slab_Price__c);
            }
        }
    }
    
    public static void addSlabPriceToOppLineItem(list<opportunityLineItem> renewalOpportunityLineItem){
        set<String> oppIdSet = new set<String>();
        set<String> productCode = new set<String>();
        map<String,List<OpportunityLineItem>> mapofOppIdbyOppLineItem = new map<String,List<OpportunityLineItem>>();
        map<String,List<string>> mapofPaidProdCodeByOppId = new map<String,List<string>>();
        map<String,Opportunity> maoofOppidByOpp = new map<String,Opportunity>();
        for(opportunityLineItem oppLineItem : renewalOpportunityLineItem){
            oppIdSet.add(oppLineItem.OpportunityId);
            if(mapofOppIdbyOppLineItem.containsKey(oppLineItem.OpportunityId)){
                mapofOppIdbyOppLineItem.get(oppLineItem.OpportunityId).add(oppLineItem);
            }else{
                mapofOppIdbyOppLineItem.put(oppLineItem.OpportunityId,new list<OpportunityLineItem>{oppLineItem});
            }
        }
        
        if(!oppIdSet.isEmpty()){
            list<Opportunity> oppDetList = [select id,Add_Additional_Period__c,Additiona_Period_Date__c,Promo_Free_Period__c,Promo_Free_Period_End_Date__c,SBQQ__Renewal__c,Multi_School_opportunity__c,Deal_Organization_Type__c,Deal_Confirmed_Enrollment__c,Subscription_Start_Date__c,Subscription_End_Date__c from Opportunity where id in: oppIdSet];
            if(!oppDetList.isEmpty()){
                for(Opportunity opp : oppDetList){
                    productCode.add(opp.Deal_Organization_Type__c);
                    maoofOppidByOpp.put(opp.Id,opp);
                    if(mapofPaidProdCodeByOppId.containsKey(opp.Deal_Organization_Type__c)){
                        mapofPaidProdCodeByOppId.get(opp.Deal_Organization_Type__c).add(opp.Id);
                    }else{
                        mapofPaidProdCodeByOppId.put(opp.Deal_Organization_Type__c,new list<string>{opp.Id});
                    }
                }
                
                if(!productCode.isEmpty()){
                    list<SBQQ__BlockPrice__c> prodBlockPriceList = [select id,SBQQ__LowerBound__c,SBQQ__UpperBound__c,SBQQ__Price__c,SBQQ__OriginalBlockPrice__r.SBQQ__Product__c,SBQQ__OriginalBlockPrice__r.SBQQ__Product__r.Quote_Line_Types__c,SBQQ__OriginalBlockPrice__r.SBQQ__Product__r.ProductCode from SBQQ__BlockPrice__c where SBQQ__OriginalBlockPrice__r.SBQQ__Product__r.ProductCode in: productCode and SBQQ__OriginalBlockPrice__r.Pricing_Period__c =: 12];
                    if(!prodBlockPriceList.isEmpty()){
                        for(String mapKey : mapofPaidProdCodeByOppId.keySet()){
                            for(String oppId : mapofPaidProdCodeByOppId.get(mapKey)){
                                for(SBQQ__BlockPrice__c blockPrice : prodBlockPriceList){
                                    if(maoofOppidByOpp.get(oppId).SBQQ__Renewal__c && !maoofOppidByOpp.get(oppId).Multi_School_opportunity__c && maoofOppidByOpp.get(oppId).Deal_Confirmed_Enrollment__c >= blockPrice.SBQQ__LowerBound__c && maoofOppidByOpp.get(oppId).Deal_Confirmed_Enrollment__c <  blockPrice.SBQQ__UpperBound__c){
                                        mapofOppIdbyOppLineItem.get(oppId)[0].UnitPrice = blockPrice.SBQQ__Price__c;
                                        //mapofOppIdbyOppLineItem.get(oppId)[0].Slab_Price__c = 1500;
                                        mapofOppIdbyOppLineItem.get(oppId)[0].Slab_Price__c = blockPrice.SBQQ__Price__c;
                                        mapofOppIdbyOppLineItem.get(oppId)[0].Subscription_Start_Date__c = maoofOppidByOpp.get(oppId).Subscription_Start_Date__c;
                                        if(maoofOppidByOpp.get(oppId).Add_Additional_Period__c && maoofOppidByOpp.get(oppId).Additiona_Period_Date__c != null){
                                            mapofOppIdbyOppLineItem.get(oppId)[0].Subscription_End_Date__c = maoofOppidByOpp.get(oppId).Additiona_Period_Date__c;
                                        }else if(maoofOppidByOpp.get(oppId).Promo_Free_Period__c && maoofOppidByOpp.get(oppId).Promo_Free_Period_End_Date__c != null){
                                            //Update 2023-03-15 by Iceberg RevOps: set end date from opp's Promo Free Period End Date
                                            mapofOppIdbyOppLineItem.get(oppId)[0].Subscription_End_Date__c = maoofOppidByOpp.get(oppId).Promo_Free_Period_End_Date__c;
                                        }else{
                                            mapofOppIdbyOppLineItem.get(oppId)[0].Subscription_End_Date__c = maoofOppidByOpp.get(oppId).Subscription_End_Date__c;
                                        }
                                        
                                    }else{
                                        //mapofOppIdbyOppLineItem.get(oppId)[0].Slab_Price__c = 1500;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        system.debug('renewalOpportunityLineItem::'+renewalOpportunityLineItem);
    }
    
    public static void addEndDate(list<OpportunityLineItem> oppLineItemsList){
        set<Id> oppIdSet = new Set<Id>();
        for(OpportunityLineItem oppLineItem : oppLineItemsList){
            oppIdSet.add(oppLineItem.OpportunityId);
        }
        
        if(!oppIdSet.isEmpty()){
            List<Opportunity> oppList = [select id,Additiona_Period_Date__c,Add_Additional_Period__c, Promo_Free_Period__c, Promo_Free_Period_End_Date__c from opportunity where id in: oppIdSet];
            Map<Id,Opportunity> mapofOppIdbyOpp = new Map<Id,Opportunity>();
            for(opportunity opp : oppList){
                mapofOppIdbyOpp.put(opp.Id,opp);
            }
            for(OpportunityLineItem oppLineItem : oppLineItemsList){
                if(mapofOppIdbyOpp.get(oppLineItem.OpportunityId).Add_Additional_Period__c && mapofOppIdbyOpp.get(oppLineItem.OpportunityId).Additiona_Period_Date__c != null && oppLineItem.UnitPrice !=0){
                    oppLineItem.Subscription_End_Date__c = mapofOppIdbyOpp.get(oppLineItem.OpportunityId).Additiona_Period_Date__c;
                }else if(mapofOppIdbyOpp.get(oppLineItem.OpportunityId).Promo_Free_Period__c && mapofOppIdbyOpp.get(oppLineItem.OpportunityId).Promo_Free_Period_End_Date__c != null && oppLineItem.UnitPrice !=0){
                    //Update 2023-03-15 by Iceberg RevOps: set end date from opp's Promo Free Period End Date
                    oppLineItem.Subscription_End_Date__c = mapofOppIdbyOpp.get(oppLineItem.OpportunityId).Promo_Free_Period_End_Date__c;
                }
            }
        }
        
    }
    
    public static void validateDuplicateDepartmentType(list<OpportunityLineItem> oppLineItems,Map<Id,OpportunityLineItem> oldOpportunityLineItemMap){
        List<String> DepartmentTypeList = new list<String>();
        Set<String> oppIdSet = new set<String>();
        
        for(OpportunityLineItem oppLineItem : oppLineItems){
            if(oppLineItem.ProductCode == 'Department'){
                oppIdSet.add(oppLineItem.OpportunityId); 
            }
            
        }
        
        if(!oppIdSet.isEmpty()){
            List<OpportunityLineItem> oppLineItemList = [select id,Department_Type__c from OpportunityLineItem where opportunityId in : oppIdSet];
            for(OpportunityLineItem oppLine : oppLineItemList){
                if(oppLine.Department_Type__c != null && oldOpportunityLineItemMap.get(oppLine.Id) != null && oldOpportunityLineItemMap.get(oppLine.Id).Department_Type__c != oppLine.Department_Type__c){
                    DepartmentTypeList.add(oppLine.Department_Type__c);
                }
                
            }
        }
        system.debug('DepartmentTypeList::'+DepartmentTypeList);
        for(OpportunityLineItem oppLineItem : oppLineItems){
            if(oppLineItem.Department_Type__c != null){
                system.debug('oppLineItem.Department_Type__c::'+oppLineItem.Department_Type__c);
                system.debug('Inside null condition');
                if(DepartmentTypeList.contains(oppLineItem.Department_Type__c)){
                    oppLineItem.Department_Type__c.addError('You Can Not Select Duplicate Department Type. Kindly Select Different Department Type.');
                }else{
                    oppLineItem.Description = oppLineItem.Department_Type__c;
                    DepartmentTypeList.add(oppLineItem.Department_Type__c);
                }
            }
            
        }
    }
    
    public static void validatequantityfordepartment(list<OpportunityLineItem> oppLineItems){
        for(OpportunityLineItem oppLineItem : oppLineItems){
            if(oppLineItem.ProductCode == 'Department'){
                oppLineItem.Quantity = 1;
            }
        }
    }
    
    public static void updateSlalPriceonDiscount(list<OpportunityLineItem> oppLineItems,map<Id,OpportunityLineItem> oldMap){
        for(OpportunityLineItem oppLine : oppLineItems){
            if(oppLine.Slab_Discount__c != null && oppLine.Slab_Discount__c != 0 && oppLine.Slab_Discount__c != oldMap.get(oppLine.Id).Slab_Discount__c){
                oppLine.Slab_Price__c = oppLine.Slab_Price__c - oppLine.Slab_Price__c * oppLine.Slab_Discount__c/100;
            }
            
            
        }
    }
}