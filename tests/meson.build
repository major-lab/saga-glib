foreach name : ['job-service', 'url']
    test(name, executable(name + '-test', name + '-test.vala',
                          dependencies: [glib_dep, gobject_dep, gio_dep, saga_glib_dep]))
endforeach

if get_option('with_introspection')
    test('gi', find_program('python3'),
         args: [join_paths(meson.current_source_dir(), 'gi-test.py')],
         env: ['GI_TYPELIB_PATH=@0@'.format(join_paths(meson.current_build_dir(), '..', 'src')),
               'LD_LIBRARY_PATH=@0@'.format(join_paths(meson.current_build_dir(), '..', 'src')),
               'SAGA_GLIB_BACKEND_PATH=@0@'.format(join_paths(meson.current_build_dir(), '../src/backends'))])
endif
