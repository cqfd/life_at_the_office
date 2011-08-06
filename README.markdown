# Life at the office

## What

This is a fun little [ZeroMQ](http://www.zeromq.org/) example that simulates
life at the office.

First, open up some terminals and fire up the boss and hr processes with

```bash
./boss_process
./hr_process
```

Next, fire up a worker process:

```bash
./worker_process
```

Now you can start bossing that worker around. In the boss's terminal, try
typing

```bash
somebody jump
```

Notice that the worker happily obliges and the hr person happily logs what
happened.

Next, have the boss request something complicated, and watch the worker
struggle valiantly.

```bash
somebody do_something_complicated
```

Notice that the boss asked for `somebody` to do something complicated; there's
only one worker, so that's the only worker who does something complicated.  Now
try firing up a few more worker processes in different terminals, and do some
more bossing. Notice that `somebody` requests are equitably distributed amongst
the workers, while `everybody` requests make it to every worker, no matter how
many there are and no matter when they started working!

## Prerequisites

```bash
brew install zeromq
gem install zmq
```
