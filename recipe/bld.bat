robocopy %SRC_DIR%\perl\ %LIBRARY_PREFIX%\ *.* /E
if %ERRORLEVEL% GEQ 8 exit 1

REM Strawberry Perl depends on many bundled C runtime DLLs (often with "__" suffixes to avoid PATH collisions);
REM copy the full Strawberry c\bin DLL set so XS modules can load their exact imported DLL names.
robocopy %SRC_DIR%\c\bin\ %LIBRARY_BIN%\ *.dll /E /NFL /NDL
if %ERRORLEVEL% GEQ 8 exit 1
REM Some Strawberry XS modules import Check.xs.dll by basename (no relative path),
REM so we also place it in Library\bin (on PATH) for the Windows loader.
copy %SRC_DIR%\perl\vendor\lib\auto\B\Hooks\OP\Check\Check.xs.dll %LIBRARY_BIN%\
if %ERRORLEVEL% NEQ 0 exit 1

REM There's a bat file in here that says it is better than exe.
REM Let's trust the strawberry perl folks.
del %LIBRARY_BIN%\perlglob.exe

copy %SRC_DIR%\licenses\perl %LIBRARY_PREFIX%\perl_licenses
