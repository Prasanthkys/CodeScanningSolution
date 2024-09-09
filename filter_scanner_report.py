import os

def filter_report_by_lines(scanner_report_file, changed_lines_file, output_file):
    if not os.path.isfile(scanner_report_file):
        raise FileNotFoundError(f"The file {scanner_report_file} does not exist.")
    
    # Your existing logic to filter the report

# Example usage
if __name__ == "__main__":
    import sys
    if len(sys.argv) != 4:
        print("Usage: python filter_scanner_report.py <changed_lines_file> <scanner_report_file> <output_file>")
        sys.exit(1)
    
    changed_lines_file = sys.argv[1]
    scanner_report_file = sys.argv[2]
    output_file = sys.argv[3]
    
    filter_report_by_lines(scanner_report_file, changed_lines_file, output_file)