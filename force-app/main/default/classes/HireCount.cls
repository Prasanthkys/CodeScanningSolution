public with sharing class HireCount {
    
    @AuraEnabled(cacheable=true)
    public static List<PlacementWrapper> getPlacements(String filterType, String selectedValue) {
        List<PlacementWrapper> placements = new List<PlacementWrapper>();
        String query;
        List<AggregateResult> results;
        Map<Integer, Integer> yearCounts = new Map<Integer, Integer>(); // Map to store year counts
        String selectedValueString = ''; // Initialize selectedValueString
        
        if (filterType == 'daily') {
            Date today = Date.today();
            query = 'SELECT DAY_ONLY(Submitted_On_Date__c) selectedDate, COUNT(Id) recordCount FROM Placement__c WHERE DAY_ONLY(Submitted_On_Date__c) = :today GROUP BY DAY_ONLY(Submitted_On_Date__c)';
        } else if (filterType == 'weekly') {
            query = 'SELECT WEEK_IN_YEAR(Submitted_On_Date__c) selectedValue, COUNT(Id) recordCount FROM Placement__c WHERE Submitted_On_Date__c = THIS_WEEK GROUP BY WEEK_IN_YEAR(Submitted_On_Date__c)';
        } else if (filterType == 'monthly') {
            Integer monthValue = Integer.valueOf(selectedValue);
            Date startOfMonth = Date.newInstance(Date.today().year(), monthValue, 1);
            Date endOfMonth = startOfMonth.addMonths(1).addDays(-1);
            query = 'SELECT CALENDAR_MONTH(Submitted_On_Date__c) selectedMonth, COUNT(Id) recordCount FROM Placement__c WHERE Submitted_On_Date__c >= :startOfMonth AND Submitted_On_Date__c <= :endOfMonth GROUP BY CALENDAR_MONTH(Submitted_On_Date__c)';
            selectedValueString = getMonthName(monthValue); // Set selectedValueString for monthly filter
        } else if (filterType == 'yearly') {
            Integer yearValue = Integer.valueOf(selectedValue);
            Date startOfYear = Date.newInstance(yearValue, 1, 1);
            Date endOfYear = startOfYear.addYears(1).addDays(-1);
            query = 'SELECT CALENDAR_YEAR(Submitted_On_Date__c) selectedValue, COUNT(Id) recordCount FROM Placement__c WHERE Submitted_On_Date__c >= :startOfYear AND Submitted_On_Date__c <= :endOfYear GROUP BY CALENDAR_YEAR(Submitted_On_Date__c)';
            selectedValueString = String.valueOf(yearValue); // Set selectedValueString for yearly filter
        } else if (filterType == 'last5years') {
            List<Integer> lastFiveYears = getLastFiveYears();
            query = 'SELECT CALENDAR_YEAR(Submitted_On_Date__c) selectedValue, COUNT(Id) recordCount FROM Placement__c WHERE CALENDAR_YEAR(Submitted_On_Date__c) IN :lastFiveYears GROUP BY CALENDAR_YEAR(Submitted_On_Date__c)';
            
            // Initialize map with all last five years and set initial counts to 0
            for (Integer year : lastFiveYears) {
                yearCounts.put(year, 0);
            }
        }
        
        results = Database.query(query);
        
        if (filterType == 'last5years') {
            // Update year counts map with actual data
            for (AggregateResult ar : results) {
                Integer year = (Integer) ar.get('selectedValue');
                Integer count = (Integer) ar.get('recordCount');
                yearCounts.put(year, count);
            }
            
            // Add all years to placements list
            for (Integer year : yearCounts.keySet()) {
                placements.add(new PlacementWrapper(String.valueOf(year), yearCounts.get(year)));
            }
        } else if (results.isEmpty()) {
            // Handle other filters with no data found
            placements.add(new PlacementWrapper(selectedValueString, 0));
        } else {
            for (AggregateResult ar : results) {
                if (filterType == 'daily') {
                    // Date dateValue = (Date) ar.get('selectedDate');
                    // selectedValueString = dateValue.format(); // Default format 'yyyy-MM-dd'
                    selectedValueString = 'Current Day';
                } else if (filterType == 'weekly') {
                    selectedValueString = 'Current Week';
                } else if (filterType == 'monthly') {
                    Integer monthNumber = (Integer) ar.get('selectedMonth');
                    selectedValueString = getMonthName(monthNumber);
                } else {
                    selectedValueString = String.valueOf(ar.get('selectedValue'));
                }
                placements.add(new PlacementWrapper(selectedValueString, (Integer)ar.get('recordCount')));
            }
        }
        
        return placements;
    }
    
    private static List<Integer> getLastFiveYears() {
        Integer currentYear = Date.today().year();
        List<Integer> lastFiveYears = new List<Integer>();
        for (Integer i = 0; i < 5; i++) {
            lastFiveYears.add(currentYear - i);
        }
        return lastFiveYears;
    }

    private static String getMonthName(Integer monthNumber) {
        switch on monthNumber {
            when 1 { return 'January'; }
            when 2 { return 'February'; }
            when 3 { return 'March'; }
            when 4 { return 'April'; }
            when 5 { return 'May'; }
            when 6 { return 'June'; }
            when 7 { return 'July'; }
            when 8 { return 'August'; }
            when 9 { return 'September'; }
            when 10 { return 'October'; }
            when 11 { return 'November'; }
            when 12 { return 'December'; }
            when else { return 'Unknown'; }
        }
    }
    
    public class PlacementWrapper {
        @AuraEnabled public String selectedValue;
        @AuraEnabled public Integer count;
        
        public PlacementWrapper(String selectedValue, Integer count) {
            this.selectedValue = selectedValue;
            this.count = count;
        }
    }
}