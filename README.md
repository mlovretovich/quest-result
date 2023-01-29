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
* I deployed the application on the Amazon Cloud's FARGATE serverless platform for containers. I chose FARGATE due to it's ability to run containers while creating minimal AWS resources. 
* I used Terraform to 

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
The terraform in this project will bring up a VPC and most resources required to run this application in the Amazon Cloud. 

#### Modules
* ecs_fargate_service
* load_balancer
* network

#### Variables
| Name | Required? | Notes |
| ---- | --------- | ----- | 
| app_name | Yes | The app_name variable is set in the Makefile based on the project's directory name | 
| app_version | Yes | The app_version variable is set in the Makefile based on the current git tag + commit number |
 


## Given more time, I would improve...
There are a number of changes I would make to this project given time. 
* it does bother me that the docker check does not pass. If this were a hard requirement and I am unable to debug the source code I would include a version of the application that runs on a simple ec2 instance.
* Add further network security. The Application should not need public IP addresses but for some reason I could not get it to pass health checks with a private IP. It's difficult to debug through without source code.
* Create
* CI/CD 
* * git actions to include terraform plans on pull requests
* 




