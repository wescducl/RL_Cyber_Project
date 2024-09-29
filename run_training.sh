#!/bin/bash

# Prompt user for the training configuration file
echo "Please enter the path to the training config file:"
read training_config

# Check if the file exists
if [ ! -f "$training_config" ]; then
  echo "Training config file '$training_config' not found."
  exit 1
fi

# Extract the base filename from the training config to use in the log file name
base_filename=$(basename "$training_config" .yaml)
log_file="${base_filename}_curriculum_output.txt"

# List of laydown files
laydowns=("stage1_laydown.yaml" "stage2_laydown.yaml" "stage3_laydown.yaml")

# Create or clear the log file
echo "Running training with $training_config" > "$log_file"

# Loop through each laydown file and run the Primaite session
for laydown in "${laydowns[@]}"; do
  # Check if the laydown file exists
  if [ ! -f "$laydown" ]; then
    echo "Laydown file '$laydown' not found. Skipping." | tee -a "$log_file"
    continue
  fi

  # Log the start of the session for this laydown
  echo "Running session with laydown: $laydown" | tee -a "$log_file"

  # Run the Primaite session and append output to the log file
  primaite session --tc "$training_config" --ldc "$laydown" >> "$log_file" 2>&1

  # Check if the command was successful
  if [ $? -eq 0 ]; then
    echo "Session for $laydown completed successfully." | tee -a "$log_file"
  else
    echo "Error occurred during session for $laydown." | tee -a "$log_file"
  fi
done

echo "All sessions completed. Logs saved to $log_file."
