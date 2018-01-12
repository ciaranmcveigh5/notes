## Jenkins Dockerfile

* Uses latest jenkins version
* Sets up a jenkins, no install wizard

## To test out locally

```
$ docker build -t jenkins:project .
$ docker run -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker --volumes-from ${name} -d -e JENKINS_ADMIN_PASSWORD=mysecrethere jenkins:project

AWS Commands

docker build --no-cache -t 123.dkr.ecr.eu-west-2.amazonaws.com/spike/jenkins-data -f Dockerfile.data .
docker build --no-cache -t 123.dkr.ecr.eu-west-2.amazonaws.com/spike/jenkins .
```
