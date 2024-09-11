trigger FileComparisionTrigger on ContentVersion (after insert) {
    for (ContentVersion cv : Trigger.new) {
        if (cv.Title.contains('Code Scanner Delta Report_CodeScanningSolution_main_Jira Story1')) {
            // Execute the FileComparison class method
            FileComparison.compareFilesAndGenerateReport();
        }
    }
}
