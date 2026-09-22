#!/bin/bash
set -xeo pipefail

EXPAT_VERSION="2.8.4"
EXPAT_SHA256="b8ece2437692dad44d851c4532723390a5a330990007706be9c8d2b90d294f36"

curl -sS -L "https://github.com/libexpat/libexpat/releases/download/R_${EXPAT_VERSION//./_}/expat-${EXPAT_VERSION}.tar.gz" \
    -o expat-${EXPAT_VERSION}.tar.gz
echo "${EXPAT_SHA256}  expat-${EXPAT_VERSION}.tar.gz" | sha256sum -c -
tar zxf expat-${EXPAT_VERSION}.tar.gz
rm expat-${EXPAT_VERSION}.tar.gz
pushd expat-${EXPAT_VERSION}
CONFIGURE_PRE="--prefix=/usr/local --enable-shared=yes --enable-static=yes --disable-dependency-tracking"
CFLAGS="-fPIC ${CFLAGS}"
if [ "$1" == "m32" ]; then
  setarch i386 ./configure ${CONFIGURE_PRE} CFLAGS="-m32 ${CFLAGS}"
else
  ./configure ${CONFIGURE_PRE} CFLAGS="${CFLAGS}"
fi
make install
popd
rm -rf expat-${EXPAT_VERSION}
