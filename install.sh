#!/bin/sh

mkdir -p ${DESTDIR}${MESON_INSTALL_PREFIX}/share/vala/vapi

install -m 0644                       \
    ${MESON_BUILD_ROOT}/src/saga.vapi \
    ${DESTDIR}${MESON_INSTALL_PREFIX}/share/vala/vapi/saga-glib-1.0.vapi
