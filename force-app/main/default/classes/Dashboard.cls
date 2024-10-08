public with sharing class Dashboard {
    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getSubmittedCandidates(String filter, String selectedValue, Date customStartDate, Date customEndDate) {
        Date today = Date.today();
        Date startDate;
        Date endDate;

        if (filter == 'daily') {
            startDate = today;
            endDate = today;
        } else if (filter == 'weekly') {
            startDate = today.toStartOfWeek();
            endDate = startDate.addDays(6);
        } else if (filter == 'monthly') {
            Integer month = Integer.valueOf(selectedValue);
            Integer year = today.year();
            startDate = Date.newInstance(year, month, 1);
            endDate = Date.newInstance(year, month, daysInMonth(year, month));
        } else if (filter == 'yearly') {
            Integer year = Integer.valueOf(selectedValue);
            startDate = Date.newInstance(year, 1, 1);
            endDate = Date.newInstance(year, 12, 31);
        }else if (filter == 'custom') {
            if (customStartDate != null && customEndDate != null) {
                startDate = customStartDate;
                endDate = customEndDate;
            } else {
                throw new IllegalArgumentException('Custom dates must be provided for the custom filter');
            }
        } else {
            startDate = today; // Default to today if no valid filter
            endDate = today;
        }

        system.debug('Start Date: ' + startDate + ', End Date: ' + endDate);
        
        // Return the query results
        return [SELECT Sales_Team_Member__c, COUNT(Id) Job_Submitted__c 
                FROM Job_Submission__c 
                WHERE Job_Submitted__c = TRUE 
                  AND Submitted_On__c >= :startDate 
                  AND Submitted_On__c <= :endDate
                GROUP BY Sales_Team_Member__c];
    }

    // Helper method to get the number of days in a month for a given year and month
    public static Integer daysInMonth(Integer year, Integer month) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            return 31;
        } else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30;
        } else if (month == 2) {
            return Date.isLeapYear(year) ? 29 : 28;
        } else {
            throw new IllegalArgumentException('Invalid month: ' + month);
        }
    }


    @AuraEnabled(cacheable=true)
    public static List<Job_Information__c> getJobInformationForSubmittedCandidates(String submittedByName) {
       
        List<Job_Information__c> jobInformationList = [SELECT id,Vendor_Name__c,Submitted_By__c,Consultant_Name__c,Consultant_Email__c,Job_Code__c,Client_Name__c,Job_Title__c,Phone_Number__c,Location__c,Status_Changed_On_Date__c
            FROM Job_Information__c
            WHERE Submitted_By__c = :submittedByName];
        system.debug(submittedByName+'test'+jobInformationList);
        return jobInformationList;
    }

}