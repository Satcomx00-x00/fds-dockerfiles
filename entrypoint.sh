#!/bin/bash
# entrypoint.sh
set -euo pipefail

# Environment variables (expected to be set externally)
readonly REQUIRED_ENV_VARS=(
    "FDS_FILE_PATH"      # Path to FDS input file
    "MPI_PROCESSES"      # Number of MPI processes
    "OMP_NUM_THREADS"    # Number of OpenMP threads per MPI process
    "INPUT_ARCHIVE_DIR"  # Directory to be archived
)

# Script variables
readonly WORKDIR="/workdir"
readonly LOG_DATE_FORMAT='+%Y-%m-%d %H:%M:%S'
readonly REQUIRED_PACKAGES=(
    "zip"
    "mpi-default-bin"    # For mpiexec
)

# Configure logging
log() {
    echo "[$(date "$LOG_DATE_FORMAT")] $1"
}

error() {
    log "ERROR: $1" >&2
    exit 1
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root to install packages"
    fi
}

# Check and install required packages
install_required_packages() {
    log "Checking for required packages..."
    local missing_packages=()

    for package in "${REQUIRED_PACKAGES[@]}"; do
        if ! dpkg -l | grep -q "^ii.*$package"; then
            missing_packages+=("$package")
        fi
    done

    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        log "Installing missing packages: ${missing_packages[*]}"
        apt-get update || error "Failed to update package lists"
        apt-get install -y "${missing_packages[@]}" || error "Failed to install required packages"
    fi

    log "All required packages are installed"
}

# Configure OpenMP settings
configure_openmp() {
    log "Configuring OpenMP settings..."
    
    # Set OpenMP thread count
    export OMP_NUM_THREADS="${OMP_NUM_THREADS:-1}"
    
    # Set OpenMP thread affinity
    export OMP_PROC_BIND="close"
    export OMP_PLACES="cores"
    
    # Dynamic adjustment of threads disabled for better performance
    export OMP_DYNAMIC="FALSE"
    
    # Set OpenMP scheduling policy
    export OMP_SCHEDULE="static"
    
    log "OpenMP configured with ${OMP_NUM_THREADS} threads per MPI process"
}

# Validate environment variables
for var in "${REQUIRED_ENV_VARS[@]}"; do
    [[ -z "${!var:-}" ]] && error "Required environment variable $var is not set"
done

# Check root and install packages
check_root
install_required_packages

# Configure OpenMP
configure_openmp

# Validate file existence
[[ ! -f "$FDS_FILE_PATH" ]] && error "FDS file not found: $FDS_FILE_PATH"
[[ ! -d "$INPUT_ARCHIVE_DIR" ]] && error "Input directory not found: $INPUT_ARCHIVE_DIR"

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
output_archive="${simulation_name}-output.zip"

# Calculate total cores used
total_cores=$((MPI_PROCESSES * OMP_NUM_THREADS))
log "Running hybrid parallel simulation with $MPI_PROCESSES MPI processes and $OMP_NUM_THREADS OpenMP threads per process (total cores: $total_cores)"

# Run FDS simulation with hybrid parallelization using environment variables
# Environment variables are already set by configure_openmp()
if ! mpiexec -n "$MPI_PROCESSES" fds "$FDS_FILE_PATH"; then
    error "FDS simulation failed"
fi

log "FDS simulation completed successfully"

# Create zip archive
log "Creating output archive: $output_archive"
cd "$WORKDIR" || error "Failed to change to $WORKDIR directory"

if ! zip -r "$output_archive" "$INPUT_ARCHIVE_DIR" 2>&1; then
    error "Failed to create zip archive $output_archive"
fi

log "Archive created successfully at $WORKDIR/$output_archive"

# Verify zip file was created and has content
if [[ ! -f "$WORKDIR/$output_archive" ]]; then
    error "Zip file was not created"
fi

if [[ ! -s "$WORKDIR/$output_archive" ]]; then
    error "Zip file is empty"
fi

log "Process completed successfully"
exit 0
