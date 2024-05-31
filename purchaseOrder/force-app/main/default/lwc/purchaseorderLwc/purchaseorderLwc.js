import { LightningElement, track, wire } from 'lwc';
import getBranchOptions from '@salesforce/apex/PurchaseOrderController.getBranchOptions';
import getCostCenters from '@salesforce/apex/PurchaseOrderController.getCostCenters';
import getBusinessUnits from '@salesforce/apex/PurchaseOrderController.getBusinessUnits';
import createPurchaseOrderRecord from '@salesforce/apex/PurchaseOrderController.createPurchaseOrderRecord';
import { NavigationMixin } from 'lightning/navigation';

export default class purchaseorderLwc extends NavigationMixin(LightningElement) {
    @track showBranchSelection = true;
    @track showPurchaseOrderForm = false;
    @track branchOptions = [];
    @track costCenterOptions = [];
    @track businessUnitOptions = [];
    @track selectedBranch = '';
    @track selectedCostCenter = '';
    @track selectedBusinessUnit = '';
    @track name = '';
    @track nextDisabled = true;

    connectedCallback() {
        this.resetModal();
    }

    resetModal() {
        this.showBranchSelection = true;
        this.showPurchaseOrderForm = false;
        this.selectedBranch = '';
        this.selectedCostCenter = '';
        this.selectedBusinessUnit = '';
        this.name = '';
        this.nextDisabled = true;
    }

    @wire(getBranchOptions)
    wiredBranchOptions({ error, data }) {
        if (data) {
            this.branchOptions = data.map(branch => {
                return { label: branch, value: branch };
            });
        } else if (error) {
            console.error('Error fetching branch options:', error);
        }
    }

    handleBranchChange(event) {
        this.selectedBranch = event.detail.value;
        this.nextDisabled = !this.selectedBranch;
    }

    handleCostCenterChange(event) {
        this.selectedCostCenter = event.detail.value;
    }

    handleBusinessUnitChange(event) {
        this.selectedBusinessUnit = event.detail.value;
    }

    handleNameChange(event) {
        this.name = event.target.value;
    }

    handleNext() {
        if (!this.selectedBranch) {
            return; // Prevent proceeding without selecting a branch
        }

        // Load cost centers and business units based on the selected branch
        getCostCenters({ branchName: this.selectedBranch })
            .then(result => {
                this.costCenterOptions = result.map(costCenter => {
                    return { label: costCenter, value: costCenter };
                });
            })
            .catch(error => {
                console.error('Error fetching cost centers:', error);
            });

        getBusinessUnits({ branchName: this.selectedBranch })
            .then(result => {
                this.businessUnitOptions = result.map(businessUnit => {
                    return { label: businessUnit, value: businessUnit };
                });
            })
            .catch(error => {
                console.error('Error fetching business units:', error);
            });

        this.showBranchSelection = false;
        this.showPurchaseOrderForm = true;
    }

    handlePrevious() {
        this.resetModal();
    }

    handleCancel() {
        this.navigateToRecordListView();
    }

    createPurchaseOrder() {
        createPurchaseOrderRecord({
            name: this.name,
            branchName: this.selectedBranch,
            costCenterName: this.selectedCostCenter,
            businessUnitName: this.selectedBusinessUnit
        })
            .then(result => {
                // Handle success (optional)
                // Navigate to the record list view
                
                this.navigateToRecordListView();
                this.dispatchEvent(
                    new showToastEvent(
                        {
                            title:"Success",
                            message:"order" +this.name +" created sucessfully",
                            variant: "success"
                        }
                    )
                )
            })
            .catch(error => {
                console.error('Error creating purchase order:', error);
            });
    }

    navigateToRecordListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Purchase_Order__c',
                actionName: 'list'
            }
        });
    }
}
