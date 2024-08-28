({
    doInit : function(component, event, helper) {
        window.setTimeout(
        $A.getCallback(function() {
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Paid Invoice Sent Successfully !',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
            $A.get("e.force:closeQuickAction").fire(); 
        }),100
    );
        debugger;
        component.set("v.siteURL",'{!$Label.c.PaidInvoicePDF}'+component.get('v.recordId'));
        var action = component.get("c.attachPaidInvoicePDF");
        action.setParams({
            "InvoiceId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var State = response.getState();
            if(State === "SUCCESS"){
                
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'ERROR',
                    message: 'Something went wrong !',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
        
    }
})