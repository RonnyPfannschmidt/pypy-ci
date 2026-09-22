#!/bin/bash
set -xeo pipefail

SQLITE_SHA3=454e45f61c6bd75b7420e7190732dea03ce6639c63ada47bbc592f67fc340338
SQLITE_VERSION="3530400"
SQLITE_YEAR="2026"

function check_sha3 {
    local fname=$1
    local sha3_in=$2
    local sha3_file=$(openssl dgst -sha3-256 -r $fname |cut -d* -f1)
    if [ "$sha3_file" != "$sha3_in " ]; then  # extra " " is on purpose
        echo "sha3 mismatch"
        exit 1
    fi
}

curl -sS -#O "https://sqlite.org/${SQLITE_YEAR}/sqlite-autoconf-${SQLITE_VERSION}.tar.gz"
check_sha3 "sqlite-autoconf-${SQLITE_VERSION}.tar.gz" ${SQLITE_SHA3}
tar zxf sqlite*.tar.gz
pushd sqlite-autoconf-${SQLITE_VERSION}
CFLAGS="-Os -fPIC -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_FTS4 -DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_RTREE -DSQLITE_TCL=0"
# sqlite >= 3.49 uses autosetup, not autoconf: shared, static and threadsafe are
# on by default and the old --enable-* / --disable-dependency-tracking flags are rejected
CONFIGURE_PRE="--prefix=/usr/local --disable-readline"
if [ "$1" == "m32" ]; then
  setarch i386 ./configure ${CONFIGURE_PRE} CFLAGS="-m32 ${CFLAGS}"
else
  ./configure ${CONFIGURE_PRE} CFLAGS="${CFLAGS}"
fi
make install
popd
rm -rf sqlite*
