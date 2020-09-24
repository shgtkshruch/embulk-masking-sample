# embulk-masking-sample

## Install

```sh
# embulk: Java 1.8 is required to install this formula.
# Install AdoptOpenJDK 8 with Homebrew Cask:
brew cask install homebrew/cask-versions/adoptopenjdk8

# Install embulk
brew install embulk
```

## Example

[Official example](https://www.embulk.org/)

```sh
embulk example ./try1
embulk guess ./try1/seed.yml -o config.yml

embulk preview config.yml
+---------+--------------+-------------------------+-------------------------+----------------------------+
| id:long | account:long |          time:timestamp |      purchase:timestamp |             comment:string |
+---------+--------------+-------------------------+-------------------------+----------------------------+
|       1 |       32,864 | 2015-01-27 19:23:49 UTC | 2015-01-27 00:00:00 UTC |                     embulk |
|       2 |       14,824 | 2015-01-27 19:01:23 UTC | 2015-01-27 00:00:00 UTC |               embulk jruby |
|       3 |       27,559 | 2015-01-28 02:20:02 UTC | 2015-01-28 00:00:00 UTC | Embulk "csv" parser plugin |
|       4 |       11,270 | 2015-01-29 11:54:36 UTC | 2015-01-29 00:00:00 UTC |                            |
+---------+--------------+-------------------------+-------------------------+----------------------------+

embulk run config.yml
1,32864,2015-01-27 19:23:49,20150127,embulk
2,14824,2015-01-27 19:01:23,20150127,embulk jruby
3,27559,2015-01-28 02:20:02,20150128,Embulk "csv" parser plugin
4,11270,2015-01-29 11:54:36,20150129,
```

## Docker

```sh
# Lunch MySQL server on 4306 port
dip provition
```
