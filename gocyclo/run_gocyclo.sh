#!/bin/bash

set -ux
echo "Running gocyclo..."

# Detect if running from gocyclo folder or project root
if [ -d "./bas-celik" ]; then
    CODE_PATH="./bas-celik"
    RESULTS_DIR="./gocyclo/"
elif [ -d "../bas-celik" ]; then
    # Running from gocyclo folder
    CODE_PATH="../bas-celik"
    RESULTS_DIR="./"
else
    echo "Error: Could not find bas-celik directory"
    exit 1
fi

cd $CODE_PATH
RESULTS_DIR_TMP="../$RESULTS_DIR"
echo "Preparing project..."
go mod tidy
echo "Running gocyclo analysis..."
gocyclo -over 10 . -ignore "_test|Godeps|vendor/" > $RESULTS_DIR_TMP/gocyclo.txt 
echo "gocyclo analysis completed. Results are in $RESULTS_DIR/gocyclo.txt"
cd -

echo "Total number of functions/methods with cyclomatic complexity over 10:"
echo $(wc -l < $RESULTS_DIR/gocyclo.txt)

echo "Cleaning up codebase..."
git -C "$CODE_PATH" restore .
git -C "$CODE_PATH" clean -fd

echo "Done."
