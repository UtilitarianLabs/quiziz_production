({
    doInit : function(component, event, helper) {
        debugger;
        component.set("v.siteURL",'https://quizizz.my.salesforce.com/apex/CreditNoteVF?id='+component.get('v.recordId'));
    },
    SavePDF : function(component, event, helper){ 
        debugger;
        var action = component.get("c.insertCreditNote");
        action.setParams({
            "recordId" : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var State = response.getState();
            if(State === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'CreditNote Saved Successfully !',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
            }else{
                alert("ERROR")
            }
        });
        $A.enqueueAction(action);
    },
})