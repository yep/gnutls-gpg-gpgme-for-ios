Build Scripts for Static iOS Libraries
======================================

These build scripts can be used to compile static libraries for use with iOS. You can build apps with XCode and the official SDK from Apple with this.

When run, the scripts download the respective source files, do simple dependency checks and compile.

The resulting libraries are universal binaries for the following platforms: i386, x86_64, arm7, arm7s, and arm64. This means they can be used with iPhone 3gs and newer. Last revision to support arm6 (original iPhone and iPhone 3g) is SHA: 30160d92a0d0051001113ab580bbde09ba52020d.

To use the libraries, include the library from the created lib/ directory and header files from include/.

Build runs w/o errors on OSX 10.9.2 with Xcode 5.0.1 and iOS SDK 7.1.

Currently supported versions:

 * gnupg (gpg) - 1.4.13
 * libassuan - 2.1.1
 * libgcrypt - 1.5.3
 * gnutls - 2.12.14
 * gpg-error - 1.12
 * gpgme (gpg made easy)- 1.4.3

Based on https://github.com/x2on/GnuTLS-for-iOS and https://github.com/3ign0n/GnuTLS-for-iOS.

There is also an example project demonstrating the use of GnuTLS at http://www.x2on.de/2011/02/01/gnutls-for-ios-iphone-and-ipad
