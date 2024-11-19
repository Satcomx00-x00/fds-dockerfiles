#!/bin/bash
set -euo pipefail

# Environment variables (expected to be set externally)
readonly REQUIRED_ENV_VARS=(
    "FDS_FILE_PATH"      # Path to FDS input file
    "MPI_PROCESSES"      # Number of MPI processes
    "INPUT_ARCHIVE_DIR"  # Directory to be archived
)

# Script variables
readonly WORKSPACE_DIR="/workspace"
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

# Validate workspace directory
[[ ! -d "$WORKSPACE_DIR" ]] && error "Workspace directory not found: $WORKSPACE_DIR"
[[ ! -w "$WORKSPACE_DIR" ]] && error "Workspace directory not writable: $WORKSPACE_DIR"

log "Starting FDS simulation process"

# Print current directory and contents
log "Current working directory: $(pwd)"
log "Workspace contents:"
ls -la "$WORKSPACE_DIR"

# Validate input file
[[ ! -f "$FDS_FILE_PATH" ]] && error "FDS input file not found: $FDS_FILE_PATH"

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

# Run FDS simulation
log "Running FDS simulation with $MPI_PROCESSES processes..."
log "Using input file: $FDS_FILE_PATH"

if ! cd "$WORKSPACE_DIR"; then
    error "Failed to change to workspace directory"
fi

if ! mpiexec -n "$MPI_PROCESSES" fds "$FDS_FILE_PATH"; then
    error "FDS simulation failed"
fi

log "FDS simulation completed successfully"

# List generated files
log "Generated files:"
ls -la "$WORKSPACE_DIR"

# Create archive if needed
simulation_name=$(basename "${FDS_FILE_PATH%.fds}")
if [[ -n "${ZIP_ARCHIVE:-}" ]]; then
    output_archive="${simulation_name}-output.zip"
    log "Creating output archive: $output_archive"
    
    if ! zip -r "$output_archive" . -i "*.out" "*.smv" "*.sf" "*.bf" "*.q" "*.pl3d" 2>&1; then
        error "Failed to create zip archive $output_archive"
    fi
    
    log "Archive created successfully at $WORKSPACE_DIR/$output_archive"
fi

# Verify output files
for ext in out smv; do
    if [[ ! -f "${simulation_name}.${ext}" ]]; then
        error "Expected output file ${simulation_name}.${ext} not found"
    fi
done

log "Process completed successfully"
exit 0