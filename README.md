# embulk-masking-sample

## Install
- [Docker Compose](https://docs.docker.com/compose/)
- [dip](https://github.com/bibendi/dip)
- [GitHub CLI](https://cli.github.com/)

```sh
# Download test data
# ref: https://dev.mysql.com/doc/employee/en/
$ gh repo clone datacharmer/test_db

# Lunch MySQL server on 4306 port
$ dip provition

# Import test data to MySQL
$ docker-compose exec db /bin/bash -c 'mysql -u root -p"$MYSQL_ROOT_PASSWORD" < employees.sql'

# Install embulk gems
$ docker-compose exec -w /tmp/embulk/bundle embulk bash
$ embulk bundle install
```

## Example

[Official example](https://www.embulk.org/)

```sh
$ embulk example ./try1
$ embulk guess ./try1/seed.yml -o ./try1/config.yml

$ embulk preview ./try1/config.yml
+---------+--------------+-------------------------+-------------------------+----------------------------+
| id:long | account:long |          time:timestamp |      purchase:timestamp |             comment:string |
+---------+--------------+-------------------------+-------------------------+----------------------------+
|       1 |       32,864 | 2015-01-27 19:23:49 UTC | 2015-01-27 00:00:00 UTC |                     embulk |
|       2 |       14,824 | 2015-01-27 19:01:23 UTC | 2015-01-27 00:00:00 UTC |               embulk jruby |
|       3 |       27,559 | 2015-01-28 02:20:02 UTC | 2015-01-28 00:00:00 UTC | Embulk "csv" parser plugin |
|       4 |       11,270 | 2015-01-29 11:54:36 UTC | 2015-01-29 00:00:00 UTC |                            |
+---------+--------------+-------------------------+-------------------------+----------------------------+

$ embulk run ./try1/config.yml
1,32864,2015-01-27 19:23:49,20150127,embulk
2,14824,2015-01-27 19:01:23,20150127,embulk jruby
3,27559,2015-01-28 02:20:02,20150128,Embulk "csv" parser plugin
4,11270,2015-01-29 11:54:36,20150129,
```

## MySQL

```sh
$ docker-compose exec embulk bash
$ embulk guess -b bundle -o ./mysql/config.yml ./mysql/seed.yml
$ embulk preview -b bundle ./mysql/config.yml
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

$ embulk run -b bundle ./mysql/config.yml
```

## AWS

### Create IAM user for Terraform

create `.env-aws` file.

```
AWS_ACCESS_KEY_ID=xxx
AWS_SECRET_ACCESS_KEY=xxx
AWS_DEFAULT_REGION=xxx
```

```sh
$ dip aws iam create-user --user-name embulk-mysql-rds-masking
$ dip aws iam create-access-key --user-name embulk-mysql-rds-masking
$ dip aws iam attach-user-policy \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess \
  --user-name embulk-mysql-rds-masking
```

### Terraform

create `.env-tf` file with `embulk-mysql-rds-masking` credential.

```
AWS_ACCESS_KEY_ID=xxx
AWS_SECRET_ACCESS_KEY=xxx
AWS_DEFAULT_REGION=xxx
```

```sh
$ dip terraform init
$ dip terraform plan
$ dip terraform apply
```

### Load `test_data` to RDS

```sh
$ docker-compose exec db /bin/bash -c 'mysql -h HOST -u dbuser -ppassword < employees.sql'
```

## Data transfer

### Create RDS from snapshot

```sh
$ cd terraform/lambda && zip -r create-onetime-rds.zip create-onetime-rds.js && cd -
$ cd terraform/lambda && zip -r delete-onetime-rds.zip delete-onetime-rds.js && cd -

$ dip aws lambda invoke \
  --function-name create_onetime_rds \
  --cli-binary-format raw-in-base64-out \
  --payload '{ "DBInstanceIdentifier": "terraform-20200928095153696900000001" }' \
  out --log-type Tail

$ dip aws lambda invoke \
  --function-name delete_onetime_rds \
  --cli-binary-format raw-in-base64-out \
  --payload '{ "Identifier": "embulk-mysql-rds-masking" }' \
  out --log-type Tail
```

```sh
$ dip aws stepfunctions start-execution --state-machine-arn <value>
```

### Transfer data from RDS to local MySQL

1. Set db `host` to `mysql/seed.yml`
2. Run embulk

```sh
$ docker-compose exec embulk bash
$ embulk guess -b bundle -o ./mysql/config.yml ./mysql/seed.yml
$ embulk preview -b bundle ./mysql/config.yml
$ embulk run -b bundle ./mysql/config.yml
```

## Cleaning

Remove aws resources.

```sh
$ dip terraform destroy
```
