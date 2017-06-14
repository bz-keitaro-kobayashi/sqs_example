# SqsExample

Simple example of how one might use SQS.

## Dependencies

* Elixir, Erlang. `brew install elixir` should do it.

```bash
$ mix deps.get
$ iex -S mix
```

## Example

Default visibility timeout is 30 seconds.

In this example, jobs that take less than 30 seconds are only processed once.
If the job takes > 30 and < 60 seconds, it is processed twice. If the job takes > 60 and < 90 seconds,
it is processed three times (approximately).

```
07:27:19.357 [debug] [32] starting: "test_04" (takes 40s)
07:27:19.357 [debug] [4] starting: "test_01" (takes 10s)
07:27:19.358 [debug] [11] starting: "test_03" (takes 30s)
07:27:19.358 [debug] [6] starting: "test_06" (takes 60s)
07:27:19.358 [debug] [31] starting: "test_05" (takes 50s)
07:27:19.358 [debug] [29] starting: "test_02" (takes 20s)
07:27:19.358 [debug] [45] starting: "test_07" (takes 70s)
07:27:29.358 [debug] [4] done: "test_01"
07:27:39.358 [debug] [29] done: "test_02"
07:27:49.359 [debug] [11] done: "test_03"
07:27:49.511 [debug] [7] starting: "test_03" (takes 30s)
07:27:49.511 [debug] [15] starting: "test_05" (takes 50s)
07:27:49.512 [debug] [18] starting: "test_07" (takes 70s)
07:27:49.512 [debug] [12] starting: "test_04" (takes 40s)
07:27:49.513 [debug] [14] starting: "test_06" (takes 60s)
07:27:59.358 [debug] [32] done: "test_04"
07:28:09.358 [debug] [31] done: "test_05"
07:28:19.358 [debug] [6] done: "test_06"
07:28:19.511 [debug] [7] done: "test_03"
07:28:19.526 [debug] [33] starting: "test_07" (takes 70s)
07:28:29.358 [debug] [45] done: "test_07"
07:28:29.512 [debug] [12] done: "test_04"
07:28:39.513 [debug] [15] done: "test_05"
07:28:49.514 [debug] [14] done: "test_06"
07:28:59.512 [debug] [18] done: "test_07"
07:29:29.528 [debug] [33] done: "test_07"
```
