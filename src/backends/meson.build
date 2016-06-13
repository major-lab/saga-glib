xml = dependency('libxml-2.0')
shared_library('saga-torque', 'saga-torque.vala',
               dependencies: [glib, gobject, gio, saga, xml],
               install: true,
               install_dir: get_option('libdir') + '/saga-glib-1.0/backends')
