#!/bin/bash

echo "Starting gofmt analysis..."

# Detect if running from gofmt folder or project root
if [ -d "./bas-celik" ]; then
    CODE_PATH="./bas-celik"
    RESULTS_FILE="gofmt/gofmt_errors.txt"
elif [ -d "../bas-celik" ]; then
    # Running from gofmt folder
    CODE_PATH="../bas-celik"
    RESULTS_FILE="./gofmt_errors.txt"
else
    echo "Error: Could not find bas-celik directory"
    exit 1
fi

echo "Preparing project..."
cd $CODE_PATH
go mod tidy
cd -

echo "Running gofmt on code path: $CODE_PATH"
gofmt -l -s -e $CODE_PATH > $RESULTS_FILE

if [ $? -ne 0 ]; then
    echo "Error running gofmt"
    exit 1
fi

echo "gofmt completed. Output is saved in $RESULTS_FILE"

echo "Errors found:"
cat $RESULTS_FILE
echo "<-- End of errors -->"
echo "Total errors found: $(wc -l < $RESULTS_FILE)"

echo "Done."

