Build Scripts for Static iOS Libraries
======================================

These build scripts can be used to compile static libraries for use with iOS. You can build apps with XCode and the official SDK from Apple with this.

When run, the scripts download the respective source files, do simple dependency checks and compile.

The resulting libraries are universal binaries for the following platforms: i386, arm6 and arm7. This means they can be used with all iOS devices including the simulator.

To use the libraries, include the library from the created lib/ directory and header files from include/.

Tested with iOS SDK 5.1 (XCode 4.3.1) and OS X 10.7.3.

Currently supported versions:

 * gnupg (gpg) - 1.4.11
 * libassuan - 2.0.3
 * libgcrypt - 1.5.0
 * gnutls - 2.12.14
 * gpg-error - 1.10
 * gpgme (gpg made easy)- 1.3.1

Based on https://github.com/x2on/GnuTLS-for-iOS and https://github.com/3ign0n/GnuTLS-for-iOS.

There is also an example project demonstrating the use of GnuTLS at http://www.x2on.de/2011/02/01/gnutls-for-ios-iphone-and-ipad
