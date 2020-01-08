#! /bin/bash

ALTROOT="$1"; shift
BINARIES="$@"

for b in $BINARIES
do
    d=$(dirname "${b}")
    if [ ! -d "${ALTROOT}${d}" ]; then
        /bin/mkdir -p "${ALTROOT}${d}"
    fi
    /bin/cp "${b}" "${ALTROOT}${d}"

    LIBS=$(ldd "${b}" | awk '{ print $3 }' | egrep -v -v ^'\(')

    for i in ${LIBS}; do
        d=$(dirname "${i}")
        if [ ! -d "${ALTROOT}${d}" ]; then
            /bin/mkdir -p "${ALTROOT}${d}"
        fi
            /bin/cp "${i}" "${ALTROOT}${d}"
    done

    ld=$(ldd "${b}" | grep 'ld-linux' | awk '{ print $1 }')
    d=$(dirname "${ld}")

    if [ ! -d "${ALTROOT}${d}" ]; then
        /bin/mkdir -p "${ALTROOT}${d}"
    fi
    /bin/cp "${ld}" "${ALTROOT}${d}"

done

/bin/cp /lib64/libnss_* ${ALTROOT}/lib64/

mkdir -p "${ALTROOT}/dev"

mknod -m 666 ${ALTROOT}/dev/null c 1 3
mknod -m 666 ${ALTROOT}/dev/zero c 1 5
mknod -m 666 ${ALTROOT}/dev/tty c 5 0
mknod -m 444 ${ALTROOT}/dev/random c 1 8
mknod -m 444 ${ALTROOT}/dev/urandom c 1 9
