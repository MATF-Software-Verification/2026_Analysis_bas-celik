#!/bin/bash

set -ux
echo "Running Go fuzz tests..."


# Detect if running from gofuzz folder or project root
if [ -d "./bas-celik" ]; then
    CODE_PATH="./bas-celik"
    RESULTS_DIR="./gofuzz/"
    FUZZ_TESTS_DIR="./gofuzz/fuzz/"
elif [ -d "../bas-celik" ]; then
    # Running from gofuzz folder
    CODE_PATH="../bas-celik"
    RESULTS_DIR="./"
    FUZZ_TESTS_DIR="./fuzz/"
else
    echo "Error: Could not find bas-celik directory"
    exit 1
fi

echo "Moving fuzz tests into codebase (overwriting existing)..."
rsync -av --include='*/' --include='*.go' --exclude='*' "$FUZZ_TESTS_DIR"/ "$CODE_PATH"/

cd $CODE_PATH
echo "Preparing project..."
go mod tidy
RESULTS_DIR_TMP="../$RESULTS_DIR"
FUZZ_TARGETS=(
    "FuzzIDDocumentBuildPdf"
    "FuzzMedicalDocumentBuildPdf"
    "FuzzVehicleDocumentBuildPdf"
)

for fuzz_name in "${FUZZ_TARGETS[@]}"; do
    echo "Starting fuzz test ${fuzz_name}..."
    go test -run=^$ -fuzz="${fuzz_name}" -fuzztime=30s ./document > "${RESULTS_DIR_TMP}/gofuzz_out_${fuzz_name}.txt"
    echo "Fuzz test ${fuzz_name} completed. Results:"
    tail -n 2 "${RESULTS_DIR_TMP}/gofuzz_out_${fuzz_name}.txt"
done
echo "Fuzz tests completed."
cd -

echo "Cleaning up codebase (removing temporarily copied fuzz tests)..."
git -C "$CODE_PATH" restore .
git -C "$CODE_PATH" clean -fd


echo "Fuzz testing process finished results are in $RESULTS_DIR directory."


