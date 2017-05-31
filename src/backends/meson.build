qalter_bin = find_program('qalter')
qchkpt_bin = find_program('qchkpt')
qdel_bin = find_program('qdel')
qhold_bin = find_program('qhold')
qrls_bin = find_program('qrls')
qsig_bin = find_program('qsig')
qstat_bin = find_program('qstat')
qsub_bin = find_program('qsub')
sh_bin = find_program('sh')

gxml_dep = dependency('gxml-0.14')
shared_module('saga-glib-torque', 'saga-torque.vala',
               dependencies: [glib_dep, gobject_dep, gio_dep, saga_glib_dep, gxml_dep, uuid_dep],
               c_args: ['-DSAGA_TORQUE_QALTER="@0@"'.format(qalter_bin.path()),
                        '-DSAGA_TORQUE_QCHKPT="@0@"'.format(qchkpt_bin.path()),
                        '-DSAGA_TORQUE_QDEL="@0@"'.format(qdel_bin.path()),
                        '-DSAGA_TORQUE_QHOLD="@0@"'.format(qhold_bin.path()),
                        '-DSAGA_TORQUE_QRLS="@0@"'.format(qrls_bin.path()),
                        '-DSAGA_TORQUE_QSIG="@0@"'.format(qsig_bin.path()),
                        '-DSAGA_TORQUE_QSTAT="@0@"'.format(qstat_bin.path()),
                        '-DSAGA_TORQUE_QSUB="@0@"'.format(qsub_bin.path()),
                        '-DSAGA_TORQUE_SH="@0@"'.format(sh_bin.path())],
               install: true,
               install_dir: join_paths(get_option('libdir'), 'saga-glib-1.0/backends'))

linux_dep = meson.get_compiler('vala').find_library('linux')
shared_module('saga-glib-local', 'saga-local.vala',
               dependencies: [glib_dep, gobject_dep, gio_dep, saga_glib_dep, uuid_dep, linux_dep],
               install: true,
               install_dir: join_paths(get_option('libdir'), 'saga-glib-1.0/backends'))
