## Sonarqube Dockerfile

* Uses latest sonarqube version

## To test out locally

```
$ docker build -t sonarqube:project .
$ docker run -p 9000:9000 -p 9092:9092 -d sonarqube:project
```
