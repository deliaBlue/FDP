#!/bin/bash

# set dirs
input_dir="/path/to/samples"
output_dir="/path/to/samples/tables"

mkdir -p "$output_dir"

# file paths array
file_paths=("$input_dir"/*.fastq.gz)

num_files=${#file_paths[@]}
files_per_output=10
num_outputs=$((num_files / files_per_output + 1))


# create samples tables (10 sample per table)
for (( i=0; i<num_outputs; i++ )); do

  start_idx=$((i * files_per_output))
  output_file="$output_dir/samples_table_$i.csv"

  # table header
  echo -e "sample\tsample_file\tadapter\tformat" > "$output_file"
  
  for (( j=start_idx; j<start_idx+files_per_output && j<num_files; j++ )); do
  
    file="${file_paths[j]}"
    sample=$(basename "$file" .fastq.gz | sed 's/^TCGA-//; s/_.*//')
   
    echo -e "$sample\t../../samples/$(basename "$file")\tXXXXXXXXXX\tfastq" >> "$output_file"
  
  done
done

