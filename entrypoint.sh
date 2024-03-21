#!/bin/bash
# Run FDS simulation

echo "Setting unlimited stack size..."
ulimit -s unlimited

echo "Setting unlimited virtual memory..."
ulimit -v unlimited

echo "Running FDS simulation..."
mpiexec -n $MPI fds $FDS_FILE_PATH

filename=$(basename "$FDS_FILE_PATH")
echo "Filename extracted: $filename"

filename_without_extension="${filename%.fds}"
echo "Filename without extension: $filename_without_extension"

ZIP_OUTPUT_FOLDER="$filename_without_extension-output.zip"
echo "Output zip folder name: $ZIP_OUTPUT_FOLDER"

echo "Zipping to $ZIP_OUTPUT_FOLDER ..."
zip -r "/workdir/$ZIP_OUTPUT_FOLDER" "/workdir/$ZIP_ARCHIVE_INPUT" 2>&1 || {
    echo "Failed to zip $ZIP_ARCHIVE_INPUT. Exiting."
    exit 1
}

echo "Zipping completed successfully. Output: $ZIP_OUTPUT_FOLDER"
