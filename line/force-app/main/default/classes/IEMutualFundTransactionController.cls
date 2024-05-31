public with sharing class IEMutualFundTransactionController {
    @AuraEnabled
    public static void buyMutualFund(Id mutualFundId, Decimal investedAmount) {
        try {
            // Query to get the IE_Customer__c ID associated with the current User
            IE_Customer__c customer = [
                SELECT Id 
                FROM IE_Customer__c 
                WHERE User__c = :UserInfo.getUserId()
                LIMIT 1
            ];
            
            // Ensure that a customer record is found
            if (customer == null) {
                throw new AuraHandledException('No corresponding IE Customer found for the current user.');
            }

            // Create a new holding record
            IE_Mutual_Fund_Holding__c newHolding = new IE_Mutual_Fund_Holding__c(
                IE_Customer__c = customer.Id,
                IE_Mutual_Fund__c = mutualFundId,
                Invested_Amount__c = investedAmount
            );
            insert newHolding;
        } catch (Exception e) {
            throw new AuraHandledException('An error occurred while buying the mutual fund: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Decimal getInvestedAmount(Id mutualFundId) {
        Id customerId = UserInfo.getUserId();
        AggregateResult[] results = [
            SELECT SUM(Invested_Amount__c) totalInvested
            FROM IE_Mutual_Fund_Holding__c
            WHERE IE_Customer__c IN (
                SELECT Id 
                FROM IE_Customer__c 
                WHERE User__c = :customerId
            ) AND IE_Mutual_Fund__c = :mutualFundId
        ];

        return results.isEmpty() ? 0 : (Decimal) results[0].get('totalInvested');
    }
}
