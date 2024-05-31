public with sharing class NavDataController {
    @AuraEnabled(cacheable=true)
    public static List<NavData> getNavData() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.mfapi.in/mf/120843');
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            // Deserialize the response into a map
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            // Extract the data key which contains the list of NAV data
            List<Object> navList = (List<Object>) responseBody.get('data');
            List<NavData> navDataList = new List<NavData>();

            // Iterate over the list and map each item to NavData
            for (Object item : navList) {
                Map<String, Object> navItem = (Map<String, Object>) item;
                NavData data = new NavData();
                data.navDate = (String) navItem.get('date');
                data.navValue = Decimal.valueOf((String) navItem.get('nav'));
                navDataList.add(data);
            }

            return navDataList;
        } else {
            throw new AuraHandledException('Error fetching NAV data: ' + response.getStatus());
        }
    }

    public class NavData {
        @AuraEnabled public String navDate { get; set; }
        @AuraEnabled public Decimal navValue { get; set; }
    }
}
