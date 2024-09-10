import argparse
import networkx as nx
import pandas as pd
import matplotlib.pyplot as plt

def parse_diff(diff_file):
    with open(diff_file, 'r') as file:
        lines = file.readlines()
    
    changed_lines = []
    for line in lines:
        if line.startswith('+++ ') or line.startswith('--- '):
            continue
        if line.startswith('@@ '):
            continue
        if line.startswith('+'):
            changed_lines.append(line[1:].strip())
    
    return changed_lines

def perform_analysis(changed_lines):
    # Example: Create a graph where each line is a node
    G = nx.Graph()
    
    # Add nodes and edges based on changed lines
    for line in changed_lines:
        G.add_node(line)
        # Example logic: add edges based on some heuristic or criteria
        # G.add_edge(...)

    return G

def main():
    parser = argparse.ArgumentParser(description='Analyze changed lines from a diff file.')
    parser.add_argument('--diff-file', type=str, required=True, help='Path to the diff file')
    parser.add_argument('--output', type=str, required=True, help='Path to the output CSV file')

    args = parser.parse_args()
    
    # Parse the diff file to get changed lines
    changed_lines = parse_diff(args.diff_file)
    
    # Perform graph analysis
    G = perform_analysis(changed_lines)
    
    # Export graph data to CSV (example: nodes and edges)
    with open(args.output, 'w') as file:
        writer = pd.ExcelWriter(file)
        # Example: Write nodes and edges to separate sheets
        nodes_df = pd.DataFrame(list(G.nodes), columns=['Node'])
        nodes_df.to_excel(writer, sheet_name='Nodes', index=False)
        edges_df = pd.DataFrame(list(G.edges), columns=['Source', 'Target'])
        edges_df.to_excel(writer, sheet_name='Edges', index=False)
        writer.save()
    
    print(f'Analysis complete. Results saved to {args.output}')

if __name__ == '__main__':
    main()