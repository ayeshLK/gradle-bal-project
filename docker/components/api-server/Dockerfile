# Stage 1: Build stage
ARG BASE_IMAGE_DIGEST=sha256:8810492a2dd16b7f59239c1e0cc1e56c1a1a5957d11f639776bd6798e795608b
FROM debian:stable-slim@${BASE_IMAGE_DIGEST} AS build

# Install prerequisites for downloading and installing .deb packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        gnupg \
        apt-transport-https \
        dpkg \
        unzip \
    && rm -rf /var/lib/apt/lists/*

# Copy and unzip the distribution
ARG SERVER_NAME=api-server
ARG SERVER_VERSION=0.1.0-SNAPSHOT
ARG SERVER=${SERVER_NAME}-${SERVER_VERSION}
ARG SERVER_DIST_PATH=../../../../distribution/build/distributions
WORKDIR /home/wso2
COPY ${SERVER_DIST_PATH}/${SERVER}.zip .
RUN unzip ${SERVER}.zip \
    && rm ${SERVER}.zip

# Stage 2: Final stage
ARG BASE_IMAGE_DIGEST=sha256:8810492a2dd16b7f59239c1e0cc1e56c1a1a5957d11f639776bd6798e795608b
FROM debian:stable-slim@${BASE_IMAGE_DIGEST}

# Set up Docker image labels
LABEL maintainer="WSO2 Docker Maintainers <dev@wso2.org>"

# Set up build arguments
ARG USER=wso2
ARG USER_ID=10001
ARG USER_GROUP=wso2
ARG USER_GROUP_ID=10001
ARG USER_HOME=/home/${USER}
ARG MOTD='printf "\n\ Welcome to WSO2 Docker Resources \n\ --------------------------------- \n\ This Docker container comprises of a WSO2 product, running with its latest GA release \n\ which is under the Apache License, Version 2.0. \n\ Read more about Apache License, Version 2.0 here @ http://www.apache.org/licenses/LICENSE-2.0.\n"'

# Create user and group and set MOTD
RUN groupadd --system --gid ${USER_GROUP_ID} ${USER_GROUP} \
    && useradd --system --uid ${USER_ID} --gid ${USER_GROUP_ID} -m --home-dir ${USER_HOME} ${USER} \
    && echo ${MOTD} > "/etc/profile.d/motd.sh"

# Set up working directory
WORKDIR ${USER_HOME}

# Copy the distribution from the build stage
ARG SERVER_NAME=api-server
ARG SERVER_VERSION=0.1.0-SNAPSHOT
ARG SERVER=${SERVER_NAME}-${SERVER_VERSION}
ARG SERVER_HOME=${USER_HOME}/${SERVER}
COPY --from=build --chown=${USER_ID}:${USER_GROUP_ID} /home/wso2/${SERVER} ${SERVER_HOME}

# Set environment variables
ENV SERVER_HOME=${SERVER_HOME}
ENV PATH="/usr/lib/ballerina/bin:${PATH}"

# Switch to the non-root user
USER ${USER_ID}

# Set the entrypoint
CMD ["sh", "-c", "${SERVER_HOME}/bin/apiserver.sh"]

