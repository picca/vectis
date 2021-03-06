#!/bin/sh
# vim:set ft=sh sw=4 sts=4 et:

set -e
set -u
set -x

if [ -n "${VECTIS_UNINSTALLED:-}" ]; then
    VECTIS="${PYTHON:-python3} ${VECTIS_UNINSTALLED}/run"
else
    VECTIS=vectis
fi

if [ -z "${VECTIS_TEST_SUDO:-}" ]; then
    echo "1..0 # SKIP This test requires VECTIS_TEST_SUDO=sudo or similar"
    exit 0
fi

if [ -z "${VECTIS_TEST_DEBIAN_MIRROR:-}" ]; then
    echo "1..0 # SKIP This test requires VECTIS_TEST_DEBIAN_MIRROR=http://192.168.122.1:3142/debian or similar"
    exit 0
fi

echo "1..1"

storage="$(mktemp -d)"

( cd "$storage"; apt-get --download-only source hello )

"$VECTIS_TEST_SUDO" $VECTIS --storage="${storage}" bootstrap \
    --mirror="${VECTIS_TEST_DEBIAN_MIRROR}" --size=23G
$VECTIS --storage="${storage}" sbuild-tarball \
    --mirror="${VECTIS_TEST_DEBIAN_MIRROR}" --suite=sid
$VECTIS --storage="${storage}" sbuild \
    --mirror="${VECTIS_TEST_DEBIAN_MIRROR}" --suite=sid "${storage}/"hello*.dsc
rm -fr "${storage}"

echo "ok 1"
