public class FileComparison {
    
    public static void compareFilesAndGenerateReport() {
        // 1. Retrieve the latest two files
        List<ContentDocument> documents = [
            SELECT Id, Title
            FROM ContentDocument
            WHERE Title = 'Code Scanner Delta Report_CodeScanningSolution_main_Jira Story1'
            ORDER BY CreatedDate DESC
            LIMIT 2
        ];
        
        if (documents.size() < 2) {
            System.debug('Not enough files found.');
            return;
        }
        
        ContentVersion file1 = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId = :documents[0].Id LIMIT 1];
        ContentVersion file2 = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId = :documents[1].Id LIMIT 1];
        
        String content1 = file1.VersionData.toString();
        String content2 = file2.VersionData.toString();
        
        // 2. Parse the file content into rows
        List<String[]> rowsFile1 = parseCSV(content1);
        List<String[]> rowsFile2 = parseCSV(content2);
        
        // 3. Find unique rows
        Set<String> uniqueRowsFile1 = new Set<String>();
        Set<String> uniqueRowsFile2 = new Set<String>();
        
        for (String[] row : rowsFile1) {
            String rowString = convertRowToString(row);
            if (!containsRow(rowsFile2, row)) {
                uniqueRowsFile1.add(rowString);
            }
        }
        
        for (String[] row : rowsFile2) {
            String rowString = convertRowToString(row);
            if (!containsRow(rowsFile1, row)) {
                uniqueRowsFile2.add(rowString);
            }
        }
        
        // Convert sets to lists for joining
        List<String> uniqueRowsFile1List = new List<String>(uniqueRowsFile1);
        List<String> uniqueRowsFile2List = new List<String>(uniqueRowsFile2);
        
        // 4. Create a new CSV with unique rows
        String csvContent = 'Problem,Severity,File,Line,Column,Rule,Description,URL,Category,Engine\n';
        csvContent += String.join(uniqueRowsFile1List, '\n') + '\n';
        csvContent += String.join(uniqueRowsFile2List, '\n');
        
        // Save the new CSV file to Salesforce
        ContentVersion newFile = new ContentVersion();
        newFile.Title = 'Unique_Rows_Report.csv';
        newFile.PathOnClient = 'Unique_Rows_Report.csv';
        newFile.VersionData = Blob.valueOf(csvContent);
        newFile.IsMajorVersion = true;
        insert newFile;
        
        System.debug('New file created with unique rows.');
    }
    
    private static List<String[]> parseCSV(String csvContent) {
        List<String[]> rows = new List<String[]>();
        String[] lines = csvContent.split('\n');
        
        for (Integer i = 1; i < lines.size(); i++) {
            String[] columns = lines[i].split(',');
            rows.add(columns);
        }
        
        return rows;
    }
    
    private static String convertRowToString(String[] row) {
        return String.join(row, ',');
    }
    
    private static Boolean containsRow(List<String[]> rows, String[] targetRow) {
        for (String[] row : rows) {
            if (row.equals(targetRow)) {
                return true;
            }
        }
        return false;
    }
    public static void Test(){
        System.debug('test');
    }
}
