public class TriggerOnOppContactRole {
    public static void attachCSTeamMember(list<OpportunityContactRole> oppContactList){
        if(!oppContactList.isEmpty()){
            set<String> oppIdSet = new set<String>();
            for(OpportunityContactRole oppContactRole : oppContactList){
                if(oppContactRole.Customer_Success__c == null){
                    oppIdSet.add(oppContactRole.OpportunityId);
                }
            }
            
            if(!oppIdSet.isEmpty()){
                list<Opportunity> oppList = [SELECT id,Account.Customer_Success__c from opportunity where id in: oppIdSet];
                if(!oppList.isEmpty()){
                    map<String,String> mapofOppIdByCSId = new map<String,String>();
                    for(Opportunity opp : oppList){
                       mapofOppIdByCSId.put(opp.Id,opp.Account.Customer_Success__c); 
                    }
                    
                    for(OpportunityContactRole oppContactRole : oppContactList){
                        if(oppContactRole.Customer_Success__c == null &&  mapofOppIdByCSId.get(oppContactRole.OpportunityId) != null){
                            oppContactRole.Customer_Success__c = mapofOppIdByCSId.get(oppContactRole.OpportunityId);
                        }
                    }
                }
            }
        }
    }
}