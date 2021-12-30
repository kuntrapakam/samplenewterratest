output "terratest_vpc_id" {
  value       = aws_vpc.terratest.id
  description = "The main VPC id"
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "The public subnet id"
}

output "private_subnet_id" {
  value       = aws_subnet.private.id
  description = "The private subnet id"
}

output "network_acl_id" {
  value = aws_network_acl.terratestacl.id
}

output "security_group_sg" {
  value = aws_security_group.security_group
}