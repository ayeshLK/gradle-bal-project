#!/bin/bash
# ---------------------------------------------------------------------------
# Copyright (c) 2024, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
#
# WSO2 Inc. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
# ---------------------------------------------------------------------------

# Ballerina API Server startup script
# This script starts the Ballerina API server

# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ]; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '.*/.*' > /dev/null; then
        PRG="$link"
    else
        PRG=`dirname "$PRG"`/"$link"
    fi
done

# Get standard environment variables
PRGDIR=`dirname "$PRG"`
BASE_DIR=`cd "$PRGDIR/.." ; pwd`
LIB_DIR="$BASE_DIR/lib"
CONF_DIR="$BASE_DIR/conf"

# Validate Java installation
if [ -n "$JAVA_HOME" ]; then
    if [ -x "$JAVA_HOME/jre/sh/java" ]; then
        # IBM's JDK on AIX uses strange locations for the executables
        JAVACMD="$JAVA_HOME/jre/sh/java"
    else
        JAVACMD="$JAVA_HOME/bin/java"
    fi
    if [ ! -x "$JAVACMD" ]; then
        echo "Error: JAVA_HOME is set to an invalid directory: $JAVA_HOME"
        echo "Please set the JAVA_HOME variable in your environment to match the"
        echo "location of your Java installation."
        exit 1
    fi
else
    JAVACMD="java"
    which java >/dev/null 2>&1 || {
        echo "Error: JAVA_HOME is not set and no 'java' command could be found in your PATH."
        echo "Please set the JAVA_HOME variable in your environment to match the"
        echo "location of your Java installation."
        exit 1
    }
fi

# Find the JAR file
JAR_FILE=$(find "$LIB_DIR" -name "*.jar" | head -n 1)

if [ -z "$JAR_FILE" ]; then
    echo "Error: No JAR file found in $LIB_DIR"
    exit 1
fi

echo "Starting API Server..."
echo "Using JAVA_HOME: ${JAVA_HOME:-system}"
echo "Java executable: $JAVACMD"
echo "JAR: $JAR_FILE"
echo "Config: $CONF_DIR/Config.toml"

# Run the JAR with Ballerina configuration set only for this command
exec env BAL_CONFIG_FILES="$CONF_DIR/Config.toml" "$JAVACMD" -jar "$JAR_FILE"