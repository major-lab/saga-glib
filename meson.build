project('SAGA-GLib', 'c', 'vala',
        version: '1.0.0',
        meson_version: '>=0.31')

if not meson.is_subproject()
add_global_arguments(['-Wall',
                      '-Wno-deprecated-declarations',
                      '-Wno-implicit-function-declaration',
                      '-Wno-incompatible-pointer-types',
                      '-Wno-int-to-pointer-cast',
                      '-Wno-unused'], language: 'c')
endif

glib = dependency('glib-2.0')
gobject = dependency('gobject-2.0')
gio = dependency('gio-2.0')
gmodule = dependency('gmodule-2.0')
uuid = dependency('uuid')

subdir('src')
subdir('tests')
