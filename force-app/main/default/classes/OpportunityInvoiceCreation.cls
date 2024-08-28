public class OpportunityInvoiceCreation {
    
    public static void createInvoices(Set<Id> oppIdSet){
        If(!oppIdSet.isEmpty()){
            List<Invoice__c> invoiceListTobeInsert = new List<Invoice__c>();
            list<opportunity> opportunityList = [SELECT Id,No_of_Invoices__c,Amount,Invoice_created__c,PO_Number__c,
                                                 Subscription_Start_Date__c,Subscription_End_Date__c 
                                                 FROM Opportunity 
                                                 WHERE Id in: oppIdSet and Invoice_created__c = false];
            
            for(opportunity oppDetails : opportunityList){
                date tempEndDate = system.today();
                for(Integer i=0;i<(oppDetails.No_of_Invoices__c);i++){
                    Invoice__c invoiceToCreate=new Invoice__c();
                    if(i==0){
                        invoiceToCreate.Invoice_Date__c=date.today();
                    }else{
                        invoiceToCreate.Invoice_Date__c = tempEndDate + 1;
                    }
                    invoiceToCreate.Amount__c				=	oppDetails.Amount/(oppDetails.No_of_Invoices__c);
                    invoiceToCreate.Opportunity__c			=	oppDetails.Id;
                    invoiceToCreate.Due_Date__c 			= 	invoiceToCreate.Invoice_Date__c.addDays(30);
                    invoiceToCreate.Billing_Start_Date__c 	= 	oppDetails.Subscription_Start_Date__c;
                    invoiceToCreate.Billing_End_Date__c   	= 	oppDetails.Subscription_End_Date__c;
                    invoiceToCreate.PO_Number__c 		  	= 	oppDetails.PO_Number__c;
                    tempEndDate 							= 	invoiceToCreate.Invoice_Date__c.addMonths(Integer.valueOf((12/oppDetails.No_of_Invoices__c))) - 1;
                    invoiceListTobeInsert.add(invoiceToCreate);
                }
                
            }
            
            if(!invoiceListTobeInsert.isEmpty()){
                insert invoiceListTobeInsert;
                
                for(opportunity oppDetails : opportunityList){
                    oppDetails.Invoice_created__c = true;
                }
                
                update opportunityList;
            }
            
        }
    }
    
    @AuraEnabled
    public static String createInvoices(Id oppId){
        String returnMSG = '';
        try{
            system.debug('oppId::'+oppId);
            
            List<Invoice__c> invoices=new List<Invoice__c>();
            //Invoice_Due_Period__mdt duePeriod=[ Select Id,Due_Periods__c from Invoice_Due_Period__mdt ];
            //Invoice_Tax__mdt tax=  [Select Id,Tax_Amount__c from Invoice_Tax__mdt];
            list<opportunity> opportunityList = [SELECT Id,No_of_Invoices__c,Amount,Invoice_created__c FROM Opportunity WHERE Id=:oppId];
            decimal oppAmount = 0;
            integer invoiceCount = 0;
            Integer invoiceMonthGap = 0;
            for(opportunity oppDetails : opportunityList){
                if(oppDetails.Invoice_created__c){
                    returnMSG = 'Invoice already created. Please check with Salesforce Admin!!!';
                }else if(oppDetails.No_of_Invoices__c == null || oppDetails.No_of_Invoices__c == 0){
                    returnMSG = 'Invalid value in "No Of Invoice",Value should be greater than 0.';
                }else if(!oppDetails.Invoice_created__c){
                    oppAmount = oppDetails.Amount;
                    invoiceCount = integer.valueOf(oppDetails.No_of_Invoices__c);
                    invoiceMonthGap=12/invoiceCount; 
                }
            }
            date tempEndDate = system.today();
            if(invoiceCount > 0){
                for(integer i=0;i<invoiceCount;i++){
                    Invoice__c invoiceToCreate=new Invoice__c();
                    invoiceToCreate.Amount__c=oppAmount/invoiceCount;
                    if(i==0){
                        invoiceToCreate.Invoice_Date__c=date.today();
                    }else{
                        invoiceToCreate.Invoice_Date__c = tempEndDate + 1;
                    }
                    invoiceToCreate.Opportunity__c=oppId;
                    invoiceToCreate.Due_Date__c = invoiceToCreate.Invoice_Date__c + 15;
                    tempEndDate = invoiceToCreate.Invoice_Date__c.addMonths(Integer.valueOf((12/opportunityList[0].No_of_Invoices__c))) - 1;
                    invoices.add(invoiceToCreate);
                }
                system.debug('invoices::'+invoices);
                if(invoices.size()>0){
                    insert invoices;
                    Opportunity Opp = new Opportunity();
                    opp.Invoice_created__c = true;
                    opp.Id = oppId;
                    update opp;
                    returnMSG = 'Invoice has been created successfully!!!!';
                    //return true;
                }
            }
            if(returnMSG == ''){
                returnMSG = 'Something went wrong.Please check with Salesforce Admin!!!';
            }
            return returnMSG;
            
        }catch(Exception ex){
            System.debug(ex.getCause());
            System.debug(ex.getLineNumber());
            System.debug(ex.getMessage());
            returnMSG = 'Something went wrong.Please check with Salesforce Admin!!!';
            return returnMSG;
        }
    }
}