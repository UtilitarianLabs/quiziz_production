import { api, LightningElement, track, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import voideInvoice from '@salesforce/apex/LwcInvoiceContrroler.voideInvoice';
import updateVoideInvoice from '@salesforce/apex/LwcInvoiceContrroler.updateVoideInvoice';
export default class VoidedInvoice extends LightningElement {
    @api recordId;
    @track invoiceStatus;
    @track paymentStatus;


    @wire(voideInvoice,{invoiceId:'$recordId'})
    wireResponse({data,error}){
        debugger;
        if(data){
            console.log(data)
            if(data.Payment_Status__c != null){
                this.paymentStatus=data.Payment_Status__c;
            }
            if(data.Invoice_Status__c != null){
                this.invoiceStatus=data.Invoice_Status__c;
            }
        }
        if(error){
            console.log(error)

        }

    }

    handeleChange(event){
        var eventvalue = event.target.value;
        var eventLabel = event.target.label;
        if(eventLabel === 'Payment Status'){
            this.paymentStatus=eventvalue;
        }
        if(eventLabel === 'Invoice Status'){
            this.invoiceStatus=eventvalue;
        }
    }


    save(){
        debugger;
        
        if(this.paymentStatus == 'Paid'){
            this.paymentToast();
            this.showToast=false;
            return;   
        }
        updateVoideInvoice({invoiceId:this.recordId})
        .then(result => {
            this.dispatchEvent(new CloseActionScreenEvent());
            this.showToast();
            eval("$A.get('e.force:refreshView').fire();");
            //this.contacts = result;
        })
        .catch(error => {
            //this.error = error;
        });
    
        
        
        


    }

    cancel(){
        var url = window.location.href; 
        var value = url.substr(0,url.lastIndexOf('/') + 1);
        window.history.back();
        return false;
    }

    paymentToast() {
        const event = new ShowToastEvent({
            title: 'Alert',
            message: 'Invoice can not be voided when Payment status is Paid.!!!!!',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    showToast() {
        const event = new ShowToastEvent({
            title: 'Updated',
            message: 'Invoice Voided Successfully',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

}