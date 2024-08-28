({
	doInit : function(component, event, helper) {
        debugger;
		var action = component.get("c.SendEmailAdnPDFToCustomer");
        var currentId = component.get("v.recordId");
        action.setParams({
            "invoiceId" : currentId
        });
        action.setCallback(this, function(response){
            var State = response.getState();
            if(State === "SUCCESS"){
               var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Invoice Send Successfully',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
            }else{
                 var toastEvent = $A.get("e.force:showToast");
                alert("Please Give the required Value")
                toastEvent.setParams({
                    title : 'ERROR',
                    message: 'Something went Wrong !!',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
            }
             toastEvent.fire();
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
            $A.get('e.force:refreshView').fire();
        });
         $A.enqueueAction(action);
	}
})