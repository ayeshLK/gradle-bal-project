# Step 1: Use a minimal slim base image
FROM debian:stable-slim

# Step 2: Install prerequisites for downloading and installing .deb packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        gnupg \
        apt-transport-https \
        dpkg \
    && rm -rf /var/lib/apt/lists/*

# Step 3: Download and install Ballerina using curl
ARG BALLERINA_VERSION=2201.5.0
ARG BALLERINA_DEB_URL=https://dist.ballerina.io/downloads/${BALLERINA_VERSION}/ballerina-${BALLERINA_VERSION}-swan-lake-linux-x64.deb

RUN curl -L -o /tmp/ballerina.deb ${BALLERINA_DEB_URL} \
    && dpkg -i /tmp/ballerina.deb \
    && rm /tmp/ballerina.deb

# Step 4: Set up working directory and default command
WORKDIR /workspace
CMD ["bal", "version"]
