public with sharing class InvoiceController {
    @AuraEnabled(cacheable=true)
    public static List<Invoice__c> getInvoices() {
        return [SELECT Id, CMS_Invoice_Number__c, CreatedById, CreatedBy.Name, Days_Past_Due__c, Due_Date__c, Paid__c, Stage__c FROM Invoice__c];
    }
}
