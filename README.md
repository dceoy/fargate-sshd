fargate-sshd
============

Dockerfile of SSH bastion server for AWS Fargate

Usage
-----

1.  Check out the repository.

    ```sh
    $ git clone https://github.com/dceoy/fargate-sshd.git
    $ cd fargate-sshd
    ```

2.  Create public/private RSA key pair.

    ```sh
    $ cd keys
    $ ssh-keygen -t rsa
    $ cd -
    ```

    If you use an already-existing pair, copy the public key file into `keys/` instead of the above step.

3.  Create a repository on AWS ECR and push a Docker image.

    ```sh
    $ SSH_PORT=443
    $ aws ecr create-repository  --repository-name ssh-bastion | tee config/ecr-repository.json
    $ ECR_REPO_URI=$(cat config/ecr-repository.json | jq '.repository.repositoryUri' | cut -d \" -f 2)
    $ $(aws ecr get-login --no-include-email --region ap-northeast-1)
    $ docker image build -t ssh-bastion --build-arg SSH_PORT="${SSH_PORT}" .
    $ docker image tag ssh-bastion:latest "${ECR_REPO_URI}"
    $ docker image push "${ECR_REPO_URI}"
    ```

4.  Register a task definition.

    ```sh
    $ aws ecs register-task-definition \
        --execution-role-arn ecsTaskExecutionRole \
        --family bastion-task-definition \
        --network-mode awsvpc \
        --requires-compatibilities FARGATE \
        --cpu 256 \
        --memory 512 \
        --container-definitions "[{ \
          \"name\": \"ssh-bastion\", \"image\": \"${ECR_REPO_URI}\", \"cpu\": 256, \"memory\": 512, \
          \"logConfiguration\": { \
            \"logDriver\": \"awslogs\", \
            \"options\": { \
              \"awslogs-group\": \"/ecs/ssh-bastion\", \"awslogs-region\": \"ap-northeast-1\", \
              \"awslogs-stream-prefix\": \"ecs\" \
            } \
          }, \
          \"portMappings\": [ \
            {\"containerPort\": ${SSH_PORT}, \"hostPort\": ${SSH_PORT}, \"protocol\": \"tcp\"} \
          ] \
        }]" | tee config/ecs-task-definition.json
    ```

6.  Run a cluster and a task on AWS ECS console.

7.  Connect to the container with the private key

    ```sh
    $ ssh -i keys/id_rsa -p 443 root@x.x.x.x
    ```
