import { LightningElement, track, wire,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import manualPaymentInvoice from '@salesforce/apex/LwcInvoiceContrroler.manualPaymentInvoice';
import upDateManualPayment from '@salesforce/apex/LwcInvoiceContrroler.upDateManualPayment';

export default class InvoiceManualPayment extends LightningElement {
    @api recordId;
    @track paymentStatus;
    @track paymentModeType;
    @track paymentDate;
    @track reciviedAmount;
    @track scheuleAmount;
    @track paymentNotes;
    @track firstPaymentAmount;
    @track firstPaymentDate;
    @track secondPaymentAmount;
    @track secondPaymentDate;
    @track thirdPaymentAmount;
    @track thirdPaymentDate;
    @track invoiceRec;
    @track remaingAmount = 0;
    @track totalPaidAmount = 0;
    @track paymentCheckWireNo;
    @track firstPaymentCheckNo;
    @track secondPaymentCheck;
    @track thirdPaymentCheck;
    @track payment = true;
        @wire(manualPaymentInvoice,{invoiceId:'$recordId'})
        wireResponse(data, error){
            debugger;
            if(data && data.data){
                console.log(`this is data ${data}`)
                console.log(data)
                this.invoiceRec = data.data; 
                if(data.data.Payment_Status__c != null){
                    this.paymentStatus= data.data.Payment_Status__c ;
                }
                if(data.data.Payment_Mode_Type__c != null){
                    this.paymentModeType= data.data.Payment_Mode_Type__c ;
                }
                if(data.data.Payment_Date__c != null){
                    this.paymentDate= data.data.Payment_Date__c ;
                }
                if(data.data.Invoiced_Amount__c != null){
                    console.log("data.data.Invoiced_Amount__c ::::",data.data.Invoiced_Amount__c)
                    this.reciviedAmount= data.data.Invoiced_Amount__c ;
                    console.log("this.reciviedAmount:::",this.reciviedAmount)
                }
                if(data.data.Amount__c != null){
                    this.scheuleAmount= data.data.Amount__c ;
                }
                if(data.data.Payment_Notes__c != null){
                    this.paymentNotes= data.data.Payment_Notes__c ;
                }
                if(this.invoiceRec.Paid_Amount__c < this.invoiceRec.Invoiced_Amount__c){
                    if(this.invoiceRec.First_Payment_Amount__c == null && this.invoiceRec.First_Payment_Date__c == null){
                        this.firstPayment = true;
                        this.payment = false;
                    }else  if(this.invoiceRec.First_Payment_Amount__c != null && this.invoiceRec.Second_Payment_Amount__c == null){
                        this.SecondPayment = true;
                        this.payment = false;
                    }else  if(this.invoiceRec.Second_Payment_Amount__c != null && this.invoiceRec.Third_Payment_Amount__c == null){
                        this.ThirdPayment = true;
                        this.payment = false;
                    }
                }
               
              
            }
            if(error){
                console.log(`this is data ${error}`)
            }
        }

        handeleChange(event){
            debugger;
            var eventvalue = event.target.value;
            var eventLabel = event.target.label;
            if(eventLabel === 'Payment Status'){
                this.paymentStatus=event.detail.value;
            }
            if(eventLabel === 'Payment Mode Type'){
                this.paymentModeType=event.detail.value;
            }
            if(eventLabel === 'Date'){
                this.paymentDate=eventvalue;
            }
            if(eventLabel === 'Paid Amount'){
                this.reciviedAmount=eventvalue;
                if(this.invoiceRec.Paid_Amount__c == undefined || this.invoiceRec.Paid_Amount__c < this.invoiceRec.Invoiced_Amount__c){
                   
                    if(this.invoiceRec.First_Payment_Amount__c == null && this.invoiceRec.First_Payment_Date__c == null){
                        this.firstPayment = true;
                        this.payment = false;
                    }else if(this.invoiceRec.First_Payment_Amount__c != null && this.invoiceRec.Second_Payment_Amount__c == null){
                        this.SecondPayment = true;
                        this.payment = false;
                    }else if(this.invoiceRec.Second_Payment_Amount__c != null && this.invoiceRec.Third_Payment_Amount__c == null || this.invoiceRec.Third_Payment_Amount__c == undefined){
                        this.ThirdPayment = true;
                        this.payment = false;
                    }
                    if( this.invoiceRec.Invoiced_Amount__c > this.invoiceRec.Amount__c){
                        this.showToast('ERROR','Paid Amount can not be Greater than Scheduled Amount','warning');
                        return ;
                    }  
                }
            }

            
            if(eventLabel === 'Payment Notes'){
                this.paymentNotes=eventvalue;
            }
            if(eventLabel === 'First Payment'){
                this.firstPaymentAmount=eventvalue;
            }
            if(eventLabel === 'First Payment Date'){
                this.firstPaymentDate=eventvalue;

            }
            if(eventLabel === 'Second Payment'){
                this.secondPaymentAmount=eventvalue;
            }
            if(eventLabel === 'Second Payment Date'){
                this.secondPaymentDate=eventvalue;
            }
            if(eventLabel === 'Third Payment'){
                debugger;
                this.thirdPaymentAmount=eventvalue;
                this.totalPaidAmount = this.invoiceRec.Invoiced_Amount__c + this.invoiceRec.First_Payment_Amount__c + this.invoiceRec.Second_Payment_Amount__c;
                this.remaingAmount = this.invoiceRec.Amount__c - this.totalPaidAmount;
            }
            if(eventLabel === 'Third Payment Date'){
                this.thirdPaymentDate=eventvalue;
            }
            if (eventLabel === 'Payment Check/Wire No') {
                this.paymentCheckWireNo = eventvalue
            }
            if(eventLabel === 'First Payment Check No'){
                this.firstPaymentCheckNo = eventvalue;
            }
            if(eventLabel === 'Second Payment Check No'){
                this.secondPaymentCheck = eventvalue;
            }
            if(eventLabel === 'Third Payment Check No'){
                this.thirdPaymentCheck = eventvalue;
            }
            
        }


        save(){
            debugger;

              /*if( this.thirdPaymentAmount !=  this.remaingAmount && this.thirdPaymentAmount != null || this.thirdPaymentAmount > this.remaingAmount){
                    this.showToast('ERROR','Please provide '+ this.remaingAmount+' To Complete your Payment','warning');
                    console.log("this.thirdPaymentAmount :::",this.thirdPaymentAmount +"this.remaingAmount :::",this.remaingAmount)
                    return ;
                }else if(this.remaingAmount == this.thirdPaymentData){
                  //  alert("SUCCESS")
                }*/

            if( this.paymentStatus == null){
                this.showToast('Failed','Plesse Enter Payment Status','error');
                return ;
            }
            if( this.paymentModeType == null){
                this.showToast('Failed','Plesse Enter Payment Mode Type','error');
                return ;
            }
            if( this.paymentDate == null){
                this.showToast('Failed','Plesse Date','error');
                return ;
            }
            if( this.reciviedAmount == null){
                this.showToast('Failed','Plesse Enter Paid Amount','error');
                return ;
            }
            if( this.paymentNotes == null){
                this.showToast('Failed','Plesse Enter Payment Notes','error');
                return ;
            }
            upDateManualPayment({
                invoiceId:this.recordId,paymentDate:this.paymentDate,paymentModeType:this.paymentModeType,paymentStatus:this.paymentStatus,
                reciviedAmount:this.reciviedAmount, paymentNotes:this.paymentNotes,firstPaymentDate:this.firstPaymentDate,firstPaymentAmount:this.firstPaymentAmount,
                secondPaymentDate:this.secondPaymentDate,secondPaymentAmount:this.secondPaymentAmount,thirdPaymentDate:this.thirdPaymentDate,thirdPaymentAmount:this.thirdPaymentAmount,
                firstPaymentCheckNo:this.firstPaymentCheckNo,secondPaymentCheck:this.secondPaymentCheck,thirdPaymentCheck:this.thirdPaymentCheck,paymentCheckWireNo:this.paymentCheckWireNo
            }) 
            .then(result => {
                this.dispatchEvent(new CloseActionScreenEvent());
                this.showToast('Updated','Invoice Updated SuccessFull','success');
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

        showToast(title , message, variant ) {
            const event = new ShowToastEvent({
                title:title,
                message:message ,
                variant: variant,
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }

        get options() {
            return [
                { label: 'ACH/Wire', value: 'ACH-Wire' },
                { label: 'Check', value: 'Check' },
            ];
        }
        get paymentOptio() {
            return [
                { label: 'Draft', value: 'Draft' },
                { label: 'Paid', value: 'Paid' },
                { label: 'Open', value: 'Open' },
                { label: 'Overdue', value: 'Overdue' },
            ];
        }
        
    

       
}