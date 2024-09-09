import csv
import sys
import re

def extract_changed_lines(diff_file):
    changed_lines = set()
    with open(diff_file, 'r') as file:
        for line in file:
            match = re.match(r'^\+\d+,\d+\s', line)
            if match:
                line_numbers = match.group(0).strip().split(",")
                start_line = int(line_numbers[0].replace("+", ""))
                count = int(line_numbers[1]) if len(line_numbers) > 1 else 1
                changed_lines.update(range(start_line, start_line + count))
    return changed_lines

def filter_report_by_lines(scanner_report_file, changed_lines_file, output_file):
    changed_lines = extract_changed_lines(changed_lines_file)
    
    filtered_issues = []
    with open(scanner_report_file, mode='r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            line_number = int(row['Line'])
            if line_number in changed_lines:
                filtered_issues.append(row)

    if filtered_issues:
        fieldnames = filtered_issues[0].keys()
        with open(output_file, mode='w', newline='') as file:
            writer = csv.DictWriter(file, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(filtered_issues)
    else:
        print(f"No issues found in changed lines.")

if __name__ == "__main__":
    changed_lines_file = sys.argv[1]
    scanner_report_file = sys.argv[2]
    output_file = sys.argv[3]
    
    filter_report_by_lines(scanner_report_file, changed_lines_file, output_file)