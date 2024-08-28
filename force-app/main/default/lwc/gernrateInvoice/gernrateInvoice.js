import { LightningElement,api,wire, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import InsertInvoice from '@salesforce/apex/LwcInvoiceContrroler.InsertInvoice';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import { NavigationMixin } from 'lightning/navigation';
//import getOpp from '@salesforce/apex/LwcInvoiceContrroler.getOpp';
import getInvoiceOpp from '@salesforce/apex/LwcInvoiceContrroler.getInvoiceOpp';



export default class GernrateInvoice extends NavigationMixin(LightningElement) {

    timeSpan = 5000;
    @api autoCloseTime = 5000;
    @api recordId;
    @track invoiceDate;
    @track invoiceNo;
    @track amount;
    @track product;
    @track subStartDate;
    @track subEndDate;
    @track billingEntityName;
    @track shippingEntityName;
    @track inVoiceNote;
    @track dateval;
    @track InvoiceId;
    @track shippingStreet;
    @track shippingCity;
    @track shippingState;
    @track shippingCountry;
    @track billingStreet;
    @track billingCity;
    @track billingState;
    @track billingCode;
    @track shippingCode;
    @track bilingCountry;
    @track inId;
    @track invoiceNumber;
    @track updatedShipping;

    connectedCallback(){
        this.invoiceDate = new Date().toISOString().substring(0, 10);
    }

    generateInvoice() {
        
    }


    @api recid;
    @wire(getInvoiceOpp,{inId:'$recordId'})
    wireResponse(data, error){
  
      debugger;
      console.log('data' ,data);
      if(data && data.data){
          if (data.data.Opportunity__r.Subscription_End_Date__c != null) {
              this.subEndDate = data.data.Opportunity__r.Subscription_End_Date__c;
          }
          this.recid=data.data.Id;
          if(data.data.Amount__c != null){
              this.amount= data.data.Amount__c;
          }
          if(data.data.Opportunity__r.Subscription_Start_Date__c != null ){
              this.subStartDate=data.data.Opportunity__r.Subscription_Start_Date__c   
          }
          if(data.data.Invoice_Note__c != null){
              this.inVoiceNote = data.data.Invoice_Note__c;
          }
          if (data.data.Shipping_Entity_name__c != null) {
              this.shippingEntityName = data.data.Shipping_Entity_name__c;
          } else {
            this.shippingEntityName = data.data.Opportunity__r.Account.Name;
          }
          if (data.data.Billing_Entity_Name__c != null) {
            this.billingEntityName = data.data.Billing_Entity_Name__c;
          } else {
            this.billingEntityName = data.data.Opportunity__r.Account.Name;
        }
          if (data.data.Generate_Invoice_Number__c != null ) {
              this.invoiceNumber = data.data.Generate_Invoice_Number__c;
          }
          if(data.data.Opportunity__r != null){
              this.product=data.data.Opportunity__r.Deal_Organization_Type__c
  
          }

          if(data.data.Billing_Street__c !=null){
            this.billingStreet = data.data.Billing_Street__c;
          }else{
            this.billingStreet = data.data.Opportunity__r.Account.billingStreet
          }

          if(data.data.Billing_City__c !=null){
            this.billingCity = data.data.Billing_City__c;
          }else{
            this.billingCity = data.data.Opportunity__r.Account.billingCity
          }

          if(data.data.Billing_State__c !=null){
            this.billingState = data.data.Billing_State__c;
          }else{
            this.billingState = data.data.Opportunity__r.Account.billingState
          }



          if(data.data.Billing_Postal_Code__c !=null){
            this.billingCode = data.data.Billing_Postal_Code__c;
          }else{
            this.billingCode = data.data.Opportunity__r.Account.BillingPostalCode
          }


          if(data.data.Billing_Country__c !=null){
            this.bilingCountry = data.data.Billing_Country__c;
          }else{
            this.bilingCountry = data.data.Opportunity__r.Account.bilingCountry
          }

        
          if(data.data.Shipping_Street__c !=null){
            this.shippingStreet = data.data.Shipping_Street__c;
          }else{
            this.shippingStreet = data.data.Opportunity__r.Account.ShippingStreet
          }

      
        if(data.data.Shipping_City__c !=null){
            this.shippingCity = data.data.Shipping_City__c;
          }else{
            this.shippingCity = data.data.Opportunity__r.Account.shippingCity
          }


        if(data.data.Shipping_State__c !=null){
            this.shippingState = data.data.Shipping_State__c;
          }else{
            this.shippingState = data.data.Opportunity__r.Account.shippingState
        }
          
        if(data.data.Shipping_Postal_Code__c !=null){
            this.shippingCode = data.data.Shipping_Postal_Code__c;
          }else{
            this.shippingCode = data.data.Opportunity__r.Account.ShippingPostalCode
          }
          
          

        if(data.data.Shipping_Country__c !=null){
            this.updatedShipping = data.data.Shipping_Country__c;
           // alert("Shipping updatedShipping :"+this.updatedShipping);
          }else{
            this.updatedShipping = data.data.Opportunity__r.Account.updatedShipping
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
        debugger;
        if(eventLabel === 'Invoice Date'){
            this.invoiceDate=eventvalue;
        }
        if(eventLabel === 'Invoice No'){
            this.invoiceNo=eventvalue;
        }
        if(eventLabel === 'Amount'){
            this.amount=eventvalue;
        }
        if(eventLabel === 'Product'){
            this.product=eventvalue;
        }
        if(eventLabel === 'Subscription Start'){
            this.subStartDate=eventvalue;
        }
        if(eventLabel === 'Subscription End'){
            this.subEndDate=eventvalue;
        }
        
         if(eventLabel === 'Invoice Note'){
             this.inVoiceNote=eventvalue;
        } if (eventLabel === 'Shipping Entity Name') {
            this.shippingEntityName = eventvalue;
        }
        if (eventLabel === 'Billing Entity Name') {
            this.billingEntityName = eventvalue;
         }
        
    }

   
    addressEventHandler(event) {
        debugger;
        console.log('event.target.city::' + event.target.city);
        console.log('type::' + event.target.dataset.type);
        console.log('postal Code => ' , event.target.postalCode);

        if (event.target.dataset.type == 'Shipping') {
            if (event.target.city != undefined) {
                this.shippingCity = event.target.city
            } 
        } 
        if (event.target.dataset.type == 'Shipping') {
            if (event.target.street != undefined) {
                this.shippingStreet = event.target.street
            }
        } 
        if (event.target.dataset.type == 'Shipping') {
            if (event.target.country != undefined) {
                this.updatedShipping = event.target.country
            }
        } 
        if (event.target.dataset.type == 'Shipping') {
            if (event.target.province != undefined) {
                this.shippingState = event.target.province
            } 
        }

        if (event.target.dataset.type == 'Shipping') {
            if (event.target.postalCode != undefined) {
                this.shippingCode = event.target.postalCode
            } 
        }

        
        if (event.target.dataset.type == 'Billing') {
            if (event.target.city != undefined) {
                this.billingCity = event.target.city
            } 
        }

        if (event.target.dataset.type == 'Billing') {
            if (event.target.street != undefined) {
                this.billingStreet = event.target.street
            } 
        }

        if (event.target.dataset.type == 'Billing') {
            if (event.target.province != undefined) {
                this.billingState = event.target.province
            } 
        }

        if (event.target.dataset.type == 'Billing') {
            if (event.target.postalCode != undefined) {
                this.billingCode = event.target.postalCode
            } 
        }



        if (event.target.dataset.type == 'Billing') {
            if (event.target.country != undefined) {
                this.bilingCountry  = event.target.country
            } 
        }
        

    }

    save(event){
        debugger;
        this.handleClick();

        
        
        InsertInvoice({
            inId: this.recid, amount: this.amount, subStartDate: this.subStartDate, subEndDate: this.subEndDate, inNote: this.inVoiceNote, inDate: this.invoiceDate, product: this.product,
            shippingState: this.shippingState, shippingCity: this.shippingCity, shippingStreet: this.shippingStreet, updatedShipping: this.updatedShipping,
            billingState: this.billingState, billingCity: this.billingCity, billingStreet: this.billingStreet, billingCountry: this.bilingCountry, generateInvoiceNumber: this.invoiceNumber,
            shippingEntityName : this.shippingEntityName, billingEntityName : this.billingEntityName, billingCode : this.billingCode, shippingCode : this.shippingCode
        })
            .then(result => {
                debugger;
                //this.handleClick();
                this.event1 = setTimeout(() => {
                    this.handleClick();
                  }, this.timeSpan);

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

showToast() {
    const event = new ShowToastEvent({
          title: 'SUCCESS',
          message: 'Invoice Generated Successfully !',
        variant: 'success',
        mode: 'dismissable'
    });
    this.dispatchEvent(event);
}

@api isLoaded = false;
// change isLoaded to the opposite of its current value
    handleClick() {
        debugger;
    this.isLoaded = !this.isLoaded;
}


}