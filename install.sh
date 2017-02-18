#!/bin/sh

mkdir -p "${DESTDIR}/${MESON_INSTALL_PREFIX}/include/saga-glib-1.0"
mkdir -p "${DESTDIR}/${MESON_INSTALL_PREFIX}/share/vala/vapi"

install "${MESON_BUILD_ROOT}/src/saga-glib.h" "${MESON_INSTALL_DESTDIR_PREFIX}/include/saga-glib-1.0"
install "${MESON_BUILD_ROOT}/src/saga-glib-1.0.vapi" "${MESON_INSTALL_DESTDIR_PREFIX}/share/vala/vapi"
install "${MESON_SOURCE_ROOT}/src/saga-glib-1.0.deps" "${MESON_INSTALL_DESTDIR_PREFIX}/share/vala/vapi"
