# FDP

This repository includes the scripts for performing the isomiR quantification
and their profiles analysis in the Final Degree Project: 

_MIRFLOWZ: miRNA isoforms quantification and profiles in breast cancer._


## MIRFLOWZ Scripts

This directory holds the individual scripts embed in the `MIRFLOWZ` workflow,
along with their unit tests. During the features addition and refactoring of
the pipeline, several rules were added. To see the whole project along with
the code modifications I made, refer to the [MIRFLOWZ][mirflowz] repository.
Other project-related codes can be found in the same repository under the branch
`mirna_accounting` and in the [oligomap][oligomap] repository. The former, was
build from a `C++` script as a means to construct its [Bioconda][bioconda]
package.

> NOTE: `MIRFLOWZ` is a work-in-progress. Although the workflow is functional,
there are things yet to be optimized and implemented.


## Data Preparation

This directory includes the `bash` scripts used to turn the sample files into
the required format for the workflow.


## Expression Analysis

This directory will include the `R` script used in the expression analysis
along with a script with the codes used for the different plots used in both reports.

[bioconda]: <https://bioconda.github.io>
[mirflowz]: <https://github.com/zavolanlab/mirflowz>
[oligomap]: <https://github.com/zavolanlab/oligomap>
