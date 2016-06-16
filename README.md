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
 - `Saga.ParallelTaskContainer` to perform operations simultaneously

## Backends

Backends are provided by GModule and dynamically loaded via their appropriate
module loader (eg. `JobModule`) and stored in `${LIBDIR}/saga-glib-1.0/backends`.

To determine if a backend a specific feature, the `<feature>_init` symbol is
lookup up and loaded in the appropriate module.

