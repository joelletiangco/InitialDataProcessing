import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import stats
from statsmodels.stats.diagnostic import lilliefors

print('Hello World\n')

# Define the folder path
folder_path = 'resampled_data_col_dropped'

# Lists to store the results
normally_distributed_vars = []
not_normally_distributed_vars = []

# Function to process a CSV file
def process_csv(file_path):
    file_name = os.path.basename(file_path)
    if not file_name.startswith('._'):
        df = pd.read_csv(file_path)
        return df

# Function to perform the Shapiro-Wilk normality test
# normality_test = 'Shapiro-Wilk'
normality_test = 'Anderson'
# normality_test = 'Kolmogorov-Smirnov'
# normality_test = 'Lilliefors'

def perform_normality_test(data, col_name):
    # stat, p = stats.shapiro(data)
    stat, p = stats.anderson(data)
    # stat, p = stats.kstest(data, 'norm')
    # stat, p = lilliefors(data)

    alpha = 0.05  # Set your desired significance level

    print(f'{normality_test} normality test for', col_name, ':')
    print('Statistic:', '{:.4f}'.format(stat))
    print('P-value:', '{:.8f}'.format(p))

    if p > alpha:
        print(col_name, 'is normally distributed.')
        normally_distributed_vars.append(col_name)
    else:
        print(col_name, 'is not normally distributed.')
        not_normally_distributed_vars.append(col_name)

# Traverse the folder and process each CSV file
# condition = 'shod'
# condition = 'barefoot'
# condition = 'orthotics'
num_csv = 0
num_row_stacks = 0

for root, dirs, files in os.walk(folder_path):
    for file in files:
        # if file.endswith('.csv') and condition in file:
        if file.endswith('.csv'):
            
            
            file_path = os.path.join(root, file)
            file_name = os.path.basename(file_path)
            # skip empty files (power x and power y are empty)
            if file_name.startswith('._'):
                continue
            num_csv += 1
            print(f'file_path: {file_path}')
            print(f'file_name: {file_name}')
            data = process_csv(file_path)
            data_arr = np.asarray(data)
            data_mean = np.mean(data_arr, axis=0)
            data_mean = data_mean.reshape(1,-1)

            print(f'\nshape of reshaped data_mean: {data_mean.shape}')
            
            if 'stacked_data' not in locals():
                #stacked_data = data_arr
                stacked_data = data_mean
                print(f'shape of stacked_data: {stacked_data.shape}\n')
            else:
                stacked_data = np.row_stack((stacked_data, data_mean))
                num_row_stacks += 1

print(f'NUMBER OF CSV FILES: {num_csv}')
print(f'NUMBER OF ROW STACKS: {num_row_stacks}')
num_cols = stacked_data.shape[1]
col_names = data.columns.values

# Make an output directory to save csvs
output_dir = 'nov1_output_data'
if not os.path.exists(output_dir):
    os.makedirs(output_dir)


# Make a subfolder within the output directory
subfolder = 'all_conditions'
subfolder_path = os.path.join(output_dir, subfolder)

if not os.path.exists(subfolder_path):
    os.makedirs(subfolder_path)

output_csv = 'all_mean.csv'
output_csv_path = os.path.join(output_dir, subfolder, output_csv)
# np.savetxt(output_csv_path, stacked_data, delimiter=',', header=col_names)
np.savetxt(output_csv_path, stacked_data, delimiter=',')

print('\nGoodbye!\n')



# Make an output directory to save histograms
# output_dir = 'histograms_v1'
# if not os.path.exists(output_dir):
#     os.makedirs(output_dir)



# Create histograms and perform normality test
# histograms:
# for i in range(num_cols):
#     col_data = stacked_data[:, i]
#     col_name = col_names[i]

#     plt.figure()
#     plt.hist(col_data, bins=150)
#     plt.title('Histogram: ' + col_name)
#     plt.savefig(os.path.join(output_dir, 'histogram_' + col_name + '.png'))
#     plt.close()
# print('\nFinished creating histograms.\n')




