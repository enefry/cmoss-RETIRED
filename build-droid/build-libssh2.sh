#!/bin/bash
set -e

# Copyright (c) 2010, Pierre-Olivier Latour
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * The name of Pierre-Olivier Latour may not be used to endorse or
#       promote products derived from this software without specific prior
#       written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL PIERRE-OLIVIER LATOUR BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Download source
if [ ! -e "libssh2-${LIBSSH2_VERSION}.tar.gz" ]
then
echo  
  wget "http://www.libssh2.org/download/libssh2-${LIBSSH2_VERSION}.tar.gz"
fi

# Extract source
rm -rf "libssh2-${LIBSSH2_VERSION}"
tar xvf "libssh2-${LIBSSH2_VERSION}.tar.gz"

# Build
pushd "libssh2-${LIBSSH2_VERSION}"
CC=${DROIDTOOLS}-gcc
LD=${DROIDTOOLS}-ld
CPP=${DROIDTOOLS}-cpp
CXX=${DROIDTOOLS}-g++
AR=${DROIDTOOLS}-ar
AS=${DROIDTOOLS}-as
NM=${DROIDTOOLS}-nm
STRIP=${DROIDTOOLS}-strip
CXXCPP=${DROIDTOOLS}-cpp
RANLIB=${DROIDTOOLS}-ranlib
LDFLAGS="-Os -fpic -Wl,-rpath-link=${SYSROOT}/usr/lib -L${SYSROOT}/usr/lib -L${ROOTDIR}/lib -lz -lgpg-error -lgcrypt -lcrypto -lssl"
CFLAGS="-Os -pipe -isysroot ${SYSROOT} -I${ROOTDIR}/include"
CXXFLAGS="-Os -pipe -isysroot ${SYSROOT} -I${ROOTDIR}/include"

./configure --host=${ARCH}-android-linux --target=${PLATFORM} --prefix=${ROOTDIR} --with-libz --with-libz-prefix=${ROOTDIR} --with-openssl --with-libssl-prefix=${ROOTDIR} --with-libgcrypt --with-libgcrypt-prefix=${ROOTDIR} --with-libssl-prefix=${ROOTDIR} CFLAGS="${CFLAGS}"

# Fix libtool to not create versioned shared libraries
mv "libtool" "libtool~"
sed "s/library_names_spec=\".*\"/library_names_spec=\"~##~libname~##~{shared_ext}\"/" libtool~ > libtool~1
sed "s/soname_spec=\".*\"/soname_spec=\"~##~{libname}~##~{shared_ext}\"/" libtool~1 > libtool~2
sed "s/~##~/\\\\$/g" libtool~2 > libtool
chmod u+x libtool

make
make install
popd
# Clean up
rm -rf "libssh2-${LIBSSH2_VERSION}"
