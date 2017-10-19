project('SAGA-GLib', 'c', 'vala',
        version: '1.0.0',
        meson_version: '>=0.42')

add_project_arguments(['--target-glib=2.40',
                       '--vapidir', join_paths(meson.current_source_dir(), 'vapi')], language: 'vala')

glib_dep = dependency('glib-2.0')
gobject_dep = dependency('gobject-2.0')
gio_dep = dependency('gio-2.0')
gmodule_dep = dependency('gmodule-2.0')
uuid_dep = dependency('uuid')

subdir('src')
subdir('tests')
