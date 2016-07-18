qalter = find_program('qalter')
qchkpt = find_program('qchkpt')
qhold = find_program('qhold')
qrls = find_program('qrls')
qsig = find_program('qsig')
qstat = find_program('qstat')
qsub = find_program('qsub')
sh = find_program('sh')

gxml = dependency('gxml-0.10')
shared_library('saga-glib-torque', 'saga-torque.vala',
               dependencies: [glib, gobject, gio, saga, gxml, uuid],
               vala_args: ['--target-glib=2.40', '--vapidir=' + meson.current_source_dir () + '/../../vapi'],
               install: true,
               install_dir: get_option('libdir') + '/saga-glib-1.0/backends')
