#!/bin/bash

# export CONDA_BUILD_SYSROOT="/Library/Developer/CommandLineTools/SDKs/MacOSX11.1.sdk"
# world-writable files are not allowed
chmod -R o-w "${SRC_DIR}"

if [[ -n "$CC" ]]; then
  export CC2=$(basename $CC)
else
  export CC2=""
fi
if [[ -n "$GCC" ]]; then
  export GCC2=$(basename $GCC)
else
  export GCC2=""
fi

export PATH=$PREFIX/bin:$PATH

# export CFLAGS="-I${PREFIX}/include"
# export LDFLAGS="${LDFLAGS} -L${CONDA_BUILD_SYSROOT}/usr/lib"
declare -a _config_args
_config_args+=(-Dprefix="${PREFIX}")
_config_args+=(-Dusethreads)
_config_args+=(-Duserelocatableinc)
_config_args+=(-Dcccdlflags="-fPIC ${CFLAGS}")
_config_args+=(-Dldflags="${LDFLAGS}")
# .. ran into too many problems with '.' not being on @INC:
_config_args+=(-Ddefault_inc_excludes_dot=n)
if [[ -n "${GCC:-${CC}}" ]]; then
  _config_args+=("-Dcc=${GCC2:-${CC2}}")
fi
if [[ ${HOST} =~ .*linux.* ]]; then
  _config_args+=(-Dlddlflags="-shared ${LDFLAGS}")
# elif [[ ${HOST} =~ .*darwin.* ]]; then
#   _config_args+=(-Dlddlflags=" -bundle -undefined dynamic_lookup ${LDFLAGS}")
fi
# -Dsysroot prevents Configure rummaging around in /usr and
# linking to system libraries (like GDBM, which is GPL). An
# alternative is to pass -Dusecrosscompile but that prevents
# all Configure/run checks which we also do not want.
#if [[ -n ${CONDA_BUILD_SYSROOT} ]]; then
  _config_args+=("-Dsysroot=${CONDA_BUILD_SYSROOT}")
#else
#  if [[ -n ${HOST} ]] && [[ -n ${CC} ]]; then
#    _config_args+=("-Dsysroot=$(dirname $(dirname ${CC}))/$(${CC} -dumpmachine)/sysroot")
#  else
#    _config_args+=("-Dsysroot=${CONDA_BUILD_SYSROOT}/usr")
#  fi
#fi

./Configure "${_config_args[@]}" \
                -de
make

# change permissions again after building
chmod -R o-w "${SRC_DIR}"

# 1/13/2025
# Still getting several failing tests, see: https://github.com/AnacondaRecipes/perl-feedstock/pull/11#issuecomment-2583033446
# make test
make install
