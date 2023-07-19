#!/bin/bash
#SBATCH --job-name=bam_to_fastq
#SBATCH --output=bam_to_fastq_%a.out
#SBATCH --error=bam_to_fastq_%a.err
#SBATCH --partition=dynamic-8cores-16g
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:05:00
#SBATCH --array=1-1207%20
#SBATCH --mail-user=iris.mestres@alum.esci.upf.edu
#SBATCH --mail-type=ALL

source /path/to/.bashrc
mamba activate mirflowz

output_dir=/path/to/samples

# Traverse to samples directory
cd /path/to/TCGA-BRCA/bam_miRNA

# Get and traverse to samples subdirectory
subdir=$(find . -mindepth 1 -maxdepth 1 -type d | sed -n ${SLURM_ARRAY_TASK_ID}p)

if [[ -z "$subdir" ]]; then
    echo "No subdirectory found for task ID ${SLURM_ARRAY_TASK_ID}"
    exit 1
fi

echo "Converting BAM file to FASTQ format in $subdir..."
cd "$subdir"

# Find BAM file
bamfile=$(find . -maxdepth 1 -type f -name "*.bam")

if [[ -z "$bamfile" ]]; then
    echo "No BAM file found in $subdir"
    exit 1
fi

# Set output filename
fastqfile=$(basename "$bamfile" .bam).fastq

# Convert BAM to FASTQ
samtools fastq "$bamfile" > "$output_dir/$fastqfile"
echo "Converted $bamfile to $output_dir/$fastqfile"

# Compress FASTQ
gzip "$output_dir/$fastqfile"
echo "Compressed $output_dir/$fastqfile.gz"

