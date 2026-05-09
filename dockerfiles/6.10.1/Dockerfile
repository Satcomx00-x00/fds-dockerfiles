############################
# Download and extract FDS #
############################
FROM ubuntu:24.04 AS fds
# install dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y bash wget && rm -rf /var/lib/apt/lists/* || true
# download
RUN wget -q "https://github.com/firemodels/fds/releases/download/FDS-6.10.1/FDS-6.10.1_SMV-6.10.1_lnx.sh" -O /root/FDS-6.10.1_SMV-6.10.1_lnx.sh || true
# extract
RUN chmod +x /root/*.sh && \
    /root/*.sh y || true && \
    rm /root/FDS-6.10.1_SMV-6.10.1_lnx.sh || true && \
    mv /root/FDS/FDS*/bin/* /root/FDS/ || true && \
    find /root/FDS/* -type d -name "FDS*" -exec rm -rf {} + || true && \
    rm -f /root/FDS/*VARS.sh || true && \
    mkdir -p /root/FDS

#####################
# Copy FDS binaries #
#####################
FROM ubuntu:24.04
# set environment variables
ENV FDSBINDIR=/root/FDS
ENV impihome=$FDSBINDIR/INTEL
ENV PATH=$FDSBINDIR:$impihome/bin:$PATH
ENV FI_PROVIDER_PATH=$impihome/prov
ENV LD_LIBRARY_PATH=/usr/lib64:$impihome/lib:$LD_LIBRARY_PATH
# copy binaries
COPY --from=fds /root/FDS /root/FDS
# copy test file
COPY ./Test_File/test_file.fds /Test_File/test_file.fds
# set workdir for fds-simulation
WORKDIR /workdir

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
