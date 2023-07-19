#!/bin/bash

# set directories
input_dir="/path/to/samples"
output_file="$input_dir/samples_table.csv"

# file paths array
file_paths=("$input_dir"/*.fastq.gz)
num_files=${#file_paths[@]}

# table header
echo -e "sample\tsample_file\tadapter\tformat" > "$output_file"

for (( i=0; i<num_files; i++ )); do
  
    file="${file_paths[i]}"
    sample=$(basename "$file" .fastq.gz | sed 's/^TCGA-//; s/_.*//')

    echo -e "$sample\t../../samples/$(basename "$file")\tXXXXXXXXXX\tfastq" >> "$output_file"

done
