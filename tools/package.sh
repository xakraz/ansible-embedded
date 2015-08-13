#!/bin/bash


set -e
set -u


## Vars
## --
PKG_NAME='ansible-embedded'
PKG_MAINT='viadeo1'
PKG_ARCH='amd64'
MAINTAINER='Xavier Krantz <xakraz@gmail.com>'
CONTAINER_SHARED_DIR='/media'

# These ENVIRONMENT variables should be available from the BASE image
# of the running container:
# - ANSIBLE_VERSION
# - PYTHON_VERSION
# - INSTALL_DIR


## Create fakeroot layout
## --
echo "===> $0 - Create Fakeroot FS Layout"
TMP_DIR=$(mktemp -d)
PKG_DIR="${TMP_DIR}/${PKG_NAME}_${ANSIBLE_VERSION}-${PKG_MAINT}_${PKG_ARCH}"
mkdir -pv ${PKG_DIR}/${INSTALL_DIR}
cp -vr ${INSTALL_DIR}/* ${PKG_DIR}/${INSTALL_DIR}/


## Make Debian files
## --
echo "===> $0 - Make the Debian files"
pushd ${PKG_DIR}
mkdir -v DEBIAN
find . -type f ! -path './DEBIAN/*' -printf '%P\0' | sort -z | xargs -r0 md5sum > DEBIAN/md5sums

cat >DEBIAN/control <<EOF
Package: ${PKG_NAME}
Version: ${ANSIBLE_VERSION}-${PKG_MAINT}
Section: admin
Priority: optional
Architecture: ${PKG_ARCH}
Maintainer: ${MAINTAINER}
Description: Ansible ${ANSIBLE_VERSION} with embedded Python binary (${PYTHON_VERSION}) and libraries.
  No dependencies, nothing more to say :)
  .
EOF
popd


## Make the package
## --
echo "===> $0 - Make the Deb"
fakeroot dpkg -b ${PKG_DIR}

## Publish the package in a (hopefuly) volume / Shared directory
echo "===> $0 -  Publish the package in a (hopefuly) volume / Shared directory '${CONTAINER_SHARED_DIR}'"
mv -v ${TMP_DIR}/*.deb ${CONTAINER_SHARED_DIR}/



