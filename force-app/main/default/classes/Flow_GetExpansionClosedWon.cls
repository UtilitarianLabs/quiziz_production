/*The invocable method in this class is called by the "Opportunity - Expansion Closed Won" flow.
 * The method takes the ID of an expansion opportunity and finds closed won opportunities related to that account
 * and any child accounts with shell opportunities (Multi-School) or all child accounts (District).
 * Tested by ExpansionFlowHandlerTest*/
public class Flow_GetExpansionClosedWon {
    @InvocableMethod(label='Get Current Closed Won Opps' description='Returns a list of current closed won opportunities related to the provided expansion opportunity\'s account ID OR certain children (depending on District or Multi-School expansion)')
    public static List<List<Opportunity>> getCurrentClosedWon(List<Id> expansionOppIdList){
        //map of original opp id to account ids whose renewals should be closed
        Map<Id,List<Id>> oppToAccountIdMap = new Map<Id,List<Id>>();
        //get account id related to provided opp
        Map<Id,Opportunity> expansionOpps = new Map<Id,Opportunity>([SELECT AccountId FROM Opportunity WHERE Id IN :expansionOppIdList]);
        for(Id oppId : expansionOppIdList){
            List<Id> accountIds = new List<Id>();
            Opportunity queriedOpp = expansionOpps.get(oppId);
            accountIds.add(queriedOpp.AccountId);
            oppToAccountIdMap.put(oppId,accountIds);
        }
        
        //find opps where Expansion Opportunity = provided opp [aka shell opps], get their account ids
        List<Opportunity> shellOpps = [SELECT AccountId, Expansion_Opportunity__c FROM Opportunity WHERE Expansion_Opportunity__c IN :expansionOppIdList];
        for(Opportunity shellOpp : shellOpps){
            List<Id> thisAccountIdList = oppToAccountIdMap.get(shellOpp.Expansion_Opportunity__c);
            if(!thisAccountIdList.contains(shellOpp.AccountId)){
                thisAccountIdList.add(shellOpp.AccountId);
            }
            oppToAccountIdMap.put(shellOpp.Expansion_Opportunity__c,thisAccountIdList);
        }
        
        //ONLY IF there are no shell opps for that expansion opp, get all child account ids of the opp's account
        List<Id> districtAccountIdList = new List<Id>();
        for(Id oppId : oppToAccountIdMap.keySet()){
            List<Id> thisAccountIds = oppToAccountIdMap.get(oppId);
            if(thisAccountIds.size() == 1){
                //no shell opps were found, so we want to find all child accounts of the one account in the list (which came from the original expansion opp) 
                districtAccountIdList.add(thisAccountIds[0]);
            }
        }
        List<Account> districtChildAccounts = [SELECT ParentId FROM Account WHERE ParentId IN :districtAccountIdList];
        
        for(Opportunity expansionOpp : expansionOpps.values()){
            List<Id> thisAccountIds = oppToAccountIdMap.get(expansionOpp.Id);
            for(Account districtChildAccount : districtChildAccounts){
                if(districtChildAccount.ParentId == expansionOpp.AccountId){
                    thisAccountIds.add(districtChildAccount.Id);
                }
            }
            oppToAccountIdMap.put(expansionOpp.Id,thisAccountIds);
        }
        List<Id> allAccountIdsToQuery = new List<Id>();
        for(Id oppId : oppToAccountIdMap.keySet()){
            List<Id> thisAccountIds = oppToAccountIdMap.get(oppId);
            for(Id acctId : thisAccountIds){
                allAccountIdsToQuery.add(acctId);
            }
        }
        //now we have a map of original expansion opp ids to all accounts whose current closed won opps should have their dates open, so query the current closed opps
        List<Opportunity> currentClosedOpps = [SELECT AccountId FROM Opportunity WHERE IsWon = TRUE AND AccountId IN :allAccountIdsToQuery AND Subscription_Start_Date__c < TODAY AND Subscription_End_Date__c > TODAY];
        //create map of account id to open renewal(s) so we can associate them with the original opps
        Map<Id,List<Opportunity>> accountIdToClosedWonMap = new Map<Id,List<Opportunity>>();
        for(Opportunity currentClosedOpp : currentClosedOpps){
            List<Opportunity> thisOppList = accountIdToClosedWonMap.containsKey(currentClosedOpp.AccountId) ? accountIdToClosedWonMap.get(currentClosedOpp.AccountId) : new List<Opportunity>();
            thisOppList.add(currentClosedOpp);
            accountIdToClosedWonMap.put(currentClosedOpp.AccountId,thisOppList);
        }
        
        //create our final list to return
        List<List<Opportunity>> returnList = new List<List<Opportunity>>();
        for(Id expansionOppId : expansionOppIdList){
            List<Opportunity> returnClosedWonList = new List<Opportunity>();
            //get list of accounts associated with this opp
            List<Id> thisAccountIdList = oppToAccountIdMap.get(expansionOppId);
            for(Id accountId : thisAccountIdList){
                if(accountIdToClosedWonMap.containsKey(accountId)){
                    returnClosedWonList.addAll(accountIdToClosedWonMap.get(accountId));
                }
                
            }
			returnList.add(returnClosedWonList);       
        }
        
        return returnList;
    }

}