# Data Preparation

In this directory, you can find the three bash scripts used in the cluster to
prepare the sample files and test the workflow.

> NOTE: For security reasons, all the paths within the scripts will be changed
as to only show the final file/directory.

## `bam2fastq.sh`

As samples data was provided in `BAM` format, but the workflow only allows
`FASTQ` files, the conversion from one to another was a must. One thing to 
account for when building the script was the directory structure.

TCGA-BRCA
├── bam_miRNA
│   ├── sample_1
│   │   ├── sample_1.bam
│   │   ├── other_sample_1_data_file
│   ├── sample_2
│   │   ├── sample_2.bam
│   │   ├── other_sample_2_data_file
│   ├── sample_3
│   │   ├── sample_3.bam
│   │   ├── other_sample_3_data_file

From each `sample_#` subdirectory only the `BAM` was required. Thus, the script
had to access each `sample_#` subdirectory, make the conversion, save the file
in a separate directory and return to the parent directory.

Another choice taken was o use the [Conda][conda] environment `mirflowz`
rather than the available [samtools][samtools] module in the cluster as it
required less commands and configuration.


## `samples_10_table.sh` and `all_samples_table.sh`

`MIRFLOWZ` takes samples as input in a table format: one row per sample, one
column for the field `sample`, `sample_file`, `adapter` and `format`. There was
a total of 1207 samples and the workflow had not been tested with real data.
The first approach then, was to test the workflow with a small amount of
samples and after success, repeat the process for all the rest of the samples.
At the end, and once the workflow was tested the approach taken was to create
a single table with all the samples, hence the two scripts.

Moreover, provided that the sample reads were already preprocessed, at least
for adaptor trimming, but the workflow has an unavoidable adaptor trimming
step, the adaptor string value of `XXXXXXXXX`. This way, there won't be any
further trimming applied.

`samples_10_table.sh` takes all the sample file names and creates different
tables of 10 rows each, all of which are stored in a separated subdirectory.

`all_samples_table.sh` take all sample file names and creates a single table
which will be stored in the same directory as the sample files are.



[conda]: <https://docs.conda.io/en/latest/>
[samtools]: <http://www.htslib.org/doc/samtools.html>
