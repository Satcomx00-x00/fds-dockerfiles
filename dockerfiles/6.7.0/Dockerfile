# Ubuntu Image
FROM ubuntu:24.10
COPY ./Test_File/test_file.fds /Test_File/test_file.fds
# provide setup-file
ARG setupfile=https://github.com/firemodels/fds/releases/download/FDS6.7.0/FDS6.7.0-SMV6.7.1_linux64.sh

# download FDS
RUN apt-get update || true && DEBIAN_FRONTEND=noninteractive apt-get install -y wget || true
RUN wget -q "$setupfile" -O /root/FDS.sh || true

# set environment variables
ENV FDSBINDIR=/root/FDS/FDS6/bin
ENV PATH=$FDSBINDIR:$PATH
ENV LD_LIBRARY_PATH=/usr/lib64:$FDSBINDIR/LIB64:$LD_LIBRARY_PATH
RUN sed -i 's|http://archive.ubuntu.com|http://old-releases.ubuntu.com|g; s|http://security.ubuntu.com|http://old-releases.ubuntu.com|g' /etc/apt/sources.list.d/ubuntu.sources || true && \
    apt-get update || true && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y nano locate zip || true && \
    updatedb || true
# set execution rights, run setup script, remove setup script and unessential data
RUN chmod +x /root/FDS.sh || true && \
    /root/FDS.sh y || true && \
    rm /root/FDS.sh || true && \
    mv /root/FDS/FDS6/bin /root/FDS/ || true && \
    rm -rf /root/FDS/FDS6/* || true && \
    mv /root/FDS/bin /root/FDS/FDS6/ || true && \
    sed -i 's|http://archive.ubuntu.com|http://old-releases.ubuntu.com|g; s|http://security.ubuntu.com|http://old-releases.ubuntu.com|g' /etc/apt/sources.list.d/ubuntu.sources || true && \
    apt update || true && \
    apt upgrade -y || true

# set workdir for fds-simulation
WORKDIR /workdir

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]