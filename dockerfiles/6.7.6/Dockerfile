# Ubuntu Image
FROM ubuntu:18.04
COPY ./Test_File/test_file.fds /Test_File/test_file.fds
# provide setup-file
ARG setupfile=https://github.com/firemodels/fds/releases/download/FDS6.7.6/FDS6.7.6_SMV6.7.16_rls_lnx.sh

# download FDS
RUN apt-get update || true && DEBIAN_FRONTEND=noninteractive apt-get install -y wget || true
RUN wget -q "$setupfile" -O /root/FDS.sh || true

# set environment variables
ENV FDSBINDIR=/root/FDS/FDS6/bin
ENV impihome=/root/FDS/FDS6/bin/INTEL
ENV PATH=$FDSBINDIR:$impihome/bin:$PATH
ENV FI_PROVIDER_PATH=$impihome/prov
ENV LD_LIBRARY_PATH=/usr/lib64:$impihome/lib:$LD_LIBRARY_PATH
RUN apt-get update || true
# set execution rights, run setup script, remove setup script and unessential data
RUN chmod +x /root/FDS.sh || true && \
    /root/FDS.sh y || true && \
    rm -f /root/FDS.sh || true && \
    mv /root/FDS/FDS6/bin /root/FDS/ || true && \
    rm -rf /root/FDS/FDS6/* || true && \
    mv /root/FDS/bin /root/FDS/FDS6/ || true && \
    apt update || true && \
    apt upgrade -y || true

# set workdir for fds-simulation
WORKDIR /workdir

# # Run the FDS command
# CMD ["mpiexec", "-n", "$MPI", "fds", "$FDS_FILE_PATH"]
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]