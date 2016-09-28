qalter = find_program('qalter')
qchkpt = find_program('qchkpt')
qdel = find_program('qdel')
qhold = find_program('qhold')
qrls = find_program('qrls')
qsig = find_program('qsig')
qstat = find_program('qstat')
qsub = find_program('qsub')
sh = find_program('sh')

gxml = dependency('gxml-0.12')
shared_library('saga-glib-torque', 'saga-torque.vala',
               dependencies: [glib, gobject, gio, saga, gxml, uuid],
               vala_args: ['--target-glib=2.40', '--vapidir=' + meson.current_source_dir () + '/../../vapi'],
               c_args: ['-DSAGA_TORQUE_QALTER="@0@"'.format(qalter.path()[0]),
                        '-DSAGA_TORQUE_QCHKPT="@0@"'.format(qchkpt.path()[0]),
                        '-DSAGA_TORQUE_QDEL="@0@"'.format(qdel.path()[0]),
                        '-DSAGA_TORQUE_QHOLD="@0@"'.format(qhold.path()[0]),
                        '-DSAGA_TORQUE_QRLS="@0@"'.format(qrls.path()[0]),
                        '-DSAGA_TORQUE_QSIG="@0@"'.format(qsig.path()[0]),
                        '-DSAGA_TORQUE_QSTAT="@0@"'.format(qstat.path()[0]),
                        '-DSAGA_TORQUE_QSUB="@0@"'.format(qsub.path()[0]),
                        '-DSAGA_TORQUE_SH="@0@"'.format(sh.path()[0])],
               install: true,
               install_dir: get_option('libdir') + '/saga-glib-1.0/backends')

shared_library('saga-glib-local', 'saga-local.vala',
               dependencies: [glib, gobject, gio, saga, uuid],
               vala_args: ['--pkg=linux', '--target-glib=2.40', '--vapidir=' + meson.current_source_dir () + '/../../vapi'],
               install: true,
               install_dir: get_option('libdir') + '/saga-glib-1.0/backends')
