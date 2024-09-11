trigger FileComparisionTrigger on ContentVersion (after insert) {
    if (!FileComparison.isProcessing) {
        FileComparison.isProcessing = true;
        for (ContentVersion cv : Trigger.new) {
            if (cv.Title.contains('Code Scanner Delta Report_CodeScanningSolution_main_Jira Story1')) {
                // Execute the FileComparison class method
                FileComparison.compareFilesAndGenerateReport();
            }
        }
        FileComparison.isProcessing = false; // Reset after processing
    }
}
