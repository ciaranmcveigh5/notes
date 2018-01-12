[
    {
        "name": "sonarqube",
        "image": "123.dkr.ecr.eu-west-2.amazonaws.com/spike/sonarqube:${git_hash}",
        "cpu": 200,
        "memory": 1024,
        "links": [],
        "portMappings": [
            {
                "containerPort": 9000,
                "hostPort": 0,
                "protocol": "tcp"
            },
            {
              "containerPort": 9002,
              "hostPort": 0,
              "protocol": "tcp"
            }
        ],
        "essential": true,
        "entryPoint": [],
        "command": [],
        "environment": [],
        "mountPoints": [],
        "volumesFrom": []
    }
]
