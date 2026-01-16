#!/bin/bash

echo "Starting govulncheck analysis..."

# Detect if running from govulncheck folder or project root
if [ -d "./bas-celik" ]; then
    CODE_PATH="./bas-celik"
    RESULTS_FILE="govulncheck/govulncheck_results.txt"
elif [ -d "../bas-celik" ]; then
    # Running from govulncheck folder
    CODE_PATH="../bas-celik"
    RESULTS_FILE="./govulncheck_results.txt"
else
    echo "Error: Could not find bas-celik directory"
    exit 1
fi  

echo "Preparing project..."
cd $CODE_PATH
go mod tidy
cd -

echo "Running govulncheck on code path: $CODE_PATH"
cd $CODE_PATH
TMP_RESULTS_FILE="../$RESULTS_FILE"
govulncheck -show verbose ./... > $TMP_RESULTS_FILE 2>&1
cd -

echo "Cleaning up codebase..."

git -C "$CODE_PATH" restore .
git -C "$CODE_PATH" clean -fd

echo "govulncheck output is saved in $RESULTS_FILE"
echo "Done."