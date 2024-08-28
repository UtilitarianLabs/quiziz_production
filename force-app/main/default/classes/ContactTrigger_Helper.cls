public class ContactTrigger_Helper {

    public static void setCSOwner(List<Contact> contactList){
        set<Id> contactAccountIds=new set<Id>();
        
        for(Contact cont:contactList){
            if(cont.Admin_Contact__c || cont.Billing_Contact__c){
                contactAccountIds.add(cont.AccountId);
            }
        }
        List<Account> accounts=[SELECT Id, Customer_Success__c,ownerId FROM Account WHERE Id IN : contactAccountIds];
        for(Account acc:accounts){
            for(Contact cont:contactList){
                if(cont.AccountId==acc.Id){
                    cont.ownerId=acc.Customer_Success__c;
                    cont.Sales_Owner__c = acc.ownerId;
                }
            }
        }
    }

   public static void createOppContactRolesOnMasterOpp(List<Contact> contactsList){
        if(!contactsList.isEmpty()){
            set<Id> accountIds=new set<Id>();
            for(Contact cont:contactsList){
                if(cont.AccountId!=null){
                    accountIds.add(cont.AccountId);
                }
            }
            set<Id> accIds=new set<Id>();
            List<Account> accountsList=[SELECT Id, Name, (SELECT Id  FROM Contacts) FROM Account WHERE Id =:accountIds];
            for(Account acc:accountsList){
                if(acc.Contacts.size()==1){
                    accIds.add(acc.Id);
                }
            }
            List<Contact> contList=[SELECT Id,AccountId FROM Contact WHERE AccountId IN : accIds];
            List<Opportunity> oppsList=[SELECT Id,AccountID FROM Opportunity WHERE Master_Opportunity__c=null AND AccountID IN : accIds] ;
            List<OpportunityContactRole> oppContacts=new List<OpportunityContactRole>();
            for(Id accId:accIds){
                for(Opportunity opp:oppsList){
                    if(opp.AccountId==accId){
                        for(Contact cont:contList){
                            if(cont.AccountId==accId){
                                OpportunityContactRole oppCont=new OpportunityContactRole();
                                oppCont.ContactId=cont.Id;
                                oppCont.OpportunityId=opp.Id;
                                oppContacts.add(oppCont);
                            }
                        }
                    }
                }
            }
            insert oppContacts;
        }
    }
    public static void mapContactToopportunityContactRoles(List<Contact> contactList){
        if(!contactList.isEmpty()){
            set<String> setofAccId = new set<String>();
            set<String> setOfConId = new set<String>();
            map<string,Contact> mapOfConIdByContact = new map<String,Contact>();
            list<Opportunity> renewalOpportunityList = new list<Opportunity>();
            list<OpportunityContactRole> oppConRoleTobeUpsert = new list<OpportunityContactRole>();
            for(Contact con : contactList){
                setofAccId.add(con.AccountId);
                setOfConId.add(con.id);
                mapOfConIdByContact.put(con.Id,con);
            }
            system.debug('setOfConId::'+setOfConId);
            if(!setofAccId.isEmpty()){
                renewalOpportunityList = [select id,SBQQ__Renewal__c,AccountId,(select id,OpportunityId,Sales_User__c,Role,ContactId,Customer_Success__c from OpportunityContactRoles) from opportunity where AccountId in: setofAccId];
                for(Opportunity opp : renewalOpportunityList){
                    oppConRoleTobeUpsert.addAll(opp.OpportunityContactRoles);
                }

                if(!setOfConId.isEmpty()){
                    set<string> setOfContactRolesId = new set<String>();
                    set<string> contactIdSetTobeCreate = new set<String>();
                        for(OpportunityContactRole oppConRoles : oppConRoleTobeUpsert){
                            setOfContactRolesId.add(oppConRoles.ContactId);
                        }

                            for(String str : setOfConId){
                                if(!setOfContactRolesId.contains(str)){
                                    contactIdSetTobeCreate.add(str);
                                }
                            }

                            system.debug('contactIdSetTobeCreate::'+contactIdSetTobeCreate);
                            if(!contactIdSetTobeCreate.isEmpty()){
                                for(string str : contactIdSetTobeCreate){
                                    for(Opportunity oppDet : renewalOpportunityList){
                                        OpportunityContactRole oppConRole = new OpportunityContactRole();
                                        oppConRole.ContactId = str;
                                        oppConRole.OpportunityId = oppDet.Id;
                                        if(mapOfConIdByContact.get(str).Admin_Contact__c){
                                            oppConRole.Role='Admin User';
                                        }else if(mapOfConIdByContact.get(str).Billing_Contact__c){
                                            oppConRole.Role='Billing User';
                                        }else{
                                            oppConRole.Role='Business User';
                                        }

                                        oppConRoleTobeUpsert.add(oppConRole);
                                    }
                                    system.debug('oppConRoleTobeUpsert::'+oppConRoleTobeUpsert);
                                    if(!oppConRoleTobeUpsert.isEmpty()){
                                        upsert oppConRoleTobeUpsert;
                                    }

                                }
                            }
                }
            }
        }
    }
}