# Ubuntu Image
FROM ubuntu:24.10
# 22.04
COPY ./Test_File/test_file.fds /Test_File/test_file.fds
# provide setup-file
ARG setupfile=https://github.com/firemodels/fds/releases/download/FDS6.7.7/FDS6.7.7_SMV6.7.18_rls_lnx.sh

# download FDS
ADD $setupfile /root/

# set environment variables
ENV FDSBINDIR=/root/FDS/FDS6/bin
ENV impihome=/root/FDS/FDS6/bin/INTEL
ENV PATH=$FDSBINDIR:$impihome/bin:$PATH
ENV FI_PROVIDER_PATH=$impihome/prov
ENV LD_LIBRARY_PATH=/usr/lib64:$impihome/lib:$LD_LIBRARY_PATH

RUN sed -i 's|http://archive.ubuntu.com|http://old-releases.ubuntu.com|g; s|http://security.ubuntu.com|http://old-releases.ubuntu.com|g' /etc/apt/sources.list.d/ubuntu.sources && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y nano locate zip && \
    updatedb && \
    rm -rf /var/lib/apt/lists/*

# set execution rights, run setup script, remove setup script and unessential data
RUN chmod +x /root/*.sh && \
    /root/*.sh y && \
    rm /root/*.sh && \
    mv /root/FDS/FDS6/bin /root/FDS/ && \
    rm -rf /root/FDS/FDS6/* && \
    mv /root/FDS/bin /root/FDS/FDS6/ && \
    sed -i 's|http://archive.ubuntu.com|http://old-releases.ubuntu.com|g; s|http://security.ubuntu.com|http://old-releases.ubuntu.com|g' /etc/apt/sources.list.d/ubuntu.sources && \
    apt update && \
    apt upgrade -y

# set workdir for fds-simulation
WORKDIR /workdir

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]