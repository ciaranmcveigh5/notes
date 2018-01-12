## DB Dockerfile

* Uses latest mysql version
* Sets up a database called test
* Creates a table called users with id, first_name, last_name and policy_id

## To test out locally

```
$ docker build -t local:test-1.0.0 .
$ docker run --name local-test -e MYSQL_ROOT_PASSWORD=my-secret-pw local:test-1.0.0
```
