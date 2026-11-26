# CAZySubstrateProfiler

![Genome-based predictions](https://img.shields.io/badge/Genome--based-predictions-blue)
![Carbohydrate degradation](https://img.shields.io/badge/Carbohydrate-degradation-green)
![CAZyme profiling](https://img.shields.io/badge/CAZyme-profiling-purple)
![CAZy families](https://img.shields.io/badge/CAZy-family%20annotations-orange)

**A genomic approach to infer bacterial carbohydrate degradation potential based on CAZyme annotations.**

CAZySubstrateProfiler is an R-based application designed to infer the potential carbohydrate degradation capabilities of bacterial genomes from carbohydrate-active enzyme (CAZyme) family annotations. The application uses predefined associations between CAZyme families and carbohydrate substrates, organized according to different levels of evidence.

## Overview

Carbohydrate degradation is an important metabolic capability of bacteria, contributing to the utilization of complex carbohydrates from different environmental sources.

CAZySubstrateProfiler provides a systematic and reproducible framework for profiling the potential carbohydrate degradation capabilities of bacterial genomes based on their CAZyme family annotations.

The application evaluates the presence of substrate-associated CAZyme families and classifies the resulting evidence into three levels: **core**, **support**, and **related**. These evidence levels are subsequently used to infer the potential degradation of specific carbohydrate substrates.

## Features

- Processing of CAZyme family annotations from multiple bacterial genomes.
- Identification of substrate-associated CAZyme families.
- Evidence-based classification using predefined CAZyme family associations.
- Inference of potential carbohydrate degradation capabilities.
- Generation of detailed substrate inference tables and genome-level classification matrices.

## Methodology

CAZySubstrateProfiler uses a predefined rules file (`CAZy_substrate_rules.csv`) to associate CAZyme families with specific carbohydrate substrates.

Each family is assigned to one of three evidence levels:

| Evidence level | Description |
|---|---|
| **Core** | CAZyme families considered primary evidence for a substrate. |
| **Support** | CAZyme families providing additional evidence for substrate degradation. |
| **Related** | CAZyme families associated with substrate degradation but providing indirect evidence. |

Based on the detected CAZyme families, each genome is assigned one of three inference categories:

| Inference | Criteria |
|---|---|
| **Probable** | At least one core family is detected. |
| **Unconfirmed** | Support or related families are detected, but no core family is present. |
| **Not identified** | No associated CAZyme families are detected. |

These categories represent genomic inference and do not constitute experimental confirmation of substrate degradation.

## Input Files

### 1. CAZyme annotations

The input file (`CAZy_annotations.csv`) contains CAZyme family annotations from one or multiple bacterial genomes.

Required columns:

| Column | Description |
|---|---|
| `genome_id` | Unique identifier for each bacterial genome. |
| `CAZy_family` | CAZyme family identifier. |

### 2. Substrate-associated rules

The rules file (`CAZy_substrate_rules.csv`) defines the associations between CAZyme families and carbohydrate substrates.

Required columns:

| Column | Description |
|---|---|
| `substrate` | Carbohydrate substrate associated with the CAZyme family. |
| `family` | CAZyme family used as an inference marker. |
| `evidence_level` | Evidence level assigned to the family (`core`, `support`, or `related`). |

The rules file can be adapted or expanded to incorporate additional substrate-associated CAZyme families.

## Requirements

- R (version to be specified).
- Required R packages:
  - `readr`
  - `dplyr`
  - `tidyr`
  - `stringr`

## Usage

1. Clone or download the repository.
2. Place the CAZyme annotation file (`CAZy_annotations.csv`) in the `data/` directory.
3. Ensure that the substrate rules file (`CAZy_substrate_rules.csv`) is available in the same directory.
4. Open R or RStudio and set the working directory to the repository root.
5. Run the main script:

```r
source("scripts/CAZySubstrateProfiler.R")
```

The results will be automatically generated in the `results/` directory.

## Output Files

CAZySubstrateProfiler generates two output files:

| File | Description |
|---|---|
| `substrate_inference.csv` | Detailed substrate inference for each genome, including detected CAZyme families and their corresponding evidence levels. |
| `substrate_inference_matrix.csv` | Wide-format matrix summarizing substrate inference across all analyzed genomes. |

## Limitations

CAZySubstrateProfiler provides genomic predictions based on predefined CAZyme family–substrate associations. The presence of a CAZyme family does not necessarily demonstrate enzymatic activity or substrate utilization under specific environmental conditions.

Substrate specificity may vary among members of the same CAZyme family. Therefore, the inferred degradation potential should be interpreted as a genomic indication rather than experimental evidence of substrate degradation.

## References

To be added.

## License

To be specified.
