cd win32

:: Set the compiler to use vs2019
sed -i.bak 's/^#\s*CCTYPE\s*=\s*MSVC142/CCTYPE = MSVC142/' Makefile

:: Override the default install prefix. Backslashes need escaped (and preserved, forward slashes dont work)
:: escape for sed  (\ -> \\)
set "SED_LIBPREFIX=%LIBRARY_PREFIX:\=\\%"
:: escape AGAIN for cmd/MSYS (\\ -> \\\\)
set "SED_LIBPREFIX=%SED_LIBPREFIX:\=\\%"
sed -i.bak -E "s|^([[:space:]]*INST_TOP[[:space:]]*=).*|\1 !SED_LIBPREFIX!|" Makefile

nmake
nmake test || echo Ignoring test failure
nmake install