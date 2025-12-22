robocopy %SRC_DIR%\perl\ %LIBRARY_PREFIX%\ *.* /E
if %ERRORLEVEL% GEQ 8 exit 1

REM Strawberry Perl ships many private runtime DLLs with a "__.dll" suffix to avoid PATH collisions.
REM Perl XS modules are linked against these exact filenames, so we copy only the underscored DLLs
REM from Strawberry's c\bin into Library\bin to satisfy runtime dependencies without overlapping
REM with conda-provided libraries.
robocopy %SRC_DIR%\c\bin\ %LIBRARY_BIN%\ *__.dll /E /NFL /NDL
if %ERRORLEVEL% GEQ 8 exit 1
REM Some Strawberry XS modules import Check.xs.dll by basename (no relative path),
REM so we also place it in Library\bin (on PATH) for the Windows loader.
copy %SRC_DIR%\perl\vendor\lib\auto\B\Hooks\OP\Check\Check.xs.dll %LIBRARY_BIN%\
if %ERRORLEVEL% NEQ 0 exit 1

REM There's a bat file in here that says it is better than exe.
REM Let's trust the strawberry perl folks.
del %LIBRARY_BIN%\perlglob.exe

copy %SRC_DIR%\licenses\perl %LIBRARY_PREFIX%\perl_licenses
