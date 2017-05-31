foreach name : ['job-service', 'url']
    test(name, executable(name + '-test', name + '-test.vala',
                          dependencies: [glib_dep, gobject_dep, gio_dep, saga_glib_dep]))
endforeach
