import { LightningElement, api, wire, track } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import getRecord from "@salesforce/apex/MultiSelectSchoolHanlder.getRecord";
import getMainData from "@salesforce/apex/MultiSelectSchoolHanlder.getMainData";
import updateOppChildAccounts from "@salesforce/apex/MultiSelectSchoolHanlder.updateOppChildAccounts";
import createWithoutEnrollOpp from "@salesforce/apex/MultiSelectSchoolHanlder.createOpportunityWithoutEnrollment";
import updateAndDeleteAcc from "@salesforce/apex/MultiSelectSchoolHanlder.updateAndDeleteAcc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class MpPlan extends LightningElement {
  @api recordId;
  oppRecord;
  hasLoaded = true;

  @track firstTabVariant = "brand";
  @track secTabVariant = "neutral";
  @track isSecTabActive = false;
  @track enrollType = false;
  @track without_enroll = true;
  @track lending_page = true;

  @track taggedAccList = [];
  @track selectedAccList = [];
  @track allSchoolList = [];
  @track opportunityAccount;
  @track selectedUpdatedList = [];
  @track taggedListEmpty = false;

  @track isTagAllSelected = false;
  @track isLoaded = true;
  
  value = '';

    get options() {
        return [
            { label: 'With Enrollment', value: 'with_enrollment' },
            { label: 'Without Enrollment', value: 'without_enrollment' },
        ];
    }
  
  /*EnrollmentCondition(event) {
    debugger;
    const selectedOption = event.detail.value;
    console.log('Option selected with value: ' + selectedOption);
    if(selectedOption == 'with_enrollment'){
      this.enrollType = true;
      //this.without_enroll = false;
      this.lending_page = false;
    } else {
      //this.without_enroll = true;
      this.enrollType = false;
      this.lending_page = false;
    }
  }*/

  @wire(getRecord, { oppId: "$recordId" })
  recordWire({ data, error }) {
    if (data) {
      this.hasLoaded = true;
      console.log("Data--", data);
      this.oppRecord = data;
      this.loadMainData();
    } else {
      this.showToast(
        "Warning",
        "Selected Opportunity is not related to any District Account",
        "warning"
      );
      this.closeLightningAction();
      console.log("Error", error);
    }
  }

  loadMainData() {
    getMainData({ oppId: this.oppRecord.Id })
      .then((result) => {
        console.log("Result", result);
        debugger;
        if (result.selectedAccList) {
          result.selectedAccList.forEach((tagged, index) => {
            let obj = { ...tagged };
            obj.Enrollment_Count__c = obj.Enrollment_Count__c
              ? obj.Enrollment_Count__c
              : 0;
            obj.disabled = true;
            obj.isDeleted = false;
            obj.isEdit = false;
            this.selectedAccList.push(obj);
            this.allSchoolList.push(obj);
          });
        }

        if (result.taggedAccList) {
          result.taggedAccList.forEach((tagged) => {
            let obj = { ...tagged };
            obj.Enrollment_Count__c = obj.Enrollment_Count__c
              ? obj.Enrollment_Count__c
              : 0;
            obj.isChecked = false;
            obj.disabled = true;
            if (!this.selectedAccList.find((acc) => acc.Id == obj.Id)) {
              this.taggedAccList.push(obj);
              this.allSchoolList.push(obj);
            }
          });
        }

        console.log(result.opp);
        if (result.opp) {
          this.opportunityAccount = result.opp;
        }
        console.log(this.opportunityAccount);

        this.taggedListEmpty = this.taggedAccList.length == 0;
        console.log("Selected", this.selectedAccList);
      })
      .catch((error) => {
        console.log("Error", error);
      });
  }

  closeLightningAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  showToast(title, message, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
    });
    this.dispatchEvent(evt);
  }

  firstTabClicked() {
    
    this.firstTabVariant = "brand";
    this.secTabVariant = "neutral";
    this.isSecTabActive = false;
  }

  secTabClicked() {
    
    this.firstTabVariant = "neutral";
    this.secTabVariant = "brand";
    this.isSecTabActive = true;
  }

  tableIndexChange(event) {
    let id = event.currentTarget.dataset.id;
    let tempAccList = [];
    let totalChecked = 0;

    this.taggedAccList.forEach((acc) => {
      if (acc.Id == id) {
        acc.isChecked = !acc.isChecked;
        acc.disabled = !acc.disabled;
      }

      totalChecked += acc.isChecked ? 1 : 0;
      tempAccList.push(acc);
    });

    this.isTagAllSelected = tempAccList.length == totalChecked;
    this.taggedAccList = tempAccList;
  }

  selectAllHandler() {
    let tempAccList = [];
    let totalChecked = 0;

    this.taggedAccList.forEach((acc) => {
      acc.isChecked = !this.isTagAllSelected;
      acc.disabled = !acc.isChecked;

      totalChecked += acc.isChecked ? 1 : 0;
      tempAccList.push(acc);
    });

    this.isTagAllSelected = tempAccList.length == totalChecked;
    this.taggedAccList = tempAccList;
  }

  inputChangeHandler(event) {
    
    let id = event.currentTarget.dataset.id;
    let value = parseInt(event.target.value);

    let tagList = [...this.taggedAccList];

    let index = tagList.findIndex((acc) => acc.Id == id);
    let obj = { ...tagList[index] };
    obj.Enrollment_Count__c = parseInt(value);
    tagList[index] = obj;
    this.taggedAccList = tagList;

    console.log("TaggedList",this.taggedAccList);
  }

  secTabInputChangeHandler(event) {

    let id = event.currentTarget.dataset.id;
    let value = parseInt(event.target.value);

    let secTabList = [...this.selectedAccList];

    let index = secTabList.findIndex((acc) => acc.Id == id);
    let obj = { ...secTabList[index] };
    
    obj.Enrollment_Count__c = parseInt(value);
    console.log(obj)
    console.log(this.selectedUpdatedList.find((acc) => acc.Id === id));
    if (this.selectedUpdatedList.find((acc) => acc.Id === id)) {
      let existIndex = this.selectedUpdatedList.findIndex(
        (acc) => acc.Id == id
      );
      this.selectedUpdatedList[existIndex] = obj;
    } else {
      this.selectedUpdatedList.push(obj);
    }
    console.log(this.selectedUpdatedList);
    secTabList[index] = obj;
    this.selectedAccList = secTabList;
  }

  createEnrollment() {
    let tagAccList = [];

    debugger;
    this.taggedAccList.forEach((acc) => {
      if (acc.isChecked) {
        tagAccList.push({
          accId: acc.Id,
          enrollNum: acc.Enrollment_Count__c,
          OppName: acc.Name,
        });
      }
    });
    //console.log(this.tagAccList.length);
    
    /*if (this.selectedAccList.length == 0 && tagAccList.length<2) {
      this.showToast("Error", "Please select atleast 2 schools", "error");
      return;
    }*/
    let totalEnrolls = 0;
    tagAccList.map((tagged) => {
      totalEnrolls += tagged.enrollNum;
    });

    console.log(totalEnrolls);
    console.log(this.oppRecord);
    if (this.oppRecord.Deal_Confirmed_Enrollment__c !== totalEnrolls) {
      this.showToast(
        "Error",
        `Total enrollments must match with Deal confirmed (${this.oppRecord.Deal_Confirmed_Enrollment__c})`,
        "error"
      );
      return;
    }
    this.isLoaded=false;
    let total=this.oppRecord.Account.Enrollment_Count__c;
    if(total==null){
      total=0;
    }
    total+=totalEnrolls;
    console.log("TOTAL-----",total);
    console.log("tagAccList-----",tagAccList);
    updateOppChildAccounts({
      oppId: this.recordId,
      oppChildAccWrapperList: tagAccList,
      accIdtoUpdate:this.oppRecord.AccountId,
      totalEnrollements:total
    })
      .then((result) => {
        console.log("Result", result);

        this.showToast("Success", "Enroll Created Successfully!", "success");
        this.isLoaded=true;
        this.closeLightningAction();
      })
      .catch((error) => {
        this.showToast("Error", error, "error");
        console.log(error);
        this.isLoaded=true;
      });
  }

  createMultiSchoolWithoutEnroll() {
    debugger;
    let tagAccList = [];
    this.taggedAccList.forEach((acc) => {
      if (acc.isChecked) {
        tagAccList.push({
          accId: acc.Id,
          enrollNum: acc.Enrollment_Count__c,
          OppName: acc.Name,
        });
      }
    });
    //console.log(this.tagAccList.length);
    
    /*if (this.selectedAccList.length == 0 && tagAccList.length<2) {
      this.showToast("Error", "Please select atleast 2 schools", "error");
      return;
    }*/
    let totalEnrolls = 0;
    tagAccList.map((tagged) => {
      totalEnrolls += tagged.enrollNum;
    });
    let total=0;
    if(total==null){
      total=0;
    }
    total += totalEnrolls;
    this.isLoaded=false;
    createWithoutEnrollOpp({
      oppId: this.recordId,
      oppChildAccWrapperList: tagAccList,
      accIdtoUpdate:this.oppRecord.AccountId,
      totalEnrollements:total
    })
      .then((result) => {
        console.log("Result", result);
        this.isLoaded = true;
        if (result == 'Please provide enrollment count.') {
          this.showToast("Warning", "Kindly Add Enrollment Count.", "warning");
          this.isLoaded=true;
        this.closeLightningAction();
        } else {
          this.showToast("Success", "Schools Has Been Confirmed!", "success");
          this.isLoaded=true;
          this.closeLightningAction();
        }
        
      })
      .catch((error) => {
        this.showToast("Error", error, "error");
        console.log(error);
        this.isLoaded=true;
      });
  }

  enableEdit(event) {
    let id = event.currentTarget.dataset.id;
    let secTabList = [...this.selectedAccList];

    let index = secTabList.findIndex((acc) => acc.Id == id);
    let obj = { ...secTabList[index] };
    obj.disabled = false;
    obj.isEdit = true;

    secTabList[index] = obj;
    this.selectedAccList = secTabList;
  }

  loaded(){
    return false;
  }
  deletRow(event) {
    debugger;
    /*if(this.selectedAccList.length<=2){
      this.showToast("Error", "Minimum selected school would be 2" , "error");
      return;
    }*/
    
    /*let totalEnrolls = 0;
    this.selectedAccList.map((tagged) => {
      totalEnrolls += tagged.Enrollment_Count__c;
    });

    console.log(totalEnrolls);
    if (this.oppRecord.Account.Total_Enrollments__c !== totalEnrolls) {
      this.showToast(
        "Error",
        "Total enrollments must match with Deal confirmed",
        "error"
      );
      return;
    }*/
    let id = event.currentTarget.dataset.id;
    let deletedObj = { ...this.selectedAccList.find((acc) => acc.Id == id) };
    deletedObj.isDeleted = true;
    deletedObj.isEdit = false;

    if (this.selectedUpdatedList.find((acc) => acc.Id == id)) {
      let existIndex = this.selectedUpdatedList.findIndex(
        (acc) => acc.Id == id
      );
      this.selectedUpdatedList[existIndex] = deletedObj;
    } else {
      this.selectedUpdatedList.push(deletedObj);
    }

    this.selectedAccList = this.selectedAccList.filter((acc) => acc.Id != id);
    this.isLoaded=false;
    updateAndDeleteAcc({
      requestChildWrapper: this.selectedUpdatedList,
      allSchoolWrp: this.allSchoolList,
      oppId: this.oppRecord.Id
    }).then((result) => {
      debugger;
        this.isLoaded=true;
        console.log("Result");
        console.log(result);
        this.showToast(
          "Success",
          "School Has Been Deleted. !!!!",
          "success"
        );
        // this.closeLightningAction();
      })
      .catch((error) => {
        this.isLoaded=true;
        this.showToast("Error", "Error to update data", "error");
        console.log("Error", error);
      });
  }

  updateEnollment() {
    console.log(this.selectedUpdatedList);
    if (this.selectedUpdatedList.length == 0) {
      this.showToast("Warning", "Please change any detail", "warning");
      return;
    }

    let wrapperList = [];
    let wrapAllSchoolList = [];
    console.log(this.selectedUpdatedList);
    this.selectedUpdatedList.forEach((acc) => {
      let obj = { ...acc };

      obj.enrollment = obj.Enrollment_Count__c;
      delete obj.Enrollment_Count__c;

      wrapperList.push(obj);
    });

    this.allSchoolList.forEach((acc) => {
      
      let obj = { ...acc };

      obj.enrollment = obj.Enrollment_Count__c;
      delete obj.Enrollment_Count__c;

      wrapAllSchoolList.push(obj);
    });
    console.log("UpdatedEnroll", wrapAllSchoolList);
    this.selectedUpdatedList = wrapperList;
    console.log("UpdatedEnroll", this.selectedUpdatedList);
    console.log(this.selectedUpdatedList);
    this.selectedUpdatedList.map(select=>{
      console.log(select);
    })
    
    console.log( wrapAllSchoolList);
    
    this.isLoaded=false;
    updateAndDeleteAcc({
      requestChildWrapper: this.selectedUpdatedList,
      allSchoolWrp: wrapAllSchoolList,
    })
      .then((result) => {
        console.log("Result", result);
        this.showToast(
          "Success",
          "Selected School list data updated",
          "success"
        );
        this.isLoaded=true;
        this.closeLightningAction();
        
      })
      .catch((error) => {
        this.showToast("Error", "Error to update data", "error");
        console.log("Error", error);
        this.isLoaded=true;
      });
  }
}