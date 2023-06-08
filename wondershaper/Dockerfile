FROM ubuntu:latest

# Install dependencies
RUN apt-get update && apt-get install -y \
    iproute2 \
    ethtool \
    wget \
    unzip \
    build-essential

# Install Wondershaper
RUN apt-get install -y wget \
    && wget https://github.com/magnific0/wondershaper/archive/master.zip \
    && unzip master.zip \
    && rm master.zip \
    && cd wondershaper-master \
    && make install

# Set up entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
