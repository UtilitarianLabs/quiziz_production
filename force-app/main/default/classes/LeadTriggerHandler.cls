public class LeadTriggerHandler {
	
    public static void splitLastname(list<lead> leadList){
        for(lead ld : leadList){
            if(ld.lastName != null && ld.FirstName == null){
                integer counter = 0;
                List<String> filterLogicSplittedbySpace = ld.lastName.split(' ');
                for (String str : filterLogicSplittedbySpace){
                    ++counter;
                    if(counter == 1)
                    	ld.FirstName = str;
                    else if(counter == 2){
                        ld.LastName = str;
                    }else if(counter > 2){
                        ld.LastName = ld.LastName+' '+ str;
                    }
                }
                if(counter == 1){
                   ld.LastName = 'Unknown'; 
                }
            }
        }
    }
}