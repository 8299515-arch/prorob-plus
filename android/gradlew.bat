@echo off
setlocal
set "GRADLE_VERSION=8.7"
set "GRADLE_HOME=%USERPROFILE%\.gradle\wrapper\dists\manual-gradle-%GRADLE_VERSION%"
set "GRADLE_BIN=%GRADLE_HOME%\gradle-%GRADLE_VERSION%\bin\gradle.bat"
if not exist "%GRADLE_BIN%" (
  echo Gradle %GRADLE_VERSION% is not installed in %GRADLE_HOME%.
  echo Install Gradle %GRADLE_VERSION% or run the CI build on Linux.
  exit /b 1
)
call "%GRADLE_BIN%" %*
