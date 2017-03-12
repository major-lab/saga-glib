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
               c_args: ['-DSAGA_TORQUE_QALTER="@@"'.format(qalter.path()),
                        '-DSAGA_TORQUE_QCHKPT="@@"'.format(qchkpt.path()),
                        '-DSAGA_TORQUE_QDEL="@@"'.format(qdel.path()),
                        '-DSAGA_TORQUE_QHOLD="@@"'.format(qhold.path()),
                        '-DSAGA_TORQUE_QRLS="@@"'.format(qrls.path()),
                        '-DSAGA_TORQUE_QSIG="@@"'.format(qsig.path()),
                        '-DSAGA_TORQUE_QSTAT="@@"'.format(qstat.path()),
                        '-DSAGA_TORQUE_QSUB="@@"'.format(qsub.path()),
                        '-DSAGA_TORQUE_SH="@@"'.format(sh.path())],
               install: true,
               install_dir: get_option('libdir') + '/saga-glib-1.0/backends')

shared_library('saga-glib-local', 'saga-local.vala',
               dependencies: [glib, gobject, gio, saga, uuid],
               vala_args: ['--pkg=linux', '--target-glib=2.40', '--vapidir=' + meson.current_source_dir () + '/../../vapi'],
               install: true,
               install_dir: get_option('libdir') + '/saga-glib-1.0/backends')
