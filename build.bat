@echo off
echo ========================================
echo    Build ENGINE OGRE NEXT
echo ========================================

if not exist build (
    echo Creation du dossier build...
    mkdir build
)

echo.
echo Configuration CMake...
cd build
cmake ..
if errorlevel 1 goto error

echo.
echo Build Release...
cmake --build . --config Release
if errorlevel 1 goto error

echo.
echo Build Debug...
cmake --build . --config Debug
if errorlevel 1 goto error

cd ..
echo.
echo ========================================
echo    Build termine avec succes!
echo ========================================
pause
exit /b 0

:error
cd ..
echo.
echo ========================================
echo    ERREUR lors du build!
echo ========================================
pause
exit /b 1