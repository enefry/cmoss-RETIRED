#!/bin/bash
set -e

# Retrieve NDK path to use
NDK=$1
if [ "${NDK}" == "" ] || [ ! -e ${NDK}/build/tools/make-standalone-toolchain.sh ]
then
  echo "Please specify a valid NDK path."
  exit 1
fi

export SDK="${NDK}"

if [ -z $2 ]
then
	export PROXY=""
else
	export PROXY="-x $2"
fi

# Project version to use to build minizip (changing this may break the build)
export MINIZIP_VERSION="101e"

export ZLIB_VERSION="1.2.11"

# Project version to use to build icu (changing this may break the build)
#export ICU_VERSION="4.8.1.1"
export ICU_VERSION="50.1.1"

# Project version to use to build c-ares (changing this may break the build)
export CARES_VERSION="1.12.0"

# Project version to use to build bzip2 (changing this may break the build)
export BZIP2_VERSION="1.0.6"

# Project version to use to build libidn (changing this may break the build)
export LIBIDN_VERSION="1.26"

# GNU Crypto libraries
export LIBGPG_ERROR_VERSION="1.27"
export LIBGCRYPT_VERSION="1.8.1"
export GNUPG_VERSION="2.2.2"

# Project versions to use to build openssl (changing this may break the build)
export OPENSSL_VERSION="1.1.0g"

# Project versions to use to build libssh2 and cURL (changing this may break the build)
export LIBSSH2_VERSION="1.8.0"
export CURL_VERSION="7.28.1"

# Project Version to use to build libgsasl
export LIBGSASL_VERSION="1.8.0"

# Project version to use to build boost C++ libraries
export BOOST_VERSION="1.65.1"
export BOOST_LIBS="chrono context date_time exception filesystem graph graph_parallel iostreams mpi program_options random regex serialization signals system test thread timer wave"

# Project version to use to build tinyxml
export TINYXML_VERSION="2.6.2"
export TINYXML_FILE="2_6_2"

# Project version to use to build expat (changing this may break the build)
export EXPAT_VERSION="2.0.1"

# Project version to use to build yajl (changing this may break the build)
export YAJL_VERSION="2.0.3"

# Project version to use to build sqlcipher (changing this may break the build)
export SQLCIPHER_VERSION="3.4.1"

# Project versions to use for SOCI (Sqlite3 C++ database library)
export SOCI_VERSION="3.1.0"

# Project version to use to build pion (changing this may break the build)
export PION_VERSION="master"

export SQLITE_VERSION="3210000"
export SQLITE_YEAR="2017"

# Create dist folder
BUILDDIR=$(dirname $0)

pushd $BUILDDIR
export TOPDIR=$(dirname $(pwd))
export BINDIR=$TOPDIR/bin/droid
export LOGDIR=$TOPDIR/log/droid
export TMPDIR=$TOPDIR/tmp
popd

rm -rf $LOGDIR
mkdir -p $LOGDIR
mkdir -p $TMPDIR

pushd $TMPDIR

export ANDROID_API_LEVEL="14"
export ARM_TARGETs=('armeabi' 'armeabi-v7a' 'arm64-v8a')
if [ -z $TOOLCHAIN_VERSION ]
then
	export TOOLCHAIN_VERSION="4.7"
fi

# Platforms to build for (changing this may break the build)
PLATFORMS="arm-linux-androideabi"

# Create tool chains for each supported platform
for PLATFORM in ${PLATFORMS}
do
	echo "Creating toolchain for platform ${PLATFORM}..."

	if [ ! -d "${TMPDIR}/droidtoolchains/${PLATFORM}" ]
	then
		$NDK/build/tools/make-standalone-toolchain.sh \
			--verbose \
			--platform=android-${ANDROID_API_LEVEL} \
			--toolchain=${PLATFORM}-${TOOLCHAIN_VERSION} \
			--install-dir=${TMPDIR}/droidtoolchains/${PLATFORM}
	fi
done

call_build_script(){
	LOGPATH="$1"
	ROOTDIR="$2"
	FLAGDIR="$3"
	NAME="$4"
	if [ -e ${FLAGDIR}/${NAME} ];then
		echo "skip ${NAME}"
	else
		echo  "==> "${TOPDIR}/build-droid/build-${NAME}.sh 
		${TOPDIR}/build-droid/build-${NAME}.sh > "${LOGPATH}-${NAME}.log"
		touch ${FLAGDIR}/${NAME}
	fi
}


# Build projects
for PLATFORM in ${PLATFORMS}
do
echo "*************$PLATFORM****************"
	for ARM_TARGET in ${ARM_TARGETs}
	do
			LOGPATH="${LOGDIR}/${PLATFORM}"
			ROOTDIR="${TMPDIR}/build/droid/${PLATFORM}/${ARM_TARGET}"
			FLAGDIR="${TMPDIR}/build/droid/${PLATFORM}/${ARM_TARGET}/buildflag/"
			
			mkdir -p "${FLAGDIR}"

			if [ "${PLATFORM}" == "arm-linux-androideabi" ]
			then
				export ARCH=${ARM_TARGET}
			else
				export ARCH="x86"
			fi
			
			echo "===> setup env"
			export ROOTDIR=${ROOTDIR}
			export PLATFORM=${PLATFORM}
			export DROIDTOOLS=${TMPDIR}/droidtoolchains/${PLATFORM}/bin/${PLATFORM}
			export SYSROOT=${TMPDIR}/droidtoolchains/${PLATFORM}/sysroot
			echo "==> begin build"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "zlib"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "minizip"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "icu"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "cares"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "bzip2"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "libidn"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "libgpg-error"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "libgcrypt"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "GnuPG"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "OpenSSL"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "libssh2"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "cURL"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "boost"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "tinyxml"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "expat"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "yajl"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "sqlcipher"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "sqlite"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "soci"
			
			call_build_script ${LOGDIR} ${ROOTDIR} ${FLAGDIR} "pion"
				
			# Remove junk
			rm -rf "${ROOTDIR}/bin"
			rm -rf "${ROOTDIR}/certs"
			rm -rf "${ROOTDIR}/libexec"
			rm -rf "${ROOTDIR}/man"
			rm -rf "${ROOTDIR}/misc"
			rm -rf "${ROOTDIR}/private"
			rm -rf "${ROOTDIR}/sbin"
			rm -rf "${ROOTDIR}/share"
			rm -rf "${ROOTDIR}/openssl.cnf"
	done
done

mkdir -p ${BINDIR}/include
cp -r ${TMPDIR}/build/droid/arm-linux-androideabi/include ${BINDIR}/

#mkdir -p ${BINDIR}/lib/x86
mkdir -p ${BINDIR}/lib/${ARM_TARGET}

#cp ${TMPDIR}/build/droid/i686-android-linux/lib/*.a ${BINDIR}/lib/x86
#cp ${TMPDIR}/build/droid/i686-android-linux/lib/*.la ${BINDIR}/lib/x86

#(cd ${TMPDIR}/build/droid/i686-android-linux/lib && tar cf - *.so ) | ( cd ${BINDIR}/lib/x86 && tar xfB - )
#(cd ${TMPDIR}/build/droid/i686-android-linux/lib && tar cf - *.so.* ) | ( cd ${BINDIR}/lib/x86 && tar xfB - )

cp ${TMPDIR}/build/droid/arm-linux-androideabi/lib/*.a ${BINDIR}/lib/${ARM_TARGET}
cp ${TMPDIR}/build/droid/arm-linux-androideabi/lib/*.la ${BINDIR}/lib/${ARM_TARGET}

(cd ${TMPDIR}/build/droid/arm-linux-androideabi/lib && tar cf - *.so ) | ( cd ${BINDIR}/lib/${ARM_TARGET} && tar xfB - )
#(cd ${TMPDIR}/build/droid/arm-linux-androideabi/lib && tar cf - *.so.* ) | ( cd ${BINDIR}/lib/${ARM_TARGET} && tar xfB - )

echo "**** Android c/c++ open source build completed ****"

popd
