# A Quest In The Clouds: Results
Results of my quest in the cloud

![quest](https://user-images.githubusercontent.com/2027534/215284609-361c15ff-8ee1-4f98-a543-8b5bf51091c7.gif)


## What did I do?

- [X] Start a git repository. 
- [ ] Deploy the app in the public cloud (Amazon).
- [X] Deploy the app in a Docker container. 
- [ ] Inject an Environment variable (SECRET_WORD) in the Docker container. 
- [ ] Deploy a load balancer in front of the app.
- [ ] Use Infrastructure as Code (IaC) to "codify" your deployment (Terraform).
- [ ] Add TLS (https).

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

##### Example 
```sh
$ make build
```
## Terraform

### Modules

### Variables


## What's next?




