# A lot of this is from https://github.com/chrisheller/docker-nim-cross

# Starting with a standard Ubuntu
FROM ubuntu

# Configuration for Ubuntu
ENV LANG C.UTF-8

# Get everything up to date and install dependencies. The echo statement here is just
# in case we need to refresh the Docker cache in the future.
RUN echo "Last updated at: Jan 2, 2022" > "/last-updated.txt"
RUN DEBIAN_FRONTEND=noninteractive apt-get update -yy &&                        \
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -yy &&                       \
    DEBIAN_FRONTEND=noninteractive apt-get install -yy                          \
    automake bison curl file flex git libgtk-3-dev libtool pkg-config python    \
    texinfo cmake wget gcc-multilib apt-transport-https ca-certificates         \
    software-properties-common

# Install Nim
RUN curl https://nim-lang.org/choosenim/init.sh -sSf -o /root/init.sh && \
    chmod +x /root/init.sh && \
    /root/init.sh -y && \
    rm /root/init.sh

# Update PATH
ENV PATH $PATH:/opt/osxcross/target/bin:/root/.nimble/bin

# If no command specified, start a bash shell
CMD /bin/bash