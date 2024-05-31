public with sharing class customSearchMutualFundLWC {
    @AuraEnabled(cacheable=true)
    public static List<IE_Mutual_Fund__c> getMutualFundList(String searchKey) {
        String searchKeyword = '%' + searchKey + '%';
        
        // create mutual fund list to store search result 
        List<IE_Mutual_Fund__c> mutualFundListRecord = new List<IE_Mutual_Fund__c>();
        
        // query mutual fund records
        for(IE_Mutual_Fund__c mfObj : [SELECT Id, Name, Minimum_SIP__c, Net_Asset_Value__c
                                        FROM IE_Mutual_Fund__c
                                        WHERE Name LIKE :searchKeyword]){
            mutualFundListRecord.add(mfObj);
        }
        
        if(mutualFundListRecord.size() == 0){
            throw new AuraHandledException('No Record Found..'); 
        }
        
        return mutualFundListRecord;
    }
}
