saga_sources = [
    'saga.vala',
    'saga-backend-module.vala',
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
    'saga-session.vala',
    'saga-url.vala']
saga_lib = library('saga-glib-1.0', saga_sources, dependencies: [glib, gobject, gio, gmodule, uuid],
                   vala_args: ['--vapidir=' + meson.current_source_dir() + '/../vapi', '--target-glib=2.40'],
                   link_args: '-Wl,-rpath,' + meson.current_build_dir() + '/backends',
                   install: true,
                   install_rpath: '$ORIGIN/saga-glib-1.0/backends')
saga = declare_dependency(link_with: saga_lib, include_directories: include_directories('.'))

# backends
subdir('backends')
