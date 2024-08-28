public class ExpandOpportunityController {
    @AuraEnabled
    public static String createExpansionOpportunity(String oppId){
        try {
            Opportunity thisOpp = [SELECT AccountId, Account.ParentId FROM Opportunity WHERE Id = :oppId];
            Id expRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Multi_School_District').getRecordTypeId();
            Id theAccountId = thisOpp.Account.ParentId != null ? thisOpp.Account.ParentId : thisOpp.AccountId;
            Opportunity newOpp = new Opportunity(
                AccountId = theAccountId,
                Name = 'Expansion Opp',
                RecordTypeId = expRecordTypeId,
                StageName = '1 - Decision Maker Meeting Held',
                CloseDate = Date.today().addDays(60),
                Type = 'Expansion',
                Deal_Organization_Type__c = 'District',
                Expanded_Opportunity__c = oppId,
                Created_from_Expansion__c = true
            );
            insert newOpp;
            updateOpenRenewals(newOpp.Id);

            return newOpp.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String createMultiExpansionOpportunity(String oppId, List<Id> childAccountIds){
        try {
            Opportunity thisOpp = [SELECT AccountId, Account.ParentId FROM Opportunity WHERE Id = :oppId];
            Id expRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Multi_School_District').getRecordTypeId();
            //if the opp's account has a parent (district), assign the expansion opp to the parent.  otherwise, assign to the opp's account
            Id theAccountId = thisOpp.Account.ParentId != null ? thisOpp.Account.ParentId : thisOpp.AccountId;
            //first, create expansion opp for the original account
            Opportunity newOpp = new Opportunity(
                AccountId = theAccountId,
                Name = 'Expansion Opp',
                RecordTypeId = expRecordTypeId,
                StageName = '1 - Decision Maker Meeting Held',
                CloseDate = Date.today().addDays(60),
                Type = 'Expansion',
                Deal_Organization_Type__c = 'Multi-school',
                Expanded_Opportunity__c = oppId,
                Created_from_Expansion__c = true
            );
            insert newOpp;

            //then create a shell opp for all of the selected child accounts
            List<Opportunity> shellOppsToInsert = new List<Opportunity>();
            for(Id childAccountId : childAccountIds){
                Opportunity shellOpp = new Opportunity(
                    AccountId = childAccountId,
                    Name = 'Shell Opp',
                    RecordTypeId = expRecordTypeId,
                    StageName = '1 - Decision Maker Meeting Held',
                    CloseDate = Date.today().addDays(60),
                    Type = 'Expansion',
                    Expansion_Opportunity__c = newOpp.Id,
                    Master_Opportunity__c = newOpp.Id,
                    Created_from_Expansion__c = true
                );
                shellOppsToInsert.add(shellOpp);
                
                
            }
            insert shellOppsToInsert;

            updateOpenRenewals(newOpp.Id);

            return newOpp.Id;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<AccountWrapper> getChildAccounts(String oppId){
        Opportunity thisOpp = [SELECT Id, AccountId, Account.ParentId FROM Opportunity WHERE Id = :oppId];
        Id theAccountId = thisOpp.Account.ParentId != null ? thisOpp.Account.ParentId : thisOpp.AccountId;
        List<Account> childAccounts = [SELECT Name FROM Account WHERE ParentId = :theAccountId];
        List<AccountWrapper> wrapperList = new List<AccountWrapper>();
        for(Account acc : childAccounts){
            wrapperList.add(new AccountWrapper(acc,false));
        }
        return wrapperList;
    }

    //populate the "Expansion Opportunity" lookup on open renewal opps with the provided opportunity ID
    public static void updateOpenRenewals(Id expansionOppId){
        List<List<Opportunity>> openRenewalsList = Flow_GetExpansionRenewals.getOpenRenewals(new List<Id>{expansionOppId});
        if(!openRenewalsList.isEmpty() && !openRenewalsList[0].isEmpty()){
            List<Opportunity> openRenewals = openRenewalsList[0];
            for(Opportunity renewal : openRenewals){
                renewal.Expansion_Opportunity__c = expansionOppId;
            }
            update openRenewals;
        }
    }

    public class AccountWrapper{
        @AuraEnabled public Account account;
        @AuraEnabled public String accountName;
        @AuraEnabled public String accountId;
        @AuraEnabled public Boolean isChecked;
        
        public AccountWrapper(Account theAccount, Boolean thisIsChecked){
            this.account = theAccount;
            this.accountName = theAccount.Name;
            this.accountId = theAccount.Id;
            this.isChecked = thisIsChecked;
        }
    }
}