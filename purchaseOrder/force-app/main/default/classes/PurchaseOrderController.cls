public with sharing class PurchaseOrderController {
    @AuraEnabled(cacheable=true)
        public static String[] getBranchOptions(){
            Set<String> branchOptions = new Set<String>();
            // Query branches
            List<Branch__c> branches = [SELECT Name FROM Branch__c];
            // Populate branchOptions
            for(Branch__c branch : branches) {
                branchOptions.add(branch.Name);
            }
            return new List<String>(branchOptions);
        }
    

    @AuraEnabled(cacheable=true)
    public static String[] getCostCenters(String branchName) {
        Set<String> costCenterOptions = new Set<String>();
        // Query cost centers based on the selected branch
        List<cost_center__c> costCenters = [SELECT Name FROM cost_center__c WHERE Branch__r.Name = :branchName];
        // Populate costCenterOptions
        for(cost_center__c costCenter : costCenters) {
            costCenterOptions.add(costCenter.Name);
        }
        return new List<String>(costCenterOptions);
    }

    @AuraEnabled(cacheable=true)
    public static String[] getBusinessUnits(String branchName) {
        Set<String> businessUnitOptions = new Set<String>();
        // Query cost centers based on the selected branch
        List<Business_Unit__c> businessUnits = [SELECT Name FROM Business_Unit__c
        WHERE Branch__r.Name = :branchName];
        // Populate costCenterOptions
        for(Business_Unit__c
        businessUnit : businessUnits) {
            businessUnitOptions.add(businessUnit.Name);
        }
        return new List<String>(businessUnitOptions);
    }
    @AuraEnabled
    public static void createPurchaseOrderRecord(String name, String branchName, String costCenterName, String businessUnitName) {
        try {
            // Query for branch Id
            Id branchId = [SELECT Id FROM Branch__c WHERE Name = :branchName LIMIT 1].Id;
            // Query for cost center Id
            Id costCenterId = [SELECT Id FROM cost_center__c WHERE Name = :costCenterName AND Branch__r.Name = :branchName LIMIT 1].Id;
            // Query for business unit Id
            Id businessUnitId = [SELECT Id FROM Business_Unit__c WHERE Name = :businessUnitName AND Branch__r.Name = :branchName LIMIT 1].Id;
            // Create Purchase_OrderC__c record
            Purchase_order__c newPurchaseOrder = new Purchase_order__c(
                Name = name,
                Branch__c = branchId,
                cost_center__c = costCenterId,
                Business_Unit__c = businessUnitId
            );
            insert newPurchaseOrder;
            // Optionally, perform any additional logic or error handling here
        } catch(Exception ex) {
            // Handle exception
            throw new AuraHandledException('Error creating purchase order: ' + ex.getMessage());
        }
    }

}
