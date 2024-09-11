trigger FileComparisonTrigger on ContentVersion (after insert) {
    // Prevent recursion
    if (FileComparison.isProcessing) {
        return;
    }
    FileComparison.isProcessing = true;

    try {
        // List to hold relevant ContentVersions
        List<ContentVersion> relevantFiles = new List<ContentVersion>();

        // Collect ContentVersion records with the specific title pattern
        for (ContentVersion cv : Trigger.new) {
            if (cv.Title.contains('Code Scanner Delta Report_CodeScanningSolution_main_Jira Story1')) {
                relevantFiles.add(cv);
            }
        }

        // Ensure we have the necessary number of files to compare
        if (relevantFiles.size() >= 2) {
            // Call the FileComparison class method with relevant files
            FileComparison.compareFilesAndGenerateReport();
        } else {
            System.debug('Not enough files to compare.');
        }
    } catch (Exception e) {
        System.debug('Exception in trigger: ' + e.getMessage());
    } finally {
        // Reset processing flag
        FileComparison.isProcessing = false;
    }
}

