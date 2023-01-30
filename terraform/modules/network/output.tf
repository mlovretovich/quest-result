# output the vpc id 
#
output "vpc_id" {
  value = aws_vpc.main.id
}

# output the created subnets 
#
output "subnets" {
  value = aws_subnet.main
}