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
rem Ballerina API Server startup script for Windows
rem This script starts the Ballerina API server

setlocal EnableDelayedExpansion

rem Get base directories
set SCRIPT_DIR=%~dp0
set BASE_DIR=%SCRIPT_DIR%..
set LIB_DIR=%BASE_DIR%\lib
set CONF_DIR=%BASE_DIR%\conf

rem Validate Java installation
if not "%JAVA_HOME%" == "" goto gotJavaHome
echo Error: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.
goto error

:gotJavaHome
if exist "%JAVA_HOME%\bin\java.exe" goto okJavaHome
echo Error: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.
goto error

:okJavaHome
set JAVACMD="%JAVA_HOME%\bin\java.exe"

rem Find the JAR file
for %%f in ("%LIB_DIR%\*.jar") do set JAR_FILE=%%f

if not defined JAR_FILE (
    echo Error: No JAR file found in %LIB_DIR%
    goto error
)

echo Starting API Server...
echo Using JAVA_HOME: %JAVA_HOME%
echo Java executable: %JAVACMD%
echo JAR: %JAR_FILE%
echo Config: %CONF_DIR%\Config.toml

rem Run the JAR with Ballerina configuration set only for this command
set BAL_CONFIG_FILES=%CONF_DIR%\Config.toml && %JAVACMD% -jar "%JAR_FILE%"
goto end

:error
exit /b 1

:end
exit /b 0