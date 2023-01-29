# network
creates simple network resources for deployed application. 

## Inputs
| Name | Type | Required? | Description |
| ---- | ---- | --------- | ----------- | 
| app_name | string | Yes | The name of the application. This is used to namespace resources created. |
| tags | map(string) | No | The version of the container that should be run and declared in the task definition |


## Usage

```hcl
module "network" {
  source   = "./modules/network"
  app_name = [app_name]
  tags     = [tags]
}
```
