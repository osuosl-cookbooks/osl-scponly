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
