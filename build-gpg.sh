#!/bin/bash

#  Automatic build script for gnupg
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
SDKVERSION="7.1"
VERSION="1.4.16"
#
###########################################################################
#  No changes required beyond this point
#
CURRENTPATH=`pwd`
ARCHS="i386 x86_64 armv7 armv7s arm64"
DEVELOPER=`xcode-select -print-path`

set -e
if [ ! -e gnupg-${VERSION}.tar.bz2 ]; then
echo "Downloading gnupg-${VERSION}.tar.bz2"
curl -O ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-${VERSION}.tar.bz2
echo
else
echo "Using gnupg-${VERSION}.tar.bz2"
fi

mkdir -p bin
mkdir -p src

for ARCH in ${ARCHS}
do
if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]];
then
PLATFORM="iPhoneSimulator"
else
PLATFORM="iPhoneOS"
fi

rm -rf src/gnupg-${VERSION}
echo "Building gnupg for ${PLATFORM} ${SDKVERSION} ${ARCH}"
tar zxf gnupg-${VERSION}.tar.bz2 -C src
cd src/gnupg-${VERSION}

if [ "${VERSION}" == "1.4.11" ];
then
echo "Version ${VERSION} detected - Patch needed"
patch -p0 < ../../patches/libgcrypt-patch-1.4.6.diff
fi

export BUILD_DEVROOT="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
export BUILD_SDKROOT="${BUILD_DEVROOT}/SDKs/${PLATFORM}${SDKVERSION}.sdk"
export LD=${BUILD_DEVROOT}/usr/bin/ld
export CC="${DEVELOPER}/usr/bin/gcc -arch ${ARCH} -fheinous-gnu-extensions"
export CXX=${DEVELOPER}/usr/bin/g++

if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]];
then
export AR=${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/ar
export AS=${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/as
export NM=${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/nm
export RANLIB=${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/ranlib
else
export AR=${BUILD_DEVROOT}/usr/bin/ar
export AS=${BUILD_DEVROOT}/usr/bin/as
export NM=${BUILD_DEVROOT}/usr/bin/nm
export RANLIB=${BUILD_DEVROOT}/usr/bin/ranlib
export CPP=${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/cpp
fi

export LDFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${BUILD_SDKROOT} -L/usr/local/opt/gcc48/lib"
export CFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${BUILD_SDKROOT} -I${CURRENTPATH}/include"
export CXXFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I/usr/local/include -miphoneos-version-min=7.0 -fheinous-gnu-extensions"

HOST=${ARCH}
if [ "${ARCH}" == "arm64" ];
then
HOST="aarch64"
fi

mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"

LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-gnupg-${VERSION}.log"

echo "Follow the build log with: tail -f ${LOG}"
echo "Please stand by..."

./configure --host=${HOST}-apple-darwin --prefix="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk" ${EXTRA_CONFIGURE_FLAGS} --disable-dependency-tracking >> "${LOG}" 2>&1

mv "Makefile" "Makefile~"
sed '/checks =/d' "Makefile~" > "Makefile"  # Patch Makefile to disable checks

make >> "${LOG}" 2>&1
make install >> "${LOG}" 2>&1
cd ${CURRENTPATH}
rm -rf src/gnupg-${VERSION}
done

echo "Build executable..."
lipo -create ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/bin/gpg ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-x86_64.sdk/bin/gpg ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7.sdk/bin/gpg ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7s.sdk/bin/gpg ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-arm64.sdk/bin/gpg -output ${CURRENTPATH}/bin/gpg

cp -R ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/include/g ${CURRENTPATH}/include/
echo "Executable available at bin/gpg"
