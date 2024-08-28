({
	init : function(component, event, helper) {
		console.log(component.get('v.recordId'));
        
        var newSlab = 0;
        
        var action=component.get('c.calculateQuotation');
        action.setParams({
            oppId:component.get('v.recordId'),
            newSlabPrice: newSlab
        });
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==='SUCCESS')
            {
                var res=response.getReturnValue();     
                console.log(res);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Quotation is created',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                toastEvent.fire();
                
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        
        $A.enqueueAction(action);
	}
})