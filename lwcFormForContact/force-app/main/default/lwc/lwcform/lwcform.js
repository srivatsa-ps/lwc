import { LightningElement } from 'lwc';
import createContact from '@salesforce/apex/lwcController.createContact';
import { showToastEvent } from 'lightning/platformShowToastEvent';

export default class Lwcform extends LightningElement {
    contactFName='';
    contactLName='';
    contactEmail='';
    contactDepartment='';
    result=null;
    
    handleInputChange(event){
        const fieldname=event.target.name;
        this[fieldname]=event.target.value;
    }

    handleSave(){
        createContact({
            contactFName: this.contactFName,
            contactLName: this.contactLName,
            contactEmail: this.contactEmail,
            contactDepartment: this.contactDepartment
        }).then(result=>{
            const event = new showToastEvent({
                title: 'Success',
                message: 'Contact created',
                variant: 'success'
            });
            this.dispatchEvent(event);
        }).catch(error=>{
            const event = new showToastEvent({
                title: 'Error',
                message: 'Error while creating contact',
                variant: 'error'
            });
            this.dispatchEvent(event);
        });
    }
}
