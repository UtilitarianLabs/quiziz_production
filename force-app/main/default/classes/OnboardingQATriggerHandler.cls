public without sharing class OnboardingQATriggerHandler {
    public static void mapBillingEmailToOppAcc(List<OnBoarding_QAs__c> onboardingQAList){
        if(!onboardingQAList.isEmpty()){
            String adminEmail = '';
            String BillingEmail = '';
            String lmsData = '';
            String itEmail = '';
            set<String> onboardingId = new set<String>();
            list<Customer_OnBoarding__c> customerOnboarding = new list<Customer_OnBoarding__c>();
            for(OnBoarding_QAs__c onboardQA : onboardingQAList){
                onboardingId.add(onboardQA.Customer_OnBoarding__c);
                if(onboardQA.Question__c != null && onboardQA.Question__c.contains('Admin')){
                    adminEmail = onboardQA.Answer__c;
                }

                if(onboardQA.Question__c != null && onboardQA.Question__c.contains('Billing')){
                    BillingEmail = onboardQA.Answer__c;
                }
                if(onboardQA.Question__c != null && onboardQA.Question__c.contains('IT Contact Email')){
                    itEmail = onboardQA.Answer__c;
                }
                if(onboardQA.Question__c != null && onboardQA.Question__c.contains('LMS')){
                    lmsData = onboardQA.Answer__c;
                }
            }
            system.debug('adminEmail::'+adminEmail);
            system.debug('BillingEmail::'+BillingEmail);
            system.debug('onboardingId::o'+onboardingId);
            
            if(!onboardingId.isEmpty()){
                set<String> setofAccId = new set<String>();
                customerOnboarding = [select id,Account__c from Customer_OnBoarding__c where id in: onboardingId];
                system.debug('customerOnboarding::'+customerOnboarding);
                for(Customer_OnBoarding__c custOnboard : customerOnboarding){
                    system.debug('Inside accis:::');
                    setofAccId.add(custOnboard.Account__c);
                    system.debug('setofAccId::'+setofAccId);
                }
                system.debug('setofAccId::'+setofAccId);
                if(!setofAccId.isEmpty()){
                    list<Account> accListTobeUpdate = [select id,Billing_Accounts_Receivable_Email_Addres__c,Admin_User_Email_Address__c,IT_Contact__c,LMS__c from account where Id in: setofAccId];
                    for(Account acc : accListTobeUpdate){
                        acc.Admin_User_Email_Address__c = adminEmail;
                        acc.Billing_Accounts_Receivable_Email_Addres__c = BillingEmail;
                        acc.IT_Contact__c = itEmail;
                        acc.LMS__c = lmsData;
                    }
                    system.debug('accListTobeUpdate::'+accListTobeUpdate);
                    update accListTobeUpdate;

                    list<Opportunity> oppList = [select id,IT_Contact__c,LMS__c,Billing_Accounts_Receivable_Email_Addres__c,Admin_User_Email_Address__c from Opportunity where accountId in: setofAccId];
                    for(Opportunity opp : oppList){
                        opp.Billing_Accounts_Receivable_Email_Addres__c = BillingEmail;
                        opp.Admin_User_Email_Address__c = adminEmail;
                        opp.IT_Contact__c = itEmail;
                        opp.LMS__c = lmsData;
                    }
                    system.debug('oppList::'+oppList);
                    update oppList;
                }
            }
        }
    }

    @future 
    public static void test(set<String> customerId,string billlingEmail,String adminEmail){
        if(!customerId.isEmpty()){
            list<Customer_OnBoarding__c> customerOnboarding = new list<Customer_OnBoarding__c>();
            set<String> setofAccId = new set<String>();
            customerOnboarding = [select id,Account__c from Customer_OnBoarding__c where id in: customerId];
            system.debug('customerOnboarding::'+customerOnboarding);
            for(Customer_OnBoarding__c custOnboard : customerOnboarding){
                system.debug('Inside accis:::');
                setofAccId.add(custOnboard.Account__c);
                system.debug('setofAccId::'+setofAccId);
            }
            system.debug('setofAccId::'+setofAccId);
            if(!setofAccId.isEmpty()){
                list<Account> accListTobeUpdate = [select id,Billing_Accounts_Receivable_Email_Addres__c,Admin_User_Email_Address__c from account where Id in: setofAccId];
                for(Account acc : accListTobeUpdate){
                    acc.Admin_User_Email_Address__c = adminEmail;
                    acc.Billing_Accounts_Receivable_Email_Addres__c = billlingEmail;
                }
                system.debug('accListTobeUpdate::'+accListTobeUpdate);
                update accListTobeUpdate;

                list<Opportunity> oppList = [select id,Billing_Accounts_Receivable_Email_Addres__c,Admin_User_Email_Address__c from Opportunity where accountId in: setofAccId];
                for(Opportunity opp : oppList){
                    opp.Billing_Accounts_Receivable_Email_Addres__c = billlingEmail;
                    opp.Admin_User_Email_Address__c = adminEmail;
                }
                system.debug('oppList::'+oppList);
                update oppList;
            }
        }
    }
}