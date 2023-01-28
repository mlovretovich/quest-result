# A Quest In The Clouds: Results
Results of my quest in the cloud

## What did I do?

- [X] Start a git repository. 
- [ ] Deploy the app in the public cloud (Amazon).
- [X] Deploy the app in a Docker container. 
- [ ] Inject an Environment variable (SECRET_WORD) in the Docker container. 
- [ ] Deploy a load balancer in front of the app.
- [ ] Use Infrastructure as Code (IaC) to "codify" your deployment (Terraform).
- [ ] Add TLS (https).


## Components

### Makefile
The application is built and deployed using make commands. 

#### Requirements
| Name | Version |
| ---- | ------- | 
| terraform | >=1.3 | 
| awscli | >= 2.9 | 
| docker | >= 20 | 

#### Commands
| Command | Notes |
| ------- | ----- |
| build | builds docker image named after the project. |
| push |  pushes docker container to ECR Repository. |

##### Example 
```
$ make build
```
