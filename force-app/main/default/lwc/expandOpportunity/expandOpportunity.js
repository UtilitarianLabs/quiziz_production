import { LightningElement, api, wire } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import createDistrictExpansionOpp from "@salesforce/apex/ExpandOpportunityController.createExpansionOpportunity";
import createExpansionForMultiSchool from "@salesforce/apex/ExpandOpportunityController.createMultiExpansionOpportunity";
import getChildAccounts from "@salesforce/apex/ExpandOpportunityController.getChildAccounts";
import {getRecord} from 'lightning/uiRecordApi';

export default class ExpandOpportunity extends LightningElement {
    @api recordId;
    hasLoaded = true;
    isProcessing = false;
    isStartPage = true;
    isDistrictPage = false;
    isMultiSchoolPage = false;
    showMultiSchoolTable = false;
    expTypeValue = 'District';
    childAccountList = [];
    childAcctListEmpty = true;
    isTagAllSelected = false;

    @wire(getRecord, {recordId: '$recordId', fields: oppFields})
    opportunity;



    get expTypeOptions() {
        return [
            { label: 'District', value: 'District' },
            { label: 'Multi-School', value: 'Multi-School' }
        ];
    }

    handleExpTypeChange(event) {
        this.expTypeValue = event.detail.value;
    }


    nextScreen(){
        if(this.expTypeValue == 'District'){
            this.isStartPage = false;
            this.isDistrictPage = true;
            this.isProcessing = true;
            createDistrictExpansionOpp({oppId: this.recordId}).then(result=>{
                console.log(JSON.stringify(result));
                this.showToast(
                    "Success",
                    "Expansion Opportunity successfully created!",
                    "success"
                );
                this.isProcessing = false;
                this.closeLightningAction();
            }).catch(error=>{
                console.log(error);
                this.showToast(
                    "Error",
                    error,
                    "error"
                );
                this.isProcessing = false;
            });
        }else if(this.expTypeValue == 'Multi-School'){
            this.isStartPage = false;
            this.isMultiSchoolPage = true;
            this.isProcessing = true;
            getChildAccounts({oppId: this.recordId}).then(result=>{
                console.log(JSON.stringify(result));
                this.childAccountList = result;
                this.childAcctListEmpty = this.childAccountList.length == 0;
                this.isProcessing = false;
                this.showMultiSchoolTable = true;
            }).catch(error=>{
                console.log(error);
                this.showToast(
                    "Error",
                    error,
                    "error"
                );
                this.isProcessing = false;
            });
        }
    }

    createMultiSchoolExpansion(){
        let selectedAcctIdList = [];
        this.childAccountList.forEach((acc) => {
            if (acc.isChecked) {
                selectedAcctIdList.push(acc.accountId);
            }
          });
        
        createExpansionForMultiSchool({oppId: this.recordId, childAccountIds: selectedAcctIdList}).then(result=>{
            console.log(JSON.stringify(result));
            this.showToast(
                "Success",
                "Expansion Opportunity successfully created!",
                "success"
            );
            this.isProcessing = false;
            this.closeLightningAction();
        }).catch(error=>{
            console.log(error);
            this.showToast(
                "Error",
                error,
                "error"
            );
            this.isProcessing = false;
        });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        });
        this.dispatchEvent(evt);
    }

    closeLightningAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    tableIndexChange(event) {
        let id = event.currentTarget.dataset.id;
        let tempAccList = [];
        let totalChecked = 0;
        this.childAccountList.forEach((acc) => {
            if (acc.accountId == id) {
                acc.isChecked = !acc.isChecked;
           //acc.disabled = !acc.disabled;
            }

            totalChecked += acc.isChecked ? 1 : 0;
            tempAccList.push(acc);
        });

        this.isTagAllSelected = tempAccList.length == totalChecked;
        this.childAccountList = tempAccList;
    }

    selectAllHandler() {
        let tempAccList = [];
        let totalChecked = 0;

        this.childAccountList.forEach((acc) => {
            acc.isChecked = !this.isTagAllSelected;
            //acc.disabled = !acc.isChecked;

            totalChecked += acc.isChecked ? 1 : 0;
            tempAccList.push(acc);
        });

        this.isTagAllSelected = tempAccList.length == totalChecked;
        this.childAccountList = tempAccList;
    }
}