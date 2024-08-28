public without sharing class SavecanvasDetails {
    
    @AuraEnabled
    public static string savecanvasDetailsMethod(Customer_OnBoarding__c canvasdetails){
        String Message='';
        try{
            if(canvasdetails==null){
                return 'NULL GET';
            }
            System.debug(canvasdetails);
            upsert canvasdetails;
            
            Message='Success';
        }
        catch(Exception ex){
            Message=ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString();
        }
        return Message;
    }
    
    public class customers{
        @AuraEnabled
    	public  Customer_OnBoarding__c customerOnBoard;    
    }
    
    
    
    @AuraEnabled
    public static customers getDefaultCutomerOnBoard(String accId){
        try{
            List<Customer_OnBoarding__c> onBoard=[SELECT Id,Account__c,Canvas_Client_Id__c,Canvas_Secret_key__c,Canvas_URL__c,Schoology_URL__c FROM Customer_OnBoarding__c WHERE Account__c= : accId];
            if(onBoard.size()>0){
                
                customers cust=new customers();
                cust.customerOnBoard=onBoard[0];
                return cust;
            }
            else{
                return null;
            }    
        }
        catch(Exception ex){
            System.debug(ex.getLineNumber());
            System.debug(ex.getCause());
            return null;
        }
        
        
        
    }
}