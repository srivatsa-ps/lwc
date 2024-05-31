public with sharing class IEMutualFundController {
    @AuraEnabled(cacheable=true)
    public static MutualFundWrapper getMutualFundDetails(String schemeCode) {
        // Fetch Mutual Fund details from the Salesforce database, including NAV_History__c
        IE_Mutual_Fund__c mutualFund = [
            SELECT Name, Minimum_SIP__c, Net_Asset_Value__c, NAV_History__c
            FROM IE_Mutual_Fund__c
            WHERE API_Scheme_Code__c = :schemeCode
            LIMIT 1
        ];

        List<NavData> navDataList = new List<NavData>();
        
        // Deserialize NAV_History__c
        if (mutualFund.NAV_History__c != null) {
            List<Object> navList = (List<Object>) JSON.deserializeUntyped(mutualFund.NAV_History__c);
            
            for (Object item : navList) {
                Map<String, Object> navItem = (Map<String, Object>) item;
                NavData data = new NavData();
                data.navDate = (String) navItem.get('navDate');
                data.navValue = Decimal.valueOf((String) String.valueOf(navItem.get('navValue')));
                navDataList.add(data);
            }

            navDataList.sort(new NavDataComparator());

            // Keep only the most recent 30 days
            List<NavData> recentNavDataList = new List<NavData>();
            for (Integer i = 0; i < 30 && i < navDataList.size(); i++) {
                recentNavDataList.add(navDataList[i]);
            }

            navDataList = recentNavDataList;
        }

        // Prepare the wrapper to return both mutual fund details and NAV data
        MutualFundWrapper wrapper = new MutualFundWrapper();
        wrapper.mutualFund = mutualFund;
        wrapper.navData = navDataList;

        // Check if mutual fund is already in the user's watchlist
        wrapper.isInWatchlist = [
            SELECT Id
            FROM IE_WL_Item__c
            WHERE IE_Mutual_Fund__c = :mutualFund.Id
            AND CreatedById = :UserInfo.getUserId()
            LIMIT 1
        ].size() > 0;

        return wrapper;
    }

    @AuraEnabled
    public static void addToWatchlist(String mutualFundId) {
        // Check if the mutual fund is already in the user's watchlist
        List<IE_WL_Item__c> existingItems = [
            SELECT Id
            FROM IE_WL_Item__c
            WHERE IE_Mutual_Fund__c = :mutualFundId
            AND CreatedById = :UserInfo.getUserId()
            LIMIT 1
        ];

        if (existingItems.isEmpty()) {
            // Check if a watchlist exists for the user
            List<IE_Watchlist__c> userWatchlist = [
                SELECT Id
                FROM IE_Watchlist__c
                WHERE CreatedById = :UserInfo.getUserId()
                LIMIT 1
            ];

            Id watchlistId;
            if (userWatchlist.isEmpty()) {
                // Create a new watchlist if none exists
                IE_Watchlist__c newWatchlist = new IE_Watchlist__c();
                insert newWatchlist;
                watchlistId = newWatchlist.Id;
            } else {
                watchlistId = userWatchlist[0].Id;
            }

            // Add the mutual fund to the watchlist
            IE_WL_Item__c newItem = new IE_WL_Item__c(
                IE_Mutual_Fund__c = mutualFundId,
                IE_Watchlist__c = watchlistId
            );
            insert newItem;
        } else {
            throw new AuraHandledException('Mutual fund is already in the watchlist.');
        }
    }

    public class NavData {
        @AuraEnabled public String navDate { get; set; }
        @AuraEnabled public Decimal navValue { get; set; }
    }

    public class MutualFundWrapper {
        @AuraEnabled public IE_Mutual_Fund__c mutualFund { get; set; }
        @AuraEnabled public List<NavData> navData { get; set; }
        @AuraEnabled public Boolean isInWatchlist { get; set; }
    }

    public class NavDataComparator implements Comparator<NavData> {
        public Integer compare(NavData a, NavData b) {
            Date dateA = parseDate(a.navDate);
            Date dateB = parseDate(b.navDate);
            if (dateA == dateB) return 0;
            else if (dateA > dateB) return -1; // Sort in descending order
            else return 1;
        }

        private Date parseDate(String dateStr) {
            List<String> parts = dateStr.split('-');
            Integer day = Integer.valueOf(parts[0]);
            Integer month = Integer.valueOf(parts[1]);
            Integer year = Integer.valueOf(parts[2]);
            return Date.newInstance(year, month, day);
        }
    }
}
