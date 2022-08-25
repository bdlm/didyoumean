# didyoumean

Turns `The most similar command` and `Did you mean` error prompts for CLI commands into menus that accept input and executes a corrected command.

## bash version

The [bash version](didyoumean.sh) is a bit slower but it maintains the TTY environment (colors, etc.)

## usage

```
$ source didyoumean.sh

$ alias git="__didyoumean git"

$ alias kubectl="__didyoumean kubectl"
```

```
$ git stats
    Did you mean this?
        status

[Y/n] > y
executing git status...

On branch master
Your branch is up to date with 'origin/master'.

nothing to commit, working tree clean
```

```
$ git rst --hard origin/master
    Did you mean one of these?
        1: first
        2: reset

        0: quit

[1] > 2
executing git reset --hard origin/master...

HEAD is now at 3db57b1 update README.md
```

```
$ kubectl git deploy
    Did you mean one of these?
        1: set
        2: get
        3: edit
        4: wait

        0: quit

[1] > 2
executing kubectl get deploy...

NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
api-server         2         2         2            2           293d
data-processor     8         8         8            8           1y
activity-monitor   3         3         3            3           1y
```
