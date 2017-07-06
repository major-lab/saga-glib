# SAGA-GLib

Implementation of the Simple API for Grid Application for GLib.

## Features

Some features have been replaced by more GLib-friendly structures and
constructs.

| Feature              | Replacement                                                    |
| -------------------- | -------------------------------------------------------------- |
| Saga.Attribute       | GObject properties                                             |
| Saga.Buffer          | GIO primitives such as GBytes                                  |
| Saga.Callback        | GObject signals for callbacks                                  |
| Saga.Object.clone    | shallow and deep copy are implemented with ownership semantics |
| Saga.Object.get_type | GType                                                          |
| Saga.ErrorHandler    | GError                                                         |

Both synchronous and asynchronous APIs are provided with the `_async` suffix to
distinguish the latter. There is no batch operation implemented yet.

The `Saga.JobService` has a `get_service_url` method to obtain the passed URL
from the constructor.

There is no `Task.get_object` or `Task.rethrow` since errors are handled
directly at the source.

Two implementation of `Saga.TaskContainer` are provided:

 - `Saga.SerialTaskContainer` to perform operations serially
 - `Saga.ThreadedTaskContainer` to perform operations simultaneously

## Shallow or deep copies

To avoid messing with `Saga.Object.clone`, shallow and deep copies are
implemented with ownership semantics:

 - if a parameter is to be deep copied, it is passed as `owned`.
 - if a return value is to be deep copied, it is returned as `unowned`.

Only extensions to the specification are versioned, the `1.0` release will
provide a fully compliant implementation.

## Backends

Backends are dynamically loaded via GModule from `Saga.BackendModule` and
stored in `${LIBDIR}/saga-glib-1.0/backends`. The module only need to provide
a `backends_init` symbol which register necessary classes and interfaces and
return a struct containing `GType` from its specific implementations;
unsupported features are marked with `GLib.Type.INVALID`.

To load a backend, use `BackendModule.new_for_name`, which is used as well by
all static helpers (eg. `JobService.@new`).

```vala
[ModuleInit]
public Saga.BackendTypes backend_init (GLib.TypeModule type_module)
{
    return
    {
        typeof (Saga.CustomBackend.JobService),   // job
        typeof (Saga.CustomBackend.File),         // file
        typeof (Saga.CustomBackend.LogicalFile),  // replica
        typeof (Saga.CustomBackend.StreamServer), // stream
        typeof (Saga.CustomBackend.RPC),          // rpc
        GLib.Type.INVALID                         // mark unprovided feature
    };
}
```

### TORQUE

The TORQUE backend supports an array-based SPMD variation that can be used to
run multiple and similar jobs. Each job will have a `PBS_ARRAYID` environment
variable set with the corresponding value from the range.

```vala
var jd = new Job.Description ();
jd.smpd_variation = "Array=0-4"; // creates 5 jobs (range is inclusive)
```

