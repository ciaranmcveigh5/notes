[
    {
        "name": "${workspace}-api-gateway",
        "image": "123.dkr.ecr.eu-west-2.amazonaws.com/project/${workspace}/api-gateway:${api-gateway}",
        "cpu": 250,
        "memory": 512,
        "links": [
            "${workspace}-simple-app"
        ],
        "portMappings": [
            {
              "containerPort": 80,
              "hostPort": 80,
              "protocol": "tcp"
            }
        ],
        "essential": true
    },
    {
        "name": "${workspace}-simple-app",
        "image": "123.dkr.ecr.eu-west-2.amazonaws.com/project/${workspace}/simple-backend:${simple-backend}",
        "cpu": 250,
        "memory": 512,
        "portMappings": [
            {
              "containerPort": 8443,
              "hostPort": 8443,
              "protocol": "tcp"
            }
        ],
        "essential": true
    }
]
