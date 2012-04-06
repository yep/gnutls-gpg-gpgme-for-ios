#!/bin/bash

#  Automatic build script for libassuan
#  for iPhoneOS and iPhoneSimulator
#
#  Created by Felix Schulze on 30.01.11.
#  Copyright 2010 Felix Schulze. All rights reserved.
#  Copyright 2012 Jahn Bertsch. All rights reserverd.
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
SDKVERSION="5.1"
VERSION="2.0.3"
#
###########################################################################
#  No changes required beyond this point
CURRENTPATH=`pwd`
ARCHS="i386 armv6 armv7"
NAME=libassuan

set -e
if [ ! -e ${NAME}-${VERSION}.tar.bz2 ]; then
	echo "Downloading ${NAME}-${VERSION}.tar.bz2"
	curl -O ftp://ftp.gnupg.org/gcrypt/${NAME}/${NAME}-${VERSION}.tar.bz2
	echo
else
	echo "Using ${NAME}-${VERSION}.tar.bz2"
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

        rm -rf src/${NAME}-${VERSION}
	tar zxf ${NAME}-${VERSION}.tar.bz2 -C src
	cd src/${NAME}-${VERSION}
	
	echo "Building ${NAME} for ${PLATFORM} ${SDKVERSION} ${ARCH}"

	export DEVROOT="/Applications/Xcode.app/Contents/Developer/Platforms/${PLATFORM}.platform/Developer/"
	export SDKROOT="${DEVROOT}/SDKs/${PLATFORM}${SDKVERSION}.sdk"
	export CC="${DEVROOT}/usr/bin/gcc -arch ${ARCH}"
	export LD=${DEVROOT}/usr/bin/ld
#	export CPP=${DEVROOT}/usr/bin/cpp
	export CXX=${DEVROOT}/usr/bin/g++
	export AR=${DEVROOT}/usr/bin/ar
	export AS=${DEVROOT}/usr/bin/as
	export NM=${DEVROOT}/usr/bin/nm
#	export CXXCPP=$DEVROOT/usr/bin/cpp
	export RANLIB=$DEVROOT/usr/bin/ranlib
	export LDFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -L${CURRENTPATH}/lib"
	export CFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${CURRENTPATH}/include"
	export CXXFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${CURRENTPATH}/include"

	mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"

	LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-${NAME}-${VERSION}.log"

        echo "Follow the build log with: tail -f ${LOG}"
        echo "Please stand by..."

	./configure --host=${ARCH}-apple-darwin --prefix="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk" ${EXTRA_CONFIGURE_FLAGS} --disable-shared >> "${LOG}" 2>&1
	
	make >> "${LOG}" 2>&1
	make install >> "${LOG}" 2>&1
	cd ${CURRENTPATH}
	rm -rf src/${NAME}-${VERSION}
	
done

echo "Build library..."
lipo -create ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/lib/${NAME}.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv6.sdk/lib/${NAME}.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7.sdk/lib/${NAME}.a -output ${CURRENTPATH}/lib/${NAME}.a
mkdir -p ${CURRENTPATH}/include/${NAME}
cp -R ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/include/assuan.h ${CURRENTPATH}/include/${NAME}
echo "Static libary available at lib/${NAME}.a"
