saga_sources = [
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
saga_lib = library('saga-glib-1.0', saga_sources, dependencies: [glib, gobject, gio, gmodule, uuid],
                   vala_args: ['--vapidir=' + meson.current_source_dir() + '/../vapi'],
                   install: true,
                   install_rpath: '$ORIGIN/saga-glib-1.0/backends')
saga = declare_dependency(include_directories: include_directories('.'),
                          link_with: saga_lib,
                          link_args: '-Wl,-rpath,@0@/backends'.format(meson.current_build_dir()))

install_data(meson.current_build_dir() + '/saga-glib-1.0.vapi', install_dir: 'share/vala/vapi')
install_data('saga-glib-1.0.deps', install_dir: 'share/vala/vapi')

# backends
subdir('backends')
