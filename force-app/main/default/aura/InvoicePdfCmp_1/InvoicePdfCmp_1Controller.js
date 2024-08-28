({
    doInit : function(cmp, event, helper) {
     debugger;
        cmp.set('v.siteURL','{!$Label.c.InvoicePDF_1}'+cmp.get('v.recordId'));
    }
    ,
     SavePDF:function(component,event,helper)
    {
        debugger;
        console.log(component.get('v.recordId'));
        var action = component.get('c.attachFileToOppotunities'); 
        action.setParams({
            "InvoiceId" : component.get('v.recordId')
        });
        action.setCallback(this, function(a){
            var state = a.getState();
            if(state == 'SUCCESS') {
                
                if(a.getReturnValue()!=null){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Invoice Pdf saved',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                     $A.get('e.force:refreshView').fire();
                }
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'This is an error message',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
            console.log(state);
        }); 
        $A.enqueueAction(action);
    },
})