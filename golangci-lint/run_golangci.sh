#!/bin/bash

echo "Starting golangci-lint analysis..."

# Detect if running from golangci-lint folder or project root
if [ -d "./bas-celik" ]; then
    CODE_PATH="./bas-celik"
    RESULTS_FILE="golangci-lint/golangci_lint_errors.txt"
elif [ -d "../bas-celik" ]; then
    # Running from golangci-lint folder
    CODE_PATH="../bas-celik"
    RESULTS_FILE="./golangci_lint_errors.txt"
else
    echo "Error: Could not find bas-celik directory"
    exit 1
fi

echo "Preparing project..."
cd $CODE_PATH
go mod tidy
cd -

echo "Moving golangci-lint config file..."
if [ -f "./golangci-lint/.golangci.yaml" ]; then
    cp ./golangci-lint/.golangci.yaml $CODE_PATH/.golangci.yaml
elif [ -f "./.golangci.yaml" ]; then
    cp ./.golangci.yaml $CODE_PATH/.golangci.yaml
else
    echo "Error: Could not find golangci-lint config file"
    exit 1
fi

echo "Running golangci-lint on code path: $CODE_PATH"
cd $CODE_PATH
RESULTS_FILE_TMP="../$RESULTS_FILE"
golangci-lint run > $RESULTS_FILE_TMP 2>&1 
cd -

echo "Cleaning up codebase..."

git -C "$CODE_PATH" restore .
git -C "$CODE_PATH" clean -fd

echo "golangci-lint completed. Output is saved in $RESULTS_FILE"
echo "Done."
