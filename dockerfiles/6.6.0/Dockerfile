# Ubuntu Image
FROM ubuntu:18.04
COPY ./Test_File/test_file.fds /Test_File/test_file.fds
# provide setup-file
ARG setupfile=https://github.com/firemodels/fds/releases/download/FDS6.6.0/FDS_6.6.0-SMV_6.6.0_linux64.sh

# download FDS
ADD $setupfile /root/

# set environment variables
ENV FDSBINDIR=/root/FDS/FDS6/bin
ENV PATH=$FDSBINDIR:$PATH
ENV LD_LIBRARY_PATH=/usr/lib64:$FDSBINDIR/LIB64:$LD_LIBRARY_PATH

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