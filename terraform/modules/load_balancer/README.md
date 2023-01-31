# load_balancer
This module creates a load balancer within a vpc with both HTTP and HTTPS listeners. It creates a certificate and dns entries for the FQDN supplied. 

## Inputs
| Name | Type | Description |
| ---- | ---- | ----------- | 
| app_name | string | The name of the application. This is used to namespace resources created. |
| fqdn | string | Fully qualifiied domain name for the application. [subdomain].[domain].[top-level-domain]. This is HTTP address |
| lb_access_logs_bucket | string | s3 bucket for load balancer's access logs | 
| vpc_id | string | id of the VPC for this load balancer |
| subnet_ids | list(string) | list of subnets to attach to this load balancer |

## Outputs

| Name | Type | Description |
| ---- | ---- | ----------- | 
| target_group_arn | string | ARN of the target group created |

## Usage

```hcl
module "load_balancer" {
  source                = "./modules/load_balancer"
  fqdn                  = [fqdn]
  vpc_id                = [vpc_id]
  app_name              = [app_name]
  lb_access_logs_bucket = [lb_access_logs_bucket]
  subnet_ids            = [subnet_ids]
}

```
