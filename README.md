# Shaker

A Load Testing Tool That Optimized for Distribution Environments.

## Build
```shell
$ mix deps.get
$ mix escript
```

# Usage
Standalone mode
```shell
$ shaker -s "scenarios/*" -p 1 -l 1
```

Distributed mode
```shell
# slave
$ shaker --slave --node 'something@xxx.yyy.zzz'

# master
$ shaker -s "scenarios/*" -p 1 -l 1 -h "something@xxx.yyy.zzz"
```
