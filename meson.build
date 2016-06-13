project('SAGA-GLib', 'c', 'vala',
        version: '1.0.0',
        meson_version: '>=0.31')

meson.add_install_script('install.sh')

glib = dependency('glib-2.0')
gobject = dependency('gobject-2.0')
gio = dependency('gio-2.0')
gmodule = dependency('gmodule-2.0')
uuid = dependency('uuid')

subdir('src')
