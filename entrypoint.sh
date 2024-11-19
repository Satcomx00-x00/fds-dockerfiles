#!/bin/bash
set -euo pipefail

# Environment variables (expected to be set externally)
readonly REQUIRED_ENV_VARS=(
    "FDS_FILE_PATH"      # Path to FDS input file
    "MPI_PROCESSES"      # Number of MPI processes
    "INPUT_ARCHIVE_DIR"  # Directory to be archived
)

# Script variables
readonly WORKDIR="/workdir"
readonly OUTPUT_DIR="/output"
readonly LOG_DATE_FORMAT='+%Y-%m-%d %H:%M:%S'

# Configure logging
log() {
    echo "[$(date "$LOG_DATE_FORMAT")] $1"
}

error() {
    log "ERROR: $1" >&2
    exit 1
}

# Validate environment variables
for var in "${REQUIRED_ENV_VARS[@]}"; do
    [[ -z "${!var:-}" ]] && error "Required environment variable $var is not set"
done

# Validate file existence
[[ ! -f "$FDS_FILE_PATH" ]] && error "FDS file not found: $FDS_FILE_PATH"
[[ ! -d "$WORKDIR/$INPUT_ARCHIVE_DIR" ]] && error "Input directory not found: $WORKDIR/$INPUT_ARCHIVE_DIR"

# Ensure output directory exists and is writable
[[ ! -d "$OUTPUT_DIR" ]] && error "Output directory not found: $OUTPUT_DIR"
[[ ! -w "$OUTPUT_DIR" ]] && error "Output directory not writable: $OUTPUT_DIR"

log "Starting FDS simulation process"

# Check for pattern &HEAD CHID= in the FDS file
if ! grep -q '&HEAD[[:space:]]*CHID='\''[^'\'']*'\''' "$FDS_FILE_PATH"; then
    error "No &HEAD CHID= pattern found in the file. This field is mandatory."
fi

# Set resource limits
log "Configuring system resources..."
for limit in stack virtual; do
    if ! ulimit -$([[ "$limit" == "stack" ]] && echo "s" || echo "v") unlimited; then
        error "Failed to set unlimited $limit size"
    fi
done

# Extract filenames
input_filename=$(basename "$FDS_FILE_PATH")
simulation_name="${input_filename%.fds}"

# Run FDS simulation
log "Running FDS simulation with $MPI_PROCESSES processes..."
if ! cd "$OUTPUT_DIR" || ! mpiexec -n "$MPI_PROCESSES" fds "$FDS_FILE_PATH"; then
    error "FDS simulation failed"
fi

log "FDS simulation completed successfully"

# Create archive of outputs
output_archive="${simulation_name}-output.zip"
log "Creating output archive: $output_archive"

if ! zip -r "$output_archive" . -i "*.out" "*.smv" "*.sf" "*.bf" "*.q" "*.pl3d" 2>&1; then
    error "Failed to create zip archive $output_archive"
fi

log "Archive created successfully at $OUTPUT_DIR/$output_archive"

# Verify output files
for ext in out smv; do
    if [[ ! -f "$OUTPUT_DIR/${simulation_name}.${ext}" ]]; then
        error "Expected output file ${simulation_name}.${ext} not found"
    fi
done

log "Process completed successfully"
exit 0