# A Quest In The Clouds: Results
Results of my quest in the cloud

![quest](https://user-images.githubusercontent.com/2027534/215284609-361c15ff-8ee1-4f98-a543-8b5bf51091c7.gif)


## What did I do?

- [X] Start a git repository. 
- [X] Deploy the app in the public cloud (Amazon).
- [X] Deploy the app in a Docker container. [^1]
- [X] Inject an Environment variable (SECRET_WORD) in the Docker container. 
- [X] Deploy a load balancer in front of the app.
- [X] Use Infrastructure as Code (IaC) to "codify" your deployment (Terraform).
- [X] Add TLS (https).

[^1]: I am considering this complete even though the application does not pass it's "docker" check. I assume this is due to the FARGATE platform not being compatible or granting access to check the docker daemon. I don't have access to the application source code so I cannot debug this further.

## How did I do it?



## Components

### Makefile
The application is built and deployed using make commands. 

#### Requirements
| Name | Version |
| ---- | ------- | 
| [terraform](https://www.terraform.io/) | 1.3 | 
| [awscli](https://aws.amazon.com/cli/) | 2.9 | 
| [docker](https://www.docker.com/) | 20 | 

#### Commands
| Command | Notes |
| ------- | ----- |
| build | builds docker image named after the project. |
| push |  pushes docker container to ECR Repository. |
| init |  initializes terraform environment and installs required provider and modules |
| plan |  outputs a terraform plan based on current state and changes|
| deploy |  builds, pushes, and applys the terraform plan for the current app version |
| destroy |  tears down all infrastructure |

##### Example 
```sh
$ make build
```
### Terraform

#### Modules

#### Variables


## What's next?




