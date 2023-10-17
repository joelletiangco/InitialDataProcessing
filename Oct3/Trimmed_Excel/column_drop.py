import os
import pandas as pd

# Define the folder path
folder_path = "resampled_data"

print('Hello World')
# Function to process a CSV file
def process_csv(file_path):
    # Extract the file name
    file_name = os.path.basename(file_path)
    if file_name.startswith('._'):
        return
    print(f'Currently processing: {file_name}')
    
    # Read the CSV into a DataFrame
    df = pd.read_csv(file_path)
    
    # Determine which columns to drop based on file name
    if "left" in file_name:
        columns_to_drop = [col for col in df.columns if col.startswith("R")]
    elif "right" in file_name:
        columns_to_drop = [col for col in df.columns if col.startswith("L")]
    else:
        # Handle other cases or skip the file
        return
    
    # Drop the specified columns
    df = df.drop(columns=columns_to_drop)
    
    # Save the modified DataFrame back to the same file
    df.to_csv(file_path, index=False)

# Traverse the folder and process each CSV file
for root, dirs, files in os.walk(folder_path):
    for file in files:
        if file.endswith(".csv"):
            file_path = os.path.join(root, file)
            process_csv(file_path)

print('Goodbye')
