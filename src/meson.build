saga_glib_sources = [
    'saga.vala',
    'saga-backend-module.vala',
    'saga-backend-types.vala',
    'saga-context.vala',
    'saga-error.vala',
    'saga-file-transfer.vala',
    'saga-job-description.vala',
    'saga-job-service.vala',
    'saga-job-state.vala',
    'saga-job.vala',
    'saga-metric.vala',
    'saga-monitorable.vala',
    'saga-object.vala',
    'saga-permission.vala',
    'saga-permissions.vala',
    'saga-serial-task-container.vala',
    'saga-session.vala',
    'saga-task.vala',
    'saga-task-container.vala',
    'saga-task-state.vala',
    'saga-url.vala',
    'saga-wait-mode.vala']
saga_glib_lib = library('saga-glib-1.0', saga_glib_sources, dependencies: [glib_dep, gobject_dep, gio_dep, gmodule_dep, uuid_dep],
                        vala_header: 'saga-glib.h',
                        link_args: '-Wl,-rpath,@0@'.format(join_paths(meson.current_build_dir(), 'backends')),
                        install: true,
                        install_dir: [true, 'include/saga-glib-1.0', true],
                        install_rpath: join_paths(get_option('prefix'), get_option('libdir'), 'saga-glib-1.0/backends'))
saga_glib_dep = declare_dependency(include_directories: include_directories('.'),
                                   link_with: saga_glib_lib)

install_data('saga-glib-1.0.deps', install_dir: 'share/vala/vapi')

# backends
subdir('backends')
