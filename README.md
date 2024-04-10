# Fire Dynamics Simulator (FDS) Dockerfiles

This repository contains Dockerfiles for the Fire Dynamics Simulator (FDS) by NIST, aimed at providing a convenient and consistent FDS simulation environment across various operating systems. It is important to note that this image is maintained independently and is not officially provided by NIST.

## Docker Repository

All versions of the FDS Docker image can be found at [satcomx00/fds on Docker Hub](https://hub.docker.com/repository/docker/satcomx00/fds/general).

## Supported Tags

The Docker image supports several tags, each corresponding to different versions of FDS. You can pull the latest version by using the latest tag, or specify a version directly (e.g., 5.5.3, 6.5.3, etc.). Here is a summary of the supported operating systems and their compatibility with each FDS version:

- **Linux & WSL 2 (Windows) / Hyperkit (Mac OS):** Fully supported across most versions.
- **Certain versions may run with warnings or limitations, denoted by a checkmark (*2).**

See the table in the original README for detailed compatibility information.

## Usage

### Running FDS

To run the latest version of FDS without simulation, you can use the following command:



## Prerequisites

- Docker installed on your system.
- Basic knowledge of Docker command-line tools.
- Understanding of FDS simulations if running specific simulation tasks.

## Installation

Pull the Docker image from Docker Hub:

```bash
docker pull satcomx00/fds:latest
```

The following table provides information about the basic runability of fds containers for different operating systems.

| FDS-Version (Tag)   | Linux                | WSL 2 (Windows) / Hyperkit (Mac OS) <sup>\*1</sup>  |
| ------------------- | :------------------- | :-------------------------------------------------- |
| 6.8.0, latest       | ✅                   | ✅                                                 |
| 6.7.9               | ✅                   | ✅                                                 |
| 6.7.8               | ✅                   | ✅                                                 |
| 6.7.7               | ✅                   | ✅                                                 |
| 6.7.6               | ✅                   | ✅                                                 |
| 6.7.5               | ✅                   | ✅                                                 |
| 6.7.4               | ✅                   | ✅                                                 |
| 6.7.3               | ✅                   | ✅                                                 |
| 6.7.1               | ☑️ <sup>\*2</sup>    | ☑️ <sup>\*2</sup>                                  |
| 6.7.0               | ✅                   | ❌                                                 |
| 6.6.0               | ✅                   | ❌                                                 |
| 6.5.3               | ☑️ <sup>\*2</sup>    | ☑️ <sup>\*2</sup>                                  |
| 6.3.0               | ☑️ <sup>\*2</sup>    | ☑️ <sup>\*2</sup>                                  |
| 6.2.0               | ☑️ <sup>\*2</sup>    | ☑️ <sup>\*2</sup>                                  |
| 5.5.3               | ✅                   | ✅                                                 |

<sup>\*1</sup> Running with Docker Desktop based on Hyperkit (Mac OS) or WSL 2 (Windows) which are a lightweight virtualization solutions for Linux Docker containers.

<sup>\*2</sup> Running with [warning](https://stackoverflow.com/questions/46138549/docker-openmpi-and-unexpected-end-of-proc-mounts-line). This should not affect the functionality of FDS.

# How to use this image

To run the latest version of FDS (without doing simulation at all) please run the following command for testing purposes.
```bash
docker run --rm satcomx00/fds fds
```
To run another version of FDS (e.g. 6.7.3) you have to append the corresponding tag to the image name.
```bash
docker run --rm satcomx00/fds:6.7.3 fds
```

# Additional Information

## OpenMP Configuration

By default, FDS utilizes all available processor cores. You can specify the number of threads via the OMP_NUM_THREADS environment variable:

```bash
docker run --rm -e OMP_NUM_THREADS=<number_of_threads> -v $(pwd):/workdir satcomx00/fds fds <filename>.fds
```

