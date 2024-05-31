public with sharing class NavDataControllercopy {
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

            // Sort the navDataList by navDate in ascending order
            navDataList.sort(new NavDataComparator());

            return navDataList;
        } else {
            throw new AuraHandledException('Error fetching NAV data: ' + response.getStatus());
        }
    }

    public class NavData {
        @AuraEnabled public String navDate { get; set; }
        @AuraEnabled public Decimal navValue { get; set; }
    }

    public class NavDataComparator implements Comparator<NavData> {
        public Integer compare(NavData a, NavData b) {
            Date dateA = parseDate(a.navDate);
            Date dateB = parseDate(b.navDate);
            if (dateA == dateB) return 0;
            else if (dateA > dateB) return 1;
            else return -1;
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
