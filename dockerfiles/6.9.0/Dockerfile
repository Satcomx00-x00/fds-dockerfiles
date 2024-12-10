FROM ubuntu:24.04 as fds

COPY ./Test_File/test_file.fds /Test_File/test_file.fds

# download
ADD https://github.com/firemodels/fds/releases/download/FDS-6.9.0/FDS-6.9.0_SMV-6.9.0_lnx.sh /root/
# install dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y nano mlocate zip && \
    updatedb && \
    rm -rf /var/lib/apt/lists/*
# extract
RUN chmod +x /root/*.sh && \
    /root/*.sh y && \
    rm /root/*.sh && \
    mv /root/FDS/FDS*/bin/* /root/FDS/ && \
    find /root/FDS/* -type d -name "FDS*" -exec rm -rf {} + && \
    rm /root/FDS/*VARS.sh

FROM ubuntu:24.04
# set environment variables
ENV FDSBINDIR=/root/FDS
ENV impihome=$FDSBINDIR/INTEL
ENV PATH=$FDSBINDIR:$impihome/bin:$PATH
ENV FI_PROVIDER_PATH=$impihome/prov
ENV LD_LIBRARY_PATH=/usr/lib64:$impihome/lib:$LD_LIBRARY_PATH
# copy binaries
COPY --from=fds /root/FDS /root/FDS
# set workdir for fds-simulation
WORKDIR /workdir

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]

