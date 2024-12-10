# Ubuntu Image
FROM ubuntu:22.04

COPY ./Test_File/test_file.fds /Test_File/test_file.fds
# provide setup-file
ARG setupfile=https://github.com/firemodels/fds/releases/download/FDS-6.8.0/FDS-6.8.0_SMV-6.8.0_lnx.sh

# download FDS
ADD $setupfile /root/
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y nano mlocate zip && \
    updatedb && \
    rm -rf /var/lib/apt/lists/*
# set environment variables
ENV FDSBINDIR=/root/FDS/FDS6/bin
ENV impihome=/root/FDS/FDS6/bin/INTEL
ENV PATH=$FDSBINDIR:$impihome/bin:$PATH
ENV FI_PROVIDER_PATH=$impihome/prov
ENV LD_LIBRARY_PATH=/usr/lib64:$impihome/lib:$LD_LIBRARY_PATH

# set execution rights, run setup script, remove setup script and unessential data
RUN chmod +x /root/*.sh && \
    /root/*.sh y && \
    rm /root/*.sh && \
    mv /root/FDS/FDS6/bin /root/FDS/ && \
    rm -rf /root/FDS/FDS6/* && \
    mv /root/FDS/bin /root/FDS/FDS6/ && \
    apt update 

# set workdir for fds-simulation
WORKDIR /workdir

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
