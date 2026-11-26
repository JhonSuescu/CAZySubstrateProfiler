
# ============================================================
# CAZySubstrateProfiler
# ============================================================
#
# This script infers bacterial carbohydrate degradation
# potential from CAZyme family annotations using predefined
# substrate-associated CAZyme families and evidence levels.
#
# Input files:
#   - CAZy_annotations.csv: CAZyme annotations from one or
#     multiple bacterial genomes.
#   - CAZy_substrate_rules.csv: substrate-associated CAZyme
#     families and their corresponding evidence levels.
#
# Required columns:
#
#   CAZy_annotations.csv:
#     - genome_id: unique identifier for each bacterial genome.
#     - CAZy_family: CAZy family identifier.
#
#   CAZy_substrate_rules.csv:
#     - substrate
#     - family
#     - evidence_level
#
# Evidence levels:
#   - core
#   - support
#   - related
#
# Output files:
#   - substrate_inference.csv
#   - substrate_inference_matrix.csv
#
# ============================================================


# 1. LOAD REQUIRED PACKAGES
# ============================================================

library(readr)
library(dplyr)
library(tidyr)
library(stringr)


# 2. IMPORT INPUT DATA
# ============================================================

# CAZyme annotations

cazy <- read_csv(
  file.path("data", "CAZy_annotations.csv"),
  show_col_types = FALSE
)

# Substrate-associated CAZyme rules

rules <- read_csv(
  file.path("data", "CAZy_substrate_rules.csv"),
  show_col_types = FALSE
)


# 3. PREPARE DATA
# ============================================================

# Validate required columns

required_cazy <- c(
  "genome_id",
  "CAZy_family"
)

required_rules <- c(
  "substrate",
  "family",
  "evidence_level"
)

if (!all(required_cazy %in% names(cazy))) {
  stop("Missing required columns in CAZy_annotations.csv.")
}

if (!all(required_rules %in% names(rules))) {
  stop("Missing required columns in CAZy_substrate_rules.csv.")
}

# Prepare CAZyme annotations

cazy <- cazy %>%
  transmute(
    genome_id = str_trim(as.character(genome_id)),
    CAZy_family = str_trim(as.character(CAZy_family))
  ) %>%
  filter(
    !is.na(genome_id),
    !is.na(CAZy_family),
    genome_id != "",
    CAZy_family != ""
  ) %>%
  distinct()

# Prepare substrate rules

rules <- rules %>%
  mutate(
    substrate = str_trim(as.character(substrate)),
    family = str_trim(as.character(family)),
    evidence_level = str_to_lower(
      str_trim(as.character(evidence_level))
    )
  ) %>%
  filter(
    !is.na(substrate),
    !is.na(family),
    !is.na(evidence_level),
    substrate != "",
    family != "",
    evidence_level != ""
  ) %>%
  distinct()

# Validate evidence levels

valid_levels <- c("core", "support", "related")

if (!all(rules$evidence_level %in% valid_levels)) {
  stop("evidence_level must be core, support or related.")
}

# Check for duplicated substrate-family assignments

if (anyDuplicated(rules[c("substrate", "family")])) {
  stop(
    "Duplicate substrate-family assignments found in ",
    "CAZy_substrate_rules.csv."
  )
}

# Identify genomes and substrates

genomes <- sort(unique(cazy$genome_id))
substrates <- unique(rules$substrate)


# 4. IDENTIFY CAZyme EVIDENCE
# ============================================================

# A CAZyme annotation matches a family when it:
# - Exactly matches the specified family.
# - Starts with the specified family followed by "_".
#
# Example: GH5 matches GH5 and GH5_1, but not GH51.

evidence <- crossing(
  cazy,
  rules
) %>%
  filter(
    CAZy_family == family |
      startsWith(CAZy_family, paste0(family, "_"))
  ) %>%
  distinct(
    genome_id,
    substrate,
    CAZy_family,
    evidence_level
  )


# 5. SUMMARIZE EVIDENCE BY GENOME AND SUBSTRATE
# ============================================================

evidence_summary <- evidence %>%
  group_by(genome_id, substrate) %>%
  summarise(
    
    core_families = paste(
      sort(unique(CAZy_family[evidence_level == "core"])),
      collapse = "; "
    ),
    
    support_families = paste(
      sort(unique(CAZy_family[evidence_level == "support"])),
      collapse = "; "
    ),
    
    related_families = paste(
      sort(unique(CAZy_family[evidence_level == "related"])),
      collapse = "; "
    ),
    
    .groups = "drop"
  )


# 6. GENERATE FINAL SUBSTRATE INFERENCE
# ============================================================

final_inference <- expand_grid(
  genome_id = genomes,
  substrate = substrates
) %>%
  left_join(
    evidence_summary,
    by = c("genome_id", "substrate")
  ) %>%
  mutate(
    
    across(
      c(core_families, support_families, related_families),
      ~ replace_na(.x, "")
    ),
    
    inference = case_when(
      core_families != "" ~ "Probable",
      
      support_families != "" |
        related_families != "" ~ "Unconfirmed",
      
      TRUE ~ "Not identified"
    )
  )


# 7. GENERATE SUBSTRATE INFERENCE MATRIX
# ============================================================

substrate_matrix <- final_inference %>%
  select(
    substrate,
    genome_id,
    inference
  ) %>%
  pivot_wider(
    names_from = genome_id,
    values_from = inference
  ) %>%
  arrange(substrate)


# 8. EXPORT RESULTS
# ============================================================

output_directory <- "results"

if (!dir.exists(output_directory)) {
  dir.create(output_directory, recursive = TRUE)
}

# Export detailed substrate inference

write_csv(
  final_inference,
  file.path(
    output_directory,
    "substrate_inference.csv"
  )
)

# Export substrate inference matrix

write_csv(
  substrate_matrix,
  file.path(
    output_directory,
    "substrate_inference_matrix.csv"
  )
)


# ============================================================
# END OF SCRIPT
# ============================================================
