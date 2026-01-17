#!/bin/bash

echo "Running Go tests with verbose output..."

# Detect if running from gotest folder or project root
if [ -d "./bas-celik" ]; then
    CODE_PATH="./bas-celik"
    RESULTS_DIR="./gotest/"
    UNIT_TESTS_DIR="./gotest/unit/"
elif [ -d "../bas-celik" ]; then
    # Running from gotest folder
    CODE_PATH="../bas-celik"
    RESULTS_DIR="./"
    UNIT_TESTS_DIR="./unit/"
else
    echo "Error: Could not find bas-celik directory"
    exit 1
fi

cd $CODE_PATH
RESULTS_DIR_TMP="../$RESULTS_DIR"
echo "Preparing project..."
go mod tidy
echo "Running tests BEFORE adding new unit tests..."
go test ./... > $RESULTS_DIR_TMP/gotest_out_before.txt
go test ./... -v -coverprofile=cover.before.out > $RESULTS_DIR_TMP/gotest_out_verbose_before.txt
echo "Generating coverage report (before)..."
go tool cover -func=cover.before.out > $RESULTS_DIR_TMP/cover_out_before.txt
go tool cover -html=cover.before.out -o $RESULTS_DIR_TMP/cover_before.html
rm cover.before.out
cd -

echo "Adding new unit tests into codebase (overwriting existing)..."
# Copy Go tests preserving relative paths (e.g., unit/card -> bas-celik/card)
rsync -av --include='*/' --include='*.go' --exclude='*' "$UNIT_TESTS_DIR"/ "$CODE_PATH"/

cd $CODE_PATH
echo "Preparing project..."
go mod tidy
echo "Running tests AFTER adding new unit tests..."
go test ./... > $RESULTS_DIR_TMP/gotest_out_after.txt
go test ./... -v -coverprofile=cover.after.out > $RESULTS_DIR_TMP/gotest_out_verbose_after.txt
echo "Generating coverage report (after)..."
go tool cover -func=cover.after.out > $RESULTS_DIR_TMP/cover_out_after.txt
go tool cover -html=cover.after.out -o $RESULTS_DIR_TMP/cover_after.html
rm cover.after.out

cd -

echo "Coverage before adding tests:"
tail -n 1 $RESULTS_DIR/cover_out_before.txt
echo "Coverage after adding tests:"
tail -n 1 $RESULTS_DIR/cover_out_after.txt

echo "Cleaning up codebase (removing temporarily copied tests)..."

git -C "$CODE_PATH" restore .
git -C "$CODE_PATH" clean -fd


echo "Go tests and coverage reports completed. Results are in the $RESULTS_DIR directory."


