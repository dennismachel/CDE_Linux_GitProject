#!/usr/bin/env bash
# Exit immediately if a pipeline, variable, or command fails
set -euo pipefail
# ------------------------------------------------------------------------------
# STEP 0: ENVIRONMENT VARIABLES & DIRECTORY SETUP
# ------------------------------------------------------------------------------
echo "=================================================="
echo "CoreDataEngineers ETL Pipeline: Initializing..."
echo "=================================================="
# Define directory structure
RAW_DIR="raw"
TRANSFORMED_DIR="Transformed"
GOLD_DIR="Gold"
# Create directories if they do not already exist
mkdir -p "${RAW_DIR}" "${TRANSFORMED_DIR}" "${GOLD_DIR}"
echo "[INIT] Directory structure verified: /${RAW_DIR}, /${TRANSFORMED_DIR}, /${GOLD_DIR}"
# ------------------------------------------------------------------------------
echo ""
echo "--------------------------------------------------"
echo "STEP 1: Extract Phase"
echo "--------------------------------------------------"

RAW_FILE="${RAW_DIR}/raw_data.csv"
echo "[EXTRACT] Downloading CSV dataset from: ${CSV_SOURCE_URL}..."
#Download the CSV file using curl or wget, depending on availability
if command -v curl &> /dev/null; then
    curl -sSf -L "${CSV_SOURCE_URL}" -o "${RAW_FILE}"
elif command -v wget &> /dev/null; then
    wget -q -O "${RAW_FILE}" "${CSV_SOURCE_URL}"
else
    echo "[ERROR] Neither curl nor wget is available on this system."
    exit 1
fi

# Confirm file exists and is not empty in the raw directory
if [[ -s "${RAW_FILE}" ]]; then
    echo "[CONFIRMATION] Success: File extracted and saved to '${RAW_FILE}'"
    echo "[METRICS] Raw file size: $(du -h "${RAW_FILE}" | cut -f1)"
    echo "[METRICS] Raw total row count: $(wc -l < "${RAW_FILE}")"
else
    echo "[ERROR] Failed to save raw file or downloaded file is empty."
    exit 1
fi
echo ""
echo "--------------------------------------------------"
echo "STEP 2: File Transformation Phase"
echo "--------------------------------------------------"
TRANSFORMED_FILE="${TRANSFORMED_DIR}/2023_year_finance.csv"

echo "[TRANSFORM] Renaming column 'Variable_code' to 'variable_code'..."
echo "[TRANSFORM] Selecting columns: year, Value, Units, variable_code..."

# Use awk to dynamically find column indices based on header names,
# replace the header name, and print only the requested columns.
awk -F',' -v OFS=',' '
NR == 1 {
    # Scan header row to map target column indices
    for (i = 1; i <= NF; i++) {
        # Normalize/clean header field from whitespace/quotes if present
        col_name = $i
        gsub(/^[ "]+|[ "]+$/, "", col_name)
        
        if (col_name == "year") col_year = i
        if (col_name == "Value") col_value = i
        if (col_name == "Units") col_units = i
        if (col_name == "Variable_code" || col_name == "variable_code") col_var_code = i
    }
    
    # Check if required columns were found
    if (!col_year || !col_value || !col_units || !col_var_code) {
        print "[ERROR] Required columns missing from source header." > "/dev/stderr"
        exit 1
    }
    
    # Print transformed header with renamed column
    print "year", "Value", "Units", "variable_code"
    next
}
{
    # Print data rows selecting only the target columns
    print $col_year, $col_value, $col_units, $col_var_code
}
' "${RAW_FILE}" > "${TRANSFORMED_FILE}"

# Confirm transformed file exists and has content in the Transformed folder
if [[ -s "${TRANSFORMED_FILE}" ]]; then
    echo "[CONFIRMATION] Success: Transformed file created at '${TRANSFORMED_FILE}'"
    echo "[METRICS] Transformed row count: $(wc -l < "${TRANSFORMED_FILE}")"
    echo "[PREVIEW] Sample transformed output (First 3 rows):"
    head -n 3 "${TRANSFORMED_FILE}"
else
    echo "[ERROR] Transformation failed or transformed file is empty."
    exit 1
fi

echo ""
echo "--------------------------------------------------"
echo "STEP 3: File Loading Phase"
echo "--------------------------------------------------"

GOLD_FILE="${GOLD_DIR}/2023_year_finance.csv"

echo "[LOAD] Loading transformed data to Gold storage layer..."
cp "${TRANSFORMED_FILE}" "${GOLD_FILE}"

# Confirm file exists in the Gold folder
if [[ -s "${GOLD_FILE}" ]]; then
    echo "[CONFIRMATION] Success: Transformed data successfully loaded into '${GOLD_FILE}'"
    echo "[METRICS] Gold layer file size: $(du -h "${GOLD_FILE}" | cut -f1)"
else
    echo "[ERROR] Failed to load data to '${GOLD_FILE}'."
    exit 1
fi

echo ""
echo "=================================================="
echo "CoreDataEngineers ETL Pipeline Completed Successfully!"
echo "=================================================="
exit 0