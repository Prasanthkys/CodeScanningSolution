public class FileComparison {

    // List of columns to compare
    private static final List<String> COLUMNS = new List<String>{
        'Problem', 'Severity', 'File', 'Line', 'Column', 'Rule', 'Description', 'URL', 'Category', 'Engine'
    };

    public static void compareFiles() {
        String filePattern = 'Code Scanner Delta Report_CodeScanningSolution_main_Jira Story1';
        
        // Fetch the two latest ContentVersions that match the file pattern
        List<ContentVersion> contentVersions = [
            SELECT Id, ContentDocumentId, Title, VersionData 
            FROM ContentVersion 
            WHERE Title LIKE :filePattern 
            ORDER BY CreatedDate DESC 
            LIMIT 2
        ];

        if (contentVersions.size() != 2) {
            System.debug('Error: Could not fetch exactly two files.');
            return;
        }

        // Read file contents
        String file1Content = contentVersions[0].VersionData.toString();
        String file2Content = contentVersions[1].VersionData.toString();

        // Parse CSV files
        List<Map<String, String>> file1Data = parseCSV(file1Content);
        List<Map<String, String>> file2Data = parseCSV(file2Content);

        // Compare files and get differences
        List<Map<String, String>> differences = compareData(file1Data, file2Data);

        if (differences.isEmpty()) {
            System.debug('No differences found.');
            return;
        }

        // Generate delta report
        String deltaReportContent = generateCSV(differences);
        
        // Store delta report in Salesforce
        storeDeltaReport(deltaReportContent);
    }

    private static List<Map<String, String>> parseCSV(String csvContent) {
        List<Map<String, String>> parsedData = new List<Map<String, String>>();
        String[] rows = csvContent.split('\n');
        
        if (rows.size() > 0) {
            // Extract headers
            String[] headers = rows[0].split(',');

            for (Integer i = 1; i < rows.size(); i++) {
                String row = rows[i];
                if (row != null && row.trim() != '') {
                    String[] values = row.split(',');
                    if (values.size() == headers.size()) {
                        Map<String, String> rowMap = new Map<String, String>();
                        for (Integer j = 0; j < headers.size(); j++) {
                            rowMap.put(headers[j].trim(), values[j].trim());
                        }
                        parsedData.add(rowMap);
                    }
                }
            }
        }
        
        return parsedData;
    }

    private static List<Map<String, String>> compareData(List<Map<String, String>> file1Data, List<Map<String, String>> file2Data) {
        List<Map<String, String>> differences = new List<Map<String, String>>();

        // Create a map to track file2 rows by key
        Map<String, Map<String, String>> file2Map = new Map<String, Map<String, String>>();
        for (Map<String, String> row : file2Data) {
            String key = generateKey(row); // Generate a unique key based on all columns
            file2Map.put(key, row);
        }

        // Compare rows from file1 to file2
        for (Map<String, String> row1 : file1Data) {
            String key1 = generateKey(row1); // Generate a unique key based on all columns
            Map<String, String> row2 = file2Map.get(key1);

            if (row2 != null) {
                Boolean rowDifferent = false;
                for (String column : COLUMNS) {
                    if (row1.containsKey(column) && row2.containsKey(column)) {
                        if (!row1.get(column).equals(row2.get(column))) {
                            rowDifferent = true;
                            break;
                        }
                    }
                }

                if (rowDifferent) {
                    differences.add(row1);
                }
            } else {
                differences.add(row1);
            }
        }

        // Check for rows in file2 that are not in file1
        for (Map<String, String> row2 : file2Data) {
            String key2 = generateKey(row2); // Generate a unique key based on all columns
            if (!file2Map.containsKey(key2)) {
                differences.add(row2);
            }
        }

        return differences;
    }

    private static String generateKey(Map<String, String> row) {
        // Concatenate all column values to generate a unique key
        String key = '';
        for (String column : COLUMNS) {
            if (row.containsKey(column)) {
                key += row.get(column) + '|'; // Use a delimiter to separate column values
            }
        }
        return key;
    }

    private static String generateCSV(List<Map<String, String>> data) {
        if (data.isEmpty()) return '';

        // Manually construct CSV content
        String csvContent = '';
        
        // Add headers
        csvContent += buildCSVRow(COLUMNS) + '\n'; 
        
        // Add rows
        for (Map<String, String> row : data) {
            List<String> rowValues = new List<String>();
            for (String column : COLUMNS) {
                rowValues.add(row.containsKey(column) ? row.get(column) : ''); 
            }
            csvContent += buildCSVRow(rowValues) + '\n'; 
        }
        
        return csvContent;
    }

    private static String buildCSVRow(List<String> values) {
        // Manually build a CSV row with quoted values to handle commas
        String row = '';
        for (String value : values) {
            row += '"' + value.replace('"', '""') + '",'; // Escape double quotes
        }
        return row.length() > 0 ? row.substring(0, row.length() - 1) : ''; // Remove last comma
    }

    private static void storeDeltaReport(String content) {
        try {
            ContentVersion newFile = new ContentVersion();
            newFile.Title = 'Code Scanner Delta Report_main';
            newFile.PathOnClient = 'CodeScannerDeltaReport.csv';
            newFile.VersionData = Blob.valueOf(content);
            
            // Insert ContentVersion record
            insert newFile;
            
            System.debug('Success!!!!');
            System.debug('Delta report successfully stored in Salesforce.');
        } catch (DmlException e) {
            System.debug('Error storing delta report: ' + e.getMessage());
            // Optionally log more details or take additional actions
        }
    }
}
