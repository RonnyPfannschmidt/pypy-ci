#!/bin/bash
# Download, verify and install a PyPy2.7 binary for translation and testing.
#
# Usage: install_pypy.sh <arch>   where <arch> is linux64, aarch64 or linux32
#
# Checksums are at https://pypy.org/checksums
set -xeo pipefail

PYPY_VERSION="8.0.0"
ARCH="${1:-linux64}"

case "${ARCH}" in
  linux64) PYPY_SHA256="714e8c41608d0d66588c3ba48fb788dc33a1e8a865168d165585d1660beade0d" ;;
  aarch64) PYPY_SHA256="9ece5a6f575514ed38dde663e7f54e59de01c35b2df6d1ef83e25490d6b7c7b8" ;;
  linux32) PYPY_SHA256="74d09cafbe0c85ae4c4d17d54099c6b31354235ffdd5277c01601434cc23e459" ;;
  *) echo "unknown arch '${ARCH}', expected linux64, aarch64 or linux32"; exit 1 ;;
esac

PYPY_NAME="pypy2.7-v${PYPY_VERSION}-${ARCH}"
PYPY_TARBALL="${PYPY_NAME}.tar.gz"

wget -q "https://downloads.python.org/pypy/${PYPY_TARBALL}" -O "${PYPY_TARBALL}"
echo "${PYPY_SHA256}  ${PYPY_TARBALL}" | sha256sum -c -
tar -C /opt -xzf "${PYPY_TARBALL}"
rm "${PYPY_TARBALL}"

# make sure the unprivileged buildworker user can read and traverse the install
chmod -R a+r "/opt/${PYPY_NAME}"
chmod -R a+X "/opt/${PYPY_NAME}"

ln -s "/opt/${PYPY_NAME}/bin/pypy" /usr/local/bin/pypy
ln -s "/opt/${PYPY_NAME}/bin/pypy" /usr/local/bin/python

pypy -mensurepip
pypy -mpip install --upgrade pip==20.3.4
pypy -mpip install --upgrade setuptools wheel
