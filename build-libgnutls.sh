#!/bin/bash

#  Automatic build script for gnutls
#  for iPhoneOS and iPhoneSimulator
#
#  Created by Felix Schulze on 30.01.11.
#  Copyright 2010 Felix Schulze. All rights reserved.
#  Copyright 2012 Jahn Bertsch. All rights reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###########################################################################
#  Change values here
#
SDKVERSION="6.1"
VERSION="2.12.14"
#
###########################################################################
#  No changes required beyond this point
CURRENTPATH=`pwd`
ARCHS="i386 armv7"

set -e
if [ ! -e gnutls-${VERSION}.tar.bz2 ]; then
	echo "Downloading gnutls-${VERSION}.tar.bz2"
	curl -O ftp://ftp.gnu.org/gnu/gnutls/gnutls-${VERSION}.tar.bz2
	echo
else
	echo "Using gnutls-${VERSION}.tar.bz2"
fi

if [ -f ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/lib/libgcrypt.a ];
then 
  echo "Using libgcrypt"
else
  echo "Please build libgcrypt first"
  exit 1
fi

mkdir -p bin
mkdir -p lib
mkdir -p src

for ARCH in ${ARCHS}
do
	if [ "${ARCH}" == "i386" ];
	then
		PLATFORM="iPhoneSimulator"
	else
		PLATFORM="iPhoneOS"
	fi

	echo "Building gnutls for ${PLATFORM} ${SDKVERSION} ${ARCH}"

	tar zxf gnutls-${VERSION}.tar.bz2 -C src
	cd src/gnutls-${VERSION}
	
	if [ "${VERSION}" == "2.8.6" ];
	then
		echo "Version 2.8.6 detected - Patch needed"
		echo "patching file lib/gnutls_global.c"
		sed -ie "s!gnutls_log_func _gnutls_log_func;!gnutls_log_func _gnutls_log_func = NULL;!" "lib/gnutls_global.c"
	fi
	
	if [ "${VERSION}" == "2.10.4" ];
	then
		echo "Version 2.10.4 detected - Patch needed"
		cd src
		patch -R < ../../../patches/gnutls-patch-${VERSION}.diff
		cd ..
	fi
	
	if [ "${VERSION}" == "2.10.5" ];
	then
		echo "Version 2.10.5 detected - Patch needed"
		cd src
		patch -R < ../../../patches/gnutls-patch-2.10.4.diff
		cd ..
	fi
	
	if [ "${VERSION}" == "2.12.14" ];
	then
		EXTRA_CONFIGURE_FLAGS="--without-p11-kit"
		echo "Version 2.12.14 detected - Setting extra configure flags: " ${EXTRA_CONFIGURE_FLAGS}
	fi

	export DEVROOT="/Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform/Developer/"
	export BUILD_SDKROOT="${DEVROOT}/SDKs/${PLATFORM}${SDKVERSION}.sdk"
	export CC="${DEVROOT}/usr/bin/gcc -arch ${ARCH}"
	export LD=${DEVROOT}/usr/bin/ld
#	export CPP=${DEVROOT}/usr/bin/cpp
	export CXX=${DEVROOT}/usr/bin/g++
	export AR=${DEVROOT}/usr/bin/ar
	export AS=${DEVROOT}/usr/bin/as
	export NM=${DEVROOT}/usr/bin/nm
#	export CXXCPP=$DEVROOT/usr/bin/cpp
	export RANLIB=$DEVROOT/usr/bin/ranlib
	export LDFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${BUILD_SDKROOT} -L${CURRENTPATH}/lib"
	export CFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${BUILD_SDKROOT} -I${CURRENTPATH}/include"
	export CXXFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${BUILD_SDKROOT} -I${CURRENTPATH}/include"

	mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"

	LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-gnutls-${VERSION}.log"

        echo "Follow the build log with: tail -f ${LOG}"
        echo "Please stand by..."

	./configure --host=${ARCH}-apple-darwin --prefix="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk" ${EXTRA_CONFIGURE_FLAGS} --enable-shared=no --with-libgcrypt --with-libgcrypt-prefix="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk" >> "${LOG}" 2>&1

	make >> "${LOG}" 2>&1
	make install >> "${LOG}" 2>&1
	cd ${CURRENTPATH}
	rm -rf src/gnutls-${VERSION}
	
done

echo "Build library..."
lipo -create ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/lib/libgnutls.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7.sdk/lib/libgnutls.a -output ${CURRENTPATH}/lib/libgnutls.a
lipo -create ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/lib/libgnutls-extra.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7.sdk/lib/libgnutls-extra.a -output ${CURRENTPATH}/lib/libgnutls-extra.a
lipo -create ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/lib/libgnutls-openssl.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7.sdk/lib/libgnutls-openssl.a -output ${CURRENTPATH}/lib/libgnutls-openssl.a
lipo -create ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/lib/libgnutlsxx.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7.sdk/lib/libgnutlsxx.a -output ${CURRENTPATH}/lib/libgnutlsxx.a

cp -R ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/include/gnutls ${CURRENTPATH}/include/
echo "Static libraries available at lib/libgnutls*"
