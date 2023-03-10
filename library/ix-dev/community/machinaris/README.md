# Machinaris

- It is running with `host network` **enabled** at all times.
- It runs as `root` user.

## Storage

Every volume defined in `Machinaris Storage` under `Additional Volumes`,
will be mounted on all workers. Volumes that are `Used For: plots`,
will also add their `Mount Path` to `plots_dir` variable on each worker.

`Plotting` storage will be mounted on all workers at `/plotting`

## Coin Storage

Each coin have it's own `Config` and `Additional Volumes` storage.
Those will be mounted on the specific worker only.

The container mount path of `config` is `/root/.chia`
