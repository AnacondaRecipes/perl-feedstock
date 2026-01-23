cd win32

:: Set the compiler to use vs2019
sed -i.bak 's/^#\s*CCTYPE\s*=\s*MSVC142/CCTYPE = MSVC142/' Makefile

:: Override the default install prefix
:: Note: backslashes are required, therefore I didn't find a reliable way to use sed.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$p = Get-Content -Raw Makefile; " ^
  "$p = [regex]::Replace($p, '(^\s*INST_TOP\s*=).*$', '${1} ' + $env:LIBRARY_PREFIX, [Text.RegularExpressions.RegexOptions]::Multiline); " ^
  "[System.IO.File]::WriteAllText('Makefile', $p, [System.Text.Encoding]::ASCII)"

:: Build with architecture-specific parameters
if "%target_platform%"=="win-arm64" (
  echo Building for ARM64
  nmake WIN64=define PROCESSOR_ARCHITECTURE=ARM64
  nmake WIN64=define PROCESSOR_ARCHITECTURE=ARM64 test || echo Ignoring test failure
  nmake WIN64=define PROCESSOR_ARCHITECTURE=ARM64 install
) else (
  nmake
  nmake test || echo Ignoring test failure
  nmake install
)