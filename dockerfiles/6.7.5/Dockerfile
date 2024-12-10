# Ubuntu Image
FROM ubuntu:18.04
COPY ./Test_File/test_file.fds /Test_File/test_file.fds
# provide setup-file
ARG setupfile=https://github.com/firemodels/fds/releases/download/FDS6.7.5/FDS6.7.5_SMV6.7.15_lnx.sh

# download FDS
ADD $setupfile /root/

# set environment variables
ENV FDSBINDIR=/root/FDS/FDS6/bin
ENV impihome=/root/FDS/FDS6/bin/INTEL
ENV PATH=$FDSBINDIR:$impihome/bin:$PATH
ENV FI_PROVIDER_PATH=$impihome/prov
ENV LD_LIBRARY_PATH=/usr/lib64:$impihome/lib:$LD_LIBRARY_PATH
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y nano mlocate zip && \
    updatedb && \
    rm -rf /var/lib/apt/lists/*
# set execution rights, run setup script, remove setup script and unessential data
RUN chmod +x /root/*.sh && \
    /root/*.sh y && \
    rm /root/*.sh && \
    mv /root/FDS/FDS6/bin /root/FDS/ && \
    rm -rf /root/FDS/FDS6/* && \
    mv /root/FDS/bin /root/FDS/FDS6/ && \
    apt update && \
    apt upgrade -y

# set workdir for fds-simulation
WORKDIR /workdir

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]