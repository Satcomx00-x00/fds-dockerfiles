# FDS 6.7.9
FROM ubuntu:22.04

COPY ./Test_File/test_file.fds /Test_File/test_file.fds

ARG setupfile=https://github.com/firemodels/fds/releases/download/FDS6.7.9/FDS6.7.9_SMV6.7.21_rls_lnx.sh

ADD $setupfile /root/

ENV FDSBINDIR=/root/FDS/FDS6/bin
ENV impihome=/root/FDS/FDS6/bin/INTEL
ENV PATH=$FDSBINDIR:$impihome/bin:$PATH
ENV FI_PROVIDER_PATH=$impihome/prov
ENV LD_LIBRARY_PATH=/usr/lib64:$impihome/lib:$LD_LIBRARY_PATH

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y nano locate zip && \
    updatedb && \
    rm -rf /var/lib/apt/lists/*

RUN chmod +x /root/*.sh && \
    /root/*.sh y && \
    rm /root/*.sh && \
    mv /root/FDS/FDS6/bin /root/FDS/ && \
    rm -rf /root/FDS/FDS6/* && \
    mv /root/FDS/bin /root/FDS/FDS6/ && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

WORKDIR /workdir

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]