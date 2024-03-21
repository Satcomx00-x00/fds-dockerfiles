#!/bin/bash
# Run FDS simulation
ulimit -s unlimited
ulimit -v unlimited
mpiexec -n $MPI fds $FDS_FILE_PATH

filename=$(basename "$FDS_FILE_PATH")

filename_without_extension="${filename%.fds}"


ZIP_OUTPUT_FOLDER="$filename_without_extension-output.zip"

echo "Zipping to $ZIP_OUTPUT_FOLDER ..."

zip -r "/workdir/$ZIP_OUTPUT_FOLDER" "/workdir/$ZIP_ARCHIVE_INPUT" 2>&1 || {
    echo "Failed to zip $ZIP_ARCHIVE_INPUT. Exiting."
    exit 1
}

echo "zipped"
