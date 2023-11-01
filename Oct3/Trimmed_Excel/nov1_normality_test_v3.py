import os
from matplotlib import pyplot as plt
import pandas as pd
import numpy as np
from scipy import stats
from statsmodels.stats.diagnostic import lilliefors

print('Hello World\n')

# Define the folder path
folder_path = 'nov1_output_data/all_conditions'

# SPECIFY CONDITION HERE (barefoot, shod, orthotics, all)
condition = 'all'
# CHANGE THE PARAMETER HERE (mean, max, min, ROM)
parameter = 'mean'
# specify normality test (shapiro, anderson, kstest, lilliefors)
normality_test = 'kstest'
# specify p/alpha value
alpha = 0.05

plot_histograms = True
input_csv_file_name = f'{condition}_{parameter}.csv'  # Input CSV filename


# make output directory to save histograms
folder_path = 'nov1_output_data/all_conditions'
histogram_output_dir = os.path.join(folder_path, 'histograms', parameter)
if not os.path.exists(histogram_output_dir):
    os.makedirs(histogram_output_dir)

# make an output directory to save normality results
normality_output_dir = os.path.join(folder_path, 'normality')
if not os.path.exists(normality_output_dir):
    os.makedirs(normality_output_dir)

# Create a new variable for the output CSV filename
output_csv_file_name = f'{condition}_{parameter}_{normality_test}_{str(alpha)}_results.csv'


# Lists to store the results
results = []

def perform_normality_test(data, col_name, alpha):
    if normality_test == 'anderson':
        stat, p = stats.anderson(data)
    elif normality_test == 'kstest':
        stat, p = stats.kstest(data, 'norm')
    # set the default to shapiro
    elif normality_test == 'lilliefors':
        stat, p = lilliefors(data)
    else:
        stat, p = stats.shapiro(data)

    print(f'{normality_test} normality test for', col_name, ':')
    print('Statistic:', '{:.4f}'.format(stat))
    print('P-value:', '{:.8f}'.format(p))

    is_normal = p > alpha  # Calculate whether it's normal based on the p-value

    result = {
        "Variable": col_name,
        "Statistic Value": stat,
        "P value": p,
        "Normal": is_normal,
    }

    results.append(result)

num_csv = 0
num_row_stacks = 0

# Load the specific input CSV file
input_csv_file_path = os.path.join(folder_path, input_csv_file_name)
data = pd.read_csv(input_csv_file_path)

for col_name in data.columns:
    # skip empty Power variables
    if 'Power_x' in col_name or 'Power_y' in col_name:
        continue
    col_data = data[col_name]
    perform_normality_test(col_data, col_name, alpha)

    if plot_histograms:
        plt.figure()
        plt.hist(col_data, bins=75)
        plt.title('Histogram: ' + col_name + ' (' + parameter + ')')
        plt.savefig(os.path.join(histogram_output_dir, 'histogram_' + col_name + '.png'))
        plt.close()

print(f'\nFinished performing normality tests for: {input_csv_file_name}.\n')

# Output the counts
condition = 'ALL'
print(f'Current condition: {condition}')
print('Total Normally Distributed Variables:', sum(1 for result in results if result["Normal"]))
print('Total Not Normally Distributed Variables:', sum(1 for result in results if not result["Normal"]))

# Convert the results to a DataFrame
results_df = pd.DataFrame(results)

# Save the results to the terminal
print(results_df)

# Save the results to the new output CSV file
output_csv_file_path = os.path.join(normality_output_dir, output_csv_file_name)
results_df.to_csv(output_csv_file_path, index=False)

print(f'Results saved in: {output_csv_file_path}')
print('\nGoodbye!\n')