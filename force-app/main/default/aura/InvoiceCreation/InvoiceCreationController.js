({
	init : function(cmp, event, helper) {
		console.log(cmp.get('v.recordId'));
        var action=cmp.get('c.createInvoices');
        action.setParams({
            oppId:cmp.get('v.recordId')
        });
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==='SUCCESS'){
                console.log(response.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Invoice created',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                 var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action);
	}
})