@REM ---------------------------------------------------------------------------
@REM Copyright (c) 2024, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
@REM
@REM WSO2 Inc. licenses this file to you under the Apache License,
@REM Version 2.0 (the "License"); you may not use this file except
@REM in compliance with the License.
@REM You may obtain a copy of the License at
@REM
@REM     http://www.apache.org/licenses/LICENSE-2.0
@REM
@REM Unless required by applicable law or agreed to in writing,
@REM software distributed under the License is distributed on an
@REM "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
@REM KIND, either express or implied. See the License for the
@REM specific language governing permissions and limitations
@REM under the License.
@REM ---------------------------------------------------------------------------

@echo off
rem Ballerina API Server startup script
rem This script starts the Ballerina API server

rem Get standard environment variables
set "PRGDIR=%~dp0"
for %%F in ("%PRGDIR%..") do set "BASE_DIR=%%~fF"
set "LIB_DIR=%BASE_DIR%\lib"
set "CONF_DIR=%BASE_DIR%\conf"

rem Validate Ballerina installation
where bal >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: 'bal' command could not be found in your PATH.
    echo Please install Ballerina and ensure it is in your PATH.
    exit /b 1
)
set "BAL_CMD=bal"

rem Find the JAR file
set "JAR_FILE="
for /f "delims=" %%F in ('dir /b /s "%LIB_DIR%\*.jar"') do (
    set "JAR_FILE=%%F"
    goto jar_found
)

:jar_found
if not defined JAR_FILE (
    echo Error: No JAR file found in %LIB_DIR%
    exit /b 1
)

echo Starting API Server...
echo JAR: %JAR_FILE%
echo Config: %CONF_DIR%\Config.toml

rem Run the Ballerina module with configuration
set "BAL_CONFIG_FILES=%CONF_DIR%\Config.toml"
"%BAL_CMD%" run "%JAR_FILE%"
