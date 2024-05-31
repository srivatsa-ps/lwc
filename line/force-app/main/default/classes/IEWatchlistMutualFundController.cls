public with sharing class IEWatchlistMutualFundController {
    @AuraEnabled(cacheable=true)
    public static List<IE_Mutual_Fund__c> getWatchlistFunds() {
        // Query to find the watchlist for the current user
        List<IE_Watchlist__c> userWatchlist = [
            SELECT Id
            FROM IE_Watchlist__c
            WHERE OwnerId = :UserInfo.getUserId()
            LIMIT 1
        ];

        if (userWatchlist.isEmpty()) {
            return new List<IE_Mutual_Fund__c>();
        }

        Id watchlistId = userWatchlist[0].Id;

        // Query to get the mutual funds in the user's watchlist
        List<IE_WL_Item__c> watchlistItems = [
            SELECT IE_Mutual_Fund__c, IE_Mutual_Fund__r.Name, IE_Mutual_Fund__r.Minimum_SIP__c, IE_Mutual_Fund__r.Net_Asset_Value__c
            FROM IE_WL_Item__c
            WHERE IE_Watchlist__c = :watchlistId
        ];

        List<IE_Mutual_Fund__c> funds = new List<IE_Mutual_Fund__c>();
        for (IE_WL_Item__c item : watchlistItems) {
            funds.add(new IE_Mutual_Fund__c(
                Name = item.IE_Mutual_Fund__r.Name,
                Minimum_SIP__c = item.IE_Mutual_Fund__r.Minimum_SIP__c,
                Net_Asset_Value__c = item.IE_Mutual_Fund__r.Net_Asset_Value__c
            ));
        }

        return funds;
    }
}
