import { LightningElement, wire } from 'lwc';
import getInvoices from '@salesforce/apex/InvoiceController.getInvoices';

const columns = [
    { label: 'CMS Invoice Number', fieldName: 'CMS_Invoice_Number__c' },
    { label: 'Created By', fieldName: 'CreatedById' },
    { label: 'Days Past Due', fieldName: 'Days_Past_Due__c' },
    { label: 'Due Date', fieldName: 'Due_Date__c' },
    { label: 'Paid', fieldName: 'Paid__c', type: 'boolean' },
    { label: 'Stage', fieldName: 'Stage__c' }
];

export default class Invoicepage extends LightningElement {
    columns = columns;
    invoices;

    @wire(getInvoices)
    wiredInvoices({ error, data }) {
        if (data) {
            this.invoices = data.map(invoice => ({
                ...invoice,
                rowClass: invoice.Paid__c ? 'paid-row' : 'open-row'
            }));
        } else if (error) {
            console.error('Error fetching invoices:', error);
        }
    }

    handleRowAction(event) {
        const row = event.detail.row;
        // Handle row action (if any)
    }
}
