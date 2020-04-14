@echo off

cls

rem ================================================
rem ================================================
rem The project structure looks like this:
rem ROOT_PATH/
rem     PROJECT_NAME/
rem         code/
rem             src/
rem             include/
rem ================================================
rem ================================================
rem ** THIS ARE VARIABLES THAT NEED TO BE DEFINED **
rem ================================================

set PROJECT_NAME=merken-revision2020
set ROOT_PATH=..\
rem You need to install RGBDS https://github.com/rednex/rgbds
rem and set the path here:
set RGBDS_PATH=path\to\rgbds
rem ================================================
rem ================================================

set ASM=%RGBDS_PATH%\rgbasm
set LNK=%RGBDS_PATH%\rgblink
set FIX=%RGBDS_PATH%\rgbfix

rem Project Variables
set PROJECT_PATH=%ROOT_PATH%\%PROJECT_NAME%
set PROJECT_CODE=%PROJECT_PATH%\code
set PROJECT_INCLUDE=%PROJECT_CODE%\include\
set PROJECT_SRC=%PROJECT_CODE%\src

rem Output Variables
set OUTPUT_PATH=%PROJECT_PATH%\build
set OUTPUT_NAME=%OUTPUT_PATH%\%PROJECT_NAME%

rem Flags
set ASM_FLAGS=-i%PROJECT_INCLUDE%
set LNK_FLAGS=-m %OUTPUT_NAME%.map -n %OUTPUT_NAME%.sym -o %OUTPUT_NAME%.gb

if not exist "%RGBDS_PATH%" (
	echo ** Failed to build **
	echo You need to install RGBDS. 
	echo Download it from https://github.com/rednex/rgbds
	echo and then set the path in build.bat line 23.
	exit /b -1
)

echo ================================================

rem Create the output directory
if not exist "%OUTPUT_PATH%" mkdir %OUTPUT_PATH%

del "%OUTPUT_PATH%\*.o" /s /f /q
del "%OUTPUT_PATH%\*.map" /s /f /q
del "%OUTPUT_PATH%\*.sym" /s /f /q

echo Cleaning
 
echo Assembling

for %%I in (%PROJECT_SRC%\*.asm) do (
    echo    - %%~I
    %ASM% %ASM_FLAGS% -o %OUTPUT_PATH%\%%~nI.o %%~I
)

echo.
echo Linking

setlocal EnableDelayedExpansion
set OBJFILES=
for %%I in (%OUTPUT_PATH%\*.o) do (
    set OBJFILES=!OBJFILES! %OUTPUT_PATH%\%%~nI.o
)

echo    - %OBJFILES%

%LNK% %LNK_FLAGS% %OBJFILES%

echo.
echo Checksum Fix

%FIX% -p0 -v %OUTPUT_NAME%.gb

echo    - %OUTPUT_NAME%.gb

echo.
echo Build Complete
echo ================================================
