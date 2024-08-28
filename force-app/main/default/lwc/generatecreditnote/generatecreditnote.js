import { LightningElement, track,api,wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getGenerateInvoiceDetails from '@salesforce/apex/LwcInvoiceContrroler.fetchCreditNoteDetails';
import upDateInvoiceCreditNote from '@salesforce/apex/LwcInvoiceContrroler.upDateInvoiceCreditNote';

export default class Generatecreditnote extends LightningElement {
    @api recordId;
    @track amountpay;
    @track creditNoteNumber;
    @track creditNoteAmount;
    @track creditNotes;


    @wire(getGenerateInvoiceDetails,{invoiceId:'$recordId'})
    wireResponse(data, error){
  
      debugger;
      console.log('data' ,data);
      if(data && data.data){
        debugger;
          this.recid=data.data.Id;
            this.amountpay=data.data.Amount__c;

          if(data.data.CN_Number__c != null){
              this.creditNoteNumber= data.data.CN_Number__c ;
          }
          if(data.data.Credit_Note_Amount__c  != null ){
            this.creditNoteAmount = data.data.Credit_Note_Amount__c ;
             
          }
          if(data.data.Credit_Note__c != null){
              this.creditNotes = data.data.Credit_Note__c;
          }

      }
      if(error){
          console.log(`this is errorr from ${error}`)
          console.log('i,m inside the error ')
          
      }
  
    }
    handeleChange(event){
        var eventvalue = event.target.value;
        var eventLabel = event.target.label;
        if(eventLabel === 'Credit Note Number Date'){
            this.creditNoteNumber=eventvalue;
        }
        if(eventLabel === 'Amount'){
            this.creditNoteAmount=eventvalue;
        }
        if(eventLabel === 'Credit Notes'){
            this.creditNotes=eventvalue;
        }   

    }
    save(){
        debugger;
        if(this.amountpay < this.creditNoteAmount || this.creditNoteAmount == null ){
            this.paymentToast()
            this.showToast=false;
        }
        upDateInvoiceCreditNote({inId:this.recordId, amount:this.creditNoteAmount, creditNote:this.creditNotes,cnNumber:this.creditNoteNumber})
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
    showToast() {
        const event = new ShowToastEvent({
            title: 'Updated',
            message: 'Credite Note Updated SuccessFully',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
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
            message: 'Credit Amount should be less then Schedule Amount!!!!!',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

}