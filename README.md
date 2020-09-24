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
embulk guess ./try1/seed.yml -o ./try1/config.yml

embulk preview ./try1/config.yml
+---------+--------------+-------------------------+-------------------------+----------------------------+
| id:long | account:long |          time:timestamp |      purchase:timestamp |             comment:string |
+---------+--------------+-------------------------+-------------------------+----------------------------+
|       1 |       32,864 | 2015-01-27 19:23:49 UTC | 2015-01-27 00:00:00 UTC |                     embulk |
|       2 |       14,824 | 2015-01-27 19:01:23 UTC | 2015-01-27 00:00:00 UTC |               embulk jruby |
|       3 |       27,559 | 2015-01-28 02:20:02 UTC | 2015-01-28 00:00:00 UTC | Embulk "csv" parser plugin |
|       4 |       11,270 | 2015-01-29 11:54:36 UTC | 2015-01-29 00:00:00 UTC |                            |
+---------+--------------+-------------------------+-------------------------+----------------------------+

embulk run ./try1/config.yml
1,32864,2015-01-27 19:23:49,20150127,embulk
2,14824,2015-01-27 19:01:23,20150127,embulk jruby
3,27559,2015-01-28 02:20:02,20150128,Embulk "csv" parser plugin
4,11270,2015-01-29 11:54:36,20150129,
```

## Docker
- [Docker Compose](https://docs.docker.com/compose/)
- [dip](https://github.com/bibendi/dip)
- [GitHub CLI](https://cli.github.com/)

```sh
# Download test data
# ref: https://dev.mysql.com/doc/employee/en/
gh repo clone datacharmer/test_db

# Lunch MySQL server on 4306 port
dip provition

# Import test data to MySQL
docker-compose exec db /bin/bash -c 'cd /tmp/test_db && mysql -u root -p"$MYSQL_ROOT_PASSWORD" < employees.sql'
```

## MySQL

```sh
embulk gem install embulk-input-mysql
embulk guess ./mysql/seed.yml -o ./mysql/config.yml
embulk preview ./mysql/config.yml
+-------------+-------------------------+-------------------+------------------+---------------+-------------------------+
| emp_no:long |    birth_date:timestamp | first_name:string | last_name:string | gender:string |     hire_date:timestamp |
+-------------+-------------------------+-------------------+------------------+---------------+-------------------------+
|      10,001 | 1953-09-01 15:00:00 UTC |            Georgi |          Facello |             M | 1986-06-25 15:00:00 UTC |
|      10,002 | 1964-06-01 15:00:00 UTC |           Bezalel |           Simmel |             F | 1985-11-20 15:00:00 UTC |
|      10,003 | 1959-12-02 15:00:00 UTC |             Parto |          Bamford |             M | 1986-08-27 15:00:00 UTC |
|      10,004 | 1954-04-30 15:00:00 UTC |         Chirstian |          Koblick |             M | 1986-11-30 15:00:00 UTC |
|      10,005 | 1955-01-20 15:00:00 UTC |           Kyoichi |         Maliniak |             M | 1989-09-11 15:00:00 UTC |
...
...
```
