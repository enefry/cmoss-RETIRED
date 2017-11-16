#!/bin/bash
set -e

# Download source
echo "sqlite-amalgamation-${SQLITE_VERSION}.zip" 
if [ ! -e "sqlite-amalgamation-${SQLITE_VERSION}.zip" ]
then
  echo curl $PROXY -O "http://www.sqlite.org/${SQLITE_YEAR}/sqlite-amalgamation-${SQLITE_VERSION}.zip"
  curl $PROXY -O "http://www.sqlite.org/${SQLITE_YEAR}/sqlite-amalgamation-${SQLITE_VERSION}.zip"
else
  ls -la "sqlite-amalgamation-${SQLITE_VERSION}.zip" 
fi

# Extract source
rm -rf "sqlite-amalgamation-${SQLITE_VERSION}"

unzip "sqlite-amalgamation-${SQLITE_VERSION}.zip"
pushd "sqlite-amalgamation-${SQLITE_VERSION}"

# Build
export CC=${DROIDTOOLS}-gcc
export LD=${DROIDTOOLS}-ld
export CPP=${DROIDTOOLS}-cpp
export CXX=${DROIDTOOLS}-g++
export AR=${DROIDTOOLS}-ar
export AS=${DROIDTOOLS}-as
export NM=${DROIDTOOLS}-nm
export STRIP=${DROIDTOOLS}-strip
export CXXCPP=${DROIDTOOLS}-cpp
export RANLIB=${DROIDTOOLS}-ranlib
export LDFLAGS="-Os -fpic -nostdlib -lc -shared -Wl,-rpath-link=${SYSROOT}/usr/lib -L${SYSROOT}/usr/lib -L${ROOTDIR}/lib"
export CFLAGS="-Os -pipe -isysroot ${SYSROOT} -I${ROOTDIR}/include -Dunix"
export CXXFLAGS="-Os -pipe -isysroot ${SYSROOT} -I${ROOTDIR}/include"

cp -f ${TOPDIR}/build-droid/Makefile.sqlite3 .

make -f Makefile.sqlite3 install CC="${CC}" CFLAGS="${CFLAGS}" RANLIB="${RANLIB}" LDFLAGS="${LDFLAGS}" PREFIX="${ROOTDIR}"

popd

# Clean up
rm -rf sqlite-amalgamation-${SQLITE_VERSION}
